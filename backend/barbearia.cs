using Microsoft.EntityFrameworkCore;
using barbearia.dados;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

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
app.UseCors("FrontendPolicy"); // precisa vir antes do UseAuthorization
app.UseAuthorization();
app.MapControllers();
app.Run();