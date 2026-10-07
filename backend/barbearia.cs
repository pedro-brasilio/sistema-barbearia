using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
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
app.MapControllers();
app.Run();