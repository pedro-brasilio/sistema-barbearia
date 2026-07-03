using barbearia.dados;
using barbearia.modelos;
//using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
//using System.Numerics;

namespace barbearia.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ServicosControlador : ControllerBase
    {
        private readonly Barbeariacontext _context;
        public ServicosControlador(Barbeariacontext context)
        {
            _context = context;
        }


        [HttpGet]
        public async Task<ActionResult<IEnumerable<servico>>> Get()
        {
            return await _context.servicos.ToListAsync();
        }


        [HttpPost]
        public async Task<ActionResult> Post(servico servicos)
        {
            _context.servicos.Add(servicos);
            await _context.SaveChangesAsync();

            return Ok();
        }

        [HttpPut("{id}")]
        public async Task<ActionResult> put(int id, servico servico)
        {
            if (id != servico.ID)
                return BadRequest("ID invalido");
            _context.Entry(servico).State = EntityState.Modified;
            await _context.SaveChangesAsync();

            return Ok(servico);
            {
            }
        }


        [HttpDelete("{id}")]
        public async Task<ActionResult> delete(int id)
        {
            var servico = await _context.servicos.FindAsync(id);

            if (servico == null)
                return NotFound("servico nao encontrado");
            _context.servicos.Remove(servico);
            await _context.SaveChangesAsync();

            return Ok("servico removido");
        }
    }
}