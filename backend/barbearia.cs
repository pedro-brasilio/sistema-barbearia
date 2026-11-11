using System.Threading.RateLimiting;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using barbearia.Controllers;
using barbearia.dados;
using barbearia.seguranca;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Usado para chamar o webhook do n8n que envia as notificações push
builder.Services.AddHttpClient();

// Login com token JWT (ver seguranca/tokens.cs). Sem Jwt:Chave a API não sobe.
var tokens = new Tokens(builder.Configuration["Jwt:Chave"] ?? "");
builder.Services.AddSingleton(tokens);

builder.Services
    .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.MapInboundClaims = false; // mantém "sub" e "role" como vêm no token
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = false,
            ValidateAudience = false,
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = tokens.Chave,
            ClockSkew = TimeSpan.FromMinutes(1),
            NameClaimType = "sub",
            RoleClaimType = "role",
        };
    });
builder.Services.AddAuthorization();

// "Esqueci a senha": no máximo 10 tentativas a cada 10 minutos por endereço,
// para ninguém ficar chutando telefones até acertar
builder.Services.AddRateLimiter(options =>
{
    options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;
    options.OnRejected = (contexto, cancelamento) =>
        new ValueTask(contexto.HttpContext.Response.WriteAsync(
            "muitas tentativas. Espere alguns minutos e tente de novo.", cancelamento));

    options.AddPolicy(authcontrolador.LimiteRedefinirSenha, http =>
        RateLimitPartition.GetFixedWindowLimiter(
            http.Connection.RemoteIpAddress?.ToString() ?? "desconhecido",
            _ => new FixedWindowRateLimiterOptions
            {
                PermitLimit = 10,
                Window = TimeSpan.FromMinutes(10),
            }));
});

// Banco de dados (PostgreSQL)
var connectionString = Inicializadorbanco.ConverterConnectionString(
    builder.Configuration.GetConnectionString("DefaultConnection")!);

builder.Services.AddDbContext<Barbeariacontext>(options =>
    options.UseNpgsql(connectionString));

// CORS — permite o React chamar a API.
// Os endereços vêm de Cors:Origins (no Render: variável Cors__Origins), separados por vírgula.
var origensPermitidas = (builder.Configuration["Cors:Origins"] ?? "")
    .Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
    .Select(origem => origem.TrimEnd('/'))
    .ToArray();

builder.Services.AddCors(options =>
{
    options.AddPolicy("FrontendPolicy", policy =>
    {
        policy
            .WithOrigins(origensPermitidas)
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});

var app = builder.Build();

// Cria as tabelas e os dados iniciais na primeira execução
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<Barbeariacontext>();
    Inicializadorbanco.Inicializar(context, app.Configuration);
}

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseCors("FrontendPolicy"); // precisa vir antes do UseAuthentication
app.UseAuthentication();
app.UseAuthorization();
app.UseRateLimiter();
app.MapControllers();
app.Run();