using barbearia.modelos;
using Microsoft.EntityFrameworkCore;
using Npgsql;

namespace barbearia.dados
{
    public static class Inicializadorbanco
    {
        // O Render fornece a conexão como URL (postgresql://usuario:senha@host:porta/banco),
        // mas o Npgsql espera o formato "Host=...;Username=...". Converte quando precisar.
        public static string ConverterConnectionString(string connectionString)
        {
            if (!connectionString.StartsWith("postgres://") && !connectionString.StartsWith("postgresql://"))
                return connectionString;

            var uri = new Uri(connectionString);
            var usuarioSenha = uri.UserInfo.Split(':', 2);

            return new NpgsqlConnectionStringBuilder
            {
                Host = uri.Host,
                Port = uri.Port > 0 ? uri.Port : 5432,
                Database = uri.AbsolutePath.TrimStart('/'),
                Username = Uri.UnescapeDataString(usuarioSenha[0]),
                Password = usuarioSenha.Length > 1 ? Uri.UnescapeDataString(usuarioSenha[1]) : null,
            }.ConnectionString;
        }

        // Cria/atualiza as tabelas e insere os dados iniciais (os mesmos do Barbearia.sql).
        public static void Inicializar(Barbeariacontext context, IConfiguration config)
        {
            context.Database.Migrate();

            // O site agenda sempre com Barbeiroid = 1
            if (!context.barbeiros.Any())
            {
                context.barbeiros.Add(new barbeiro { Nome = "Barbeiro Principal", Telefone = "(11) 99999-9999" });
            }

            if (!context.servicos.Any())
            {
                context.servicos.AddRange(
                    new servico { NameServico = "Corte Clássico", Preco = 45.00m, DuracaoMinutos = 30 },
                    new servico { NameServico = "Corte + Barba", Preco = 70.00m, DuracaoMinutos = 50 },
                    new servico { NameServico = "Barba Tradicional", Preco = 35.00m, DuracaoMinutos = 20 },
                    new servico { NameServico = "Corte Premium", Preco = 80.00m, DuracaoMinutos = 45 });
            }

            // O cadastro pela API sempre cria cliente comum, então o administrador
            // vem das configurações Admin:Email e Admin:Senha (no Render: Admin__Email e Admin__Senha).
            var adminEmail = config["Admin:Email"];
            var adminSenha = config["Admin:Senha"];

            if (!string.IsNullOrWhiteSpace(adminEmail) &&
                !string.IsNullOrWhiteSpace(adminSenha) &&
                !context.clientes.Any(c => c.Email == adminEmail))
            {
                context.clientes.Add(new cliente
                {
                    Nome = "Administrador",
                    Telefone = "",
                    Email = adminEmail,
                    senha = BCrypt.Net.BCrypt.HashPassword(adminSenha),
                    IsAdmin = true,
                });
            }

            context.SaveChanges();
        }
    }
}
