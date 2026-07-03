using barbearia.dados;
using barbearia.modelos;
//using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
//using System.Numerics;

namespace barbearia.Controllers
{
    [Route("api/[Controller]")]
    [ApiController]

    public class AgendamentoServicocontrolador : ControllerBase
    {
        private readonly Barbeariacontext _context;
        public AgendamentoServicocontrolador(Barbeariacontext context)
        {
            _context = context;
        }
        

        [HttpGet]
        public async Task<ActionResult<IEnumerable<agendamentoservico>>> get()
        {
            return await _context.agendamentoservicos.ToListAsync();
        }

        

        [HttpPost]
        public async Task<ActionResult> Post(agendamentoservico agendamentoservicos)
        {
            _context.agendamentoservicos.Add(agendamentoservicos);
            await _context.SaveChangesAsync();

            return Ok(agendamentoservicos);
        }


        [HttpPut("{id}")]
        public async Task<ActionResult> put(int id,agendamentoservico agendamentoservico)
        {
            if (id != agendamentoservico.id)
                return BadRequest("ID invalido");
            _context.Entry(agendamentoservico).State = EntityState.Modified;
            await _context.SaveChangesAsync();

            return Ok(agendamentoservico);

        }

        [HttpDelete("{id}")]
        public async Task<ActionResult> delete(int id)
        {
            var agendamentoservico = await _context.agendamentoservicos.FindAsync(id);

            if (agendamentoservico == null)
                return NotFound("agedamento nao encontrado.");

            _context.agendamentoservicos.Remove(agendamentoservico);
            await _context.SaveChangesAsync();

            return Ok("agedamento cancelado.");

        }

    }
}
