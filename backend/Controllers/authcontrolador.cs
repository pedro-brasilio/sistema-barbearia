using barbearia.dados;
using barbearia.modelos;
using barbearia.seguranca;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.EntityFrameworkCore;

namespace barbearia.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class authcontrolador : ControllerBase
    {
        // Limite de tentativas do "Esqueci a senha" (configurado em barbearia.cs)
        public const string LimiteRedefinirSenha = "redefinir-senha";

        // A mesma mensagem para e-mail inexistente, telefone errado ou conta de administrador,
        // para não revelar quais e-mails têm conta
        private const string ContaNaoConfere = "e-mail e telefone nao conferem com nenhuma conta.";

        private readonly Barbeariacontext _context;
        private readonly Tokens _tokens;

        public authcontrolador(Barbeariacontext context, Tokens tokens)
        {
            _context = context;
            _tokens = tokens;
        }

        [HttpPost("login")]
        public async Task<ActionResult> login([FromBody] LoginDto dadoslogin)
        {
            var email = Validacao.NormalizarEmail(dadoslogin.Email);
            var cliente = await _context.clientes
                .FirstOrDefaultAsync(c => c.Email.ToLower() == email);

            if (cliente == null)
                return BadRequest("email ou senha invalida.");

            bool senhavalida = BCrypt.Net.BCrypt.Verify(dadoslogin.senha ?? "", cliente.senha);

            if (!senhavalida)
                return BadRequest("email ou senha invalida.");

            return Ok(new
            {
                cliente.id,
                cliente.Nome,
                cliente.Email,
                cliente.Telefone,
                cliente.IsAdmin,
                // O site e o app mandam o token nas próximas chamadas
                token = _tokens.Gerar(cliente),
            });
        }

        // "Esqueci a senha" (site e app): o cliente prova que é dono da conta com o
        // e-mail e o telefone cadastrados, e define a nova senha na tela seguinte.
        // Contas de administrador não podem ser redefinidas por aqui.
        // Primeiro passo: confere se e-mail e telefone batem com a mesma conta.
        [HttpPost("verificar-email")]
        [EnableRateLimiting(LimiteRedefinirSenha)]
        public async Task<ActionResult> verificarEmail([FromBody] VerificarContaDto dados)
        {
            var cliente = await BuscarConta(dados.Email, dados.Telefone);

            if (cliente == null)
                return BadRequest(ContaNaoConfere);

            return Ok(new { existe = true });
        }

        // Segundo passo: grava a nova senha, conferindo e-mail e telefone de novo.
        [HttpPost("redefinir-senha")]
        [EnableRateLimiting(LimiteRedefinirSenha)]
        public async Task<ActionResult> redefinirSenha([FromBody] RedefinirSenhaDto dados)
        {
            var erroSenha = Validacao.Senha(dados.NovaSenha);
            if (erroSenha != null)
                return BadRequest(erroSenha);

            var cliente = await BuscarConta(dados.Email, dados.Telefone);

            if (cliente == null)
                return BadRequest(ContaNaoConfere);

            cliente.senha = BCrypt.Net.BCrypt.HashPassword(dados.NovaSenha);
            await _context.SaveChangesAsync();

            return Ok("senha redefinida com sucesso.");
        }

        // Cliente comum (nunca o administrador) com aquele e-mail e aquele telefone
        private async Task<cliente?> BuscarConta(string? emailDigitado, string? telefoneDigitado)
        {
            var email = Validacao.NormalizarEmail(emailDigitado);
            var telefone = Validacao.SoDigitos(telefoneDigitado);

            if (email.Length == 0 || !Validacao.TelefoneValido(telefone))
                return null;

            var contas = await _context.clientes
                .Where(c => c.Email.ToLower() == email && !c.IsAdmin)
                .ToListAsync();

            // O telefone pode estar salvo com máscara, então compara só os dígitos
            return contas.FirstOrDefault(c => Validacao.SoDigitos(c.Telefone) == telefone);
        }
    }

    public record LoginDto(string Email, string senha);
    public record VerificarContaDto(string Email, string? Telefone);
    public record RedefinirSenhaDto(string Email, string? Telefone, string NovaSenha);
}
