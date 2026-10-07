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
    }

    public record LoginDto(string Email, string senha);
}