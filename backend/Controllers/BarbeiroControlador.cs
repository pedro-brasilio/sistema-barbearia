using barbearia.dados;
using barbearia.modelos;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
//using System.Numerics;

namespace barbearia.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class BarbeiroControlador : ControllerBase
    {
        private readonly Barbeariacontext _context;

        public BarbeiroControlador(Barbeariacontext context)
        {
            _context = context;
        }


        [HttpGet]
        public async Task<ActionResult<IEnumerable<barbeiro>>> get()
        {
            return await _context.barbeiros.ToListAsync();
        }


        [HttpPost]
        public async Task<ActionResult> Post(barbeiro barbeiros)
        {
            _context.barbeiros.Add(barbeiros);
            await _context.SaveChangesAsync();

            return Ok(barbeiros);
        }


        [HttpPut("{id}")]
        public async Task<ActionResult> put(int id, barbeiro barbeiro)
        {
            if (id != barbeiro.id)
                return BadRequest("ID invalido");
            _context.Entry(barbeiro).State = EntityState.Modified;
            await _context.SaveChangesAsync();

            return Ok(barbeiro);
            {
            }
        }


        [HttpDelete("{id}")]
        public async Task<ActionResult> delete(int id)
        {
            var barbeiro = await _context.barbeiros.FindAsync(id);

            if (barbeiro == null)
                return NotFound("usuario nao encontrado.");

            _context.barbeiros.Remove(barbeiro);
            await _context.SaveChangesAsync();

            return Ok("usuario removido com sucesso.");
        }
    }
}