using barbearia.dados;
using barbearia.modelos;
using barbearia.seguranca;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace barbearia.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class authcontrolador : ControllerBase
    {
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
            var cliente = await _context.clientes
                .FirstOrDefaultAsync(c => c.Email == dadoslogin.Email);

            if (cliente == null)
                return BadRequest("email ou senha invalida.");

            bool senhavalida = BCrypt.Net.BCrypt.Verify(dadoslogin.senha, cliente.senha);

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

        // "Esqueci a senha" (site e app): o cliente digita o e-mail e, se existir
        // uma conta com ele, o próprio cliente define a nova senha na tela seguinte.
        // Primeiro passo: confere se o e-mail tem conta.
        [HttpPost("verificar-email")]
        public async Task<ActionResult> verificarEmail([FromBody] VerificarEmailDto dados)
        {
            var existe = await _context.clientes.AnyAsync(c => c.Email == dados.Email);

            if (!existe)
                return NotFound("nao encontramos uma conta com esse e-mail.");

            return Ok(new { existe = true });
        }

        // Segundo passo: grava a nova senha para aquele e-mail.
        [HttpPost("redefinir-senha")]
        public async Task<ActionResult> redefinirSenha([FromBody] RedefinirSenhaDto dados)
        {
            if (string.IsNullOrWhiteSpace(dados.NovaSenha) || dados.NovaSenha.Length < 6)
                return BadRequest("a senha precisa ter pelo menos 6 caracteres.");

            var cliente = await _context.clientes
                .FirstOrDefaultAsync(c => c.Email == dados.Email);

            if (cliente == null)
                return NotFound("nao encontramos uma conta com esse e-mail.");

            cliente.senha = BCrypt.Net.BCrypt.HashPassword(dados.NovaSenha);
            await _context.SaveChangesAsync();

            return Ok("senha redefinida com sucesso.");
        }
    }

    public record LoginDto(string Email, string senha);
    public record VerificarEmailDto(string Email);
    public record RedefinirSenhaDto(string Email, string NovaSenha);
}