using barbearia.dados;
using barbearia.modelos;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace barbearia.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class Clientecontrolador : ControllerBase
    {
        private readonly Barbeariacontext _context;

        public Clientecontrolador(Barbeariacontext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<cliente>>> get()
        {
            return await _context.clientes.ToListAsync();
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<cliente>> getById(int id)
        {
            var cliente = await _context.clientes.FindAsync(id);

            if (cliente == null)
                return NotFound("cliente nao encontrado.");

            return Ok(cliente);
        }

        [HttpPost("cadastro")]
        public async Task<ActionResult> cadastro(cliente dadoscadastro)
        {
            // Verifica se email já existe
            if (await _context.clientes.AnyAsync(c => c.Email == dadoscadastro.Email))
                return BadRequest("email ja cadastrado.");

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
                dadoscadastro.IsAdmin
            });
        }

        [HttpPut("{id}")]
        public async Task<ActionResult> put(int id, cliente cliente)
        {
            if (id != cliente.id)
                return BadRequest("ID invalido");

            _context.Entry(cliente).State = EntityState.Modified;
            await _context.SaveChangesAsync();

            return Ok(cliente);
        }

        [HttpDelete("{id}")]
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
}