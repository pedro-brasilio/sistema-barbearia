using System.Text.RegularExpressions;
using barbearia.modelos;

namespace barbearia.seguranca
{
    // Regras de dados de cliente usadas no cadastro, na edição do perfil e no "Esqueci a senha"
    public static partial class Validacao
    {
        public const int SenhaMinima = 6;

        // E-mails são guardados e comparados sempre em minúsculas, sem espaços
        public static string NormalizarEmail(string? email) => (email ?? "").Trim().ToLowerInvariant();

        // "(11) 99999-0000" e "11999990000" valem o mesmo telefone
        public static string SoDigitos(string? texto) => new((texto ?? "").Where(char.IsDigit).ToArray());

        [GeneratedRegex(@"^[^@\s]+@[^@\s]+\.[^@\s]+$")]
        private static partial Regex FormatoEmail();

        // Telefone com DDD: 10 ou 11 dígitos (até 13 com o +55)
        public static bool TelefoneValido(string? telefone)
        {
            var digitos = SoDigitos(telefone).Length;
            return digitos >= 10 && digitos <= 13;
        }

        // Ajusta e confere nome, e-mail e telefone. Devolve a mensagem de erro, ou null se estiver tudo certo.
        // O administrador é criado sem telefone, então para ele o telefone vazio é aceito.
        public static string? DadosCliente(cliente c, bool telefoneOpcional = false)
        {
            c.Nome = (c.Nome ?? "").Trim();
            c.Email = NormalizarEmail(c.Email);
            c.Telefone = (c.Telefone ?? "").Trim();

            if (c.Nome.Length < 2 || c.Nome.Length > 100)
                return "informe o seu nome.";
            if (c.Email.Length > 150 || !FormatoEmail().IsMatch(c.Email))
                return "informe um e-mail valido.";
            if (!(telefoneOpcional && c.Telefone.Length == 0) && !TelefoneValido(c.Telefone))
                return "informe um telefone valido, com DDD.";

            return null;
        }

        public static string? Senha(string? senha)
        {
            if (string.IsNullOrWhiteSpace(senha) || senha.Length < SenhaMinima)
                return $"a senha precisa ter pelo menos {SenhaMinima} caracteres.";
            return null;
        }
    }
}
