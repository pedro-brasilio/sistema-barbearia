using System.Security.Claims;
using System.Text;
using barbearia.modelos;
using Microsoft.IdentityModel.JsonWebTokens;
using Microsoft.IdentityModel.Tokens;

namespace barbearia.seguranca
{
    // Token de login (JWT). O login e o cadastro devolvem um token, e o site e o
    // app mandam esse token em toda chamada: "Authorization: Bearer <token>".
    // A chave de assinatura vem de Jwt:Chave (no Render: Jwt__Chave).
    public class Tokens
    {
        public const string PapelAdmin = "Admin";
        public const string PapelCliente = "Cliente";

        // Igual ao tempo que o site e o app guardam o login (só enquanto estão abertos)
        private static readonly TimeSpan Validade = TimeSpan.FromHours(12);

        public SymmetricSecurityKey Chave { get; }

        public Tokens(string chave)
        {
            if (string.IsNullOrWhiteSpace(chave) || chave.Length < 32)
                throw new InvalidOperationException(
                    "Configure Jwt:Chave com pelo menos 32 caracteres (no Render: variavel Jwt__Chave).");

            Chave = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(chave));
        }

        public string Gerar(cliente cliente)
        {
            return new JsonWebTokenHandler().CreateToken(new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(new[]
                {
                    new Claim("sub", cliente.id.ToString()),
                    new Claim("role", cliente.IsAdmin ? PapelAdmin : PapelCliente),
                }),
                Expires = DateTime.UtcNow.Add(Validade),
                SigningCredentials = new SigningCredentials(Chave, SecurityAlgorithms.HmacSha256),
            });
        }
    }

    public static class UsuarioLogado
    {
        // Id do cliente dono do token
        public static int Id(this ClaimsPrincipal usuario) =>
            int.Parse(usuario.FindFirstValue("sub")!);

        public static bool EhAdmin(this ClaimsPrincipal usuario) =>
            usuario.IsInRole(Tokens.PapelAdmin);

        // O próprio cliente ou o administrador
        public static bool PodeAcessarCliente(this ClaimsPrincipal usuario, int clienteId) =>
            usuario.EhAdmin() || usuario.Id() == clienteId;
    }
}
