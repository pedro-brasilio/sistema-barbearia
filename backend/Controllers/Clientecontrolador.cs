using barbearia.dados;
using barbearia.modelos;
using barbearia.seguranca;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace barbearia.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class Clientecontrolador : ControllerBase
    {
        private readonly Barbeariacontext _context;
        private readonly Tokens _tokens;

        public Clientecontrolador(Barbeariacontext context, Tokens tokens)
        {
            _context = context;
            _tokens = tokens;
        }

        // Dados que podem sair da API: nunca a senha (hash) nem o token do celular
        private static object Publico(cliente c) => new { c.id, c.Nome, c.Telefone, c.Email, c.IsAdmin };

        [HttpGet]
        [Authorize(Roles = Tokens.PapelAdmin)]
        public async Task<ActionResult> get()
        {
            var clientes = await _context.clientes.OrderBy(c => c.id).ToListAsync();
            return Ok(clientes.Select(Publico));
        }

        [HttpGet("{id}")]
        [Authorize]
        public async Task<ActionResult> getById(int id)
        {
            if (!User.PodeAcessarCliente(id))
                return StatusCode(403, "sem permissao.");

            var cliente = await _context.clientes.FindAsync(id);

            if (cliente == null)
                return NotFound("cliente nao encontrado.");

            return Ok(Publico(cliente));
        }

        [HttpPost("cadastro")]
        public async Task<ActionResult> cadastro(cliente dadoscadastro)
        {
            // Verifica se email já existe
            if (await _context.clientes.AnyAsync(c => c.Email == dadoscadastro.Email))
                return BadRequest("email ja cadastrado.");

            // O cadastro sempre cria um cliente comum, com id gerado pelo banco
            dadoscadastro.id = 0;
            dadoscadastro.senha = BCrypt.Net.BCrypt.HashPassword(dadoscadastro.senha);
            dadoscadastro.IsAdmin = false;

            _context.clientes.Add(dadoscadastro);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                dadoscadastro.id,
                dadoscadastro.Nome,
                dadoscadastro.Email,
                dadoscadastro.Telefone,
                dadoscadastro.IsAdmin,
                // Já entra logado
                token = _tokens.Gerar(dadoscadastro),
            });
        }

        // Altera só nome, telefone e e-mail. Senha e administrador não mudam por aqui.
        [HttpPut("{id}")]
        [Authorize]
        public async Task<ActionResult> put(int id, cliente dados)
        {
            if (id != dados.id)
                return BadRequest("ID invalido");

            if (!User.PodeAcessarCliente(id))
                return StatusCode(403, "sem permissao.");

            var cliente = await _context.clientes.FindAsync(id);

            if (cliente == null)
                return NotFound("cliente nao encontrado.");

            if (await _context.clientes.AnyAsync(c => c.Email == dados.Email && c.id != id))
                return BadRequest("email ja cadastrado.");

            cliente.Nome = dados.Nome;
            cliente.Telefone = dados.Telefone;
            cliente.Email = dados.Email;
            await _context.SaveChangesAsync();

            return Ok(Publico(cliente));
        }

        // O app Android envia o token do Firebase depois do login, para o n8n
        // saber para qual celular mandar as notificações deste cliente
        [HttpPut("{id}/token-push")]
        [Authorize]
        public async Task<ActionResult> salvarTokenPush(int id, TokenPushDto dados)
        {
            // Só o próprio cliente liga o celular dele à conta
            if (User.Id() != id)
                return StatusCode(403, "sem permissao.");

            var cliente = await _context.clientes.FindAsync(id);

            if (cliente == null)
                return NotFound("cliente nao encontrado.");

            // Um celular recebe as notificações só da última conta que entrou nele
            await _context.clientes
                .Where(c => c.TokenPush == dados.Token && c.id != id)
                .ExecuteUpdateAsync(s => s.SetProperty(c => c.TokenPush, (string?)null));

            cliente.TokenPush = dados.Token;
            await _context.SaveChangesAsync();

            return Ok("token salvo.");
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = Tokens.PapelAdmin)]
        public async Task<ActionResult> delete(int id)
        {
            var cliente = await _context.clientes.FindAsync(id);

            if (cliente == null)
                return NotFound("cliente nao encontrado.");

            _context.clientes.Remove(cliente);
            await _context.SaveChangesAsync();

            return Ok("cliente removido com sucesso.");
        }
    }

    public record TokenPushDto(string Token);
}