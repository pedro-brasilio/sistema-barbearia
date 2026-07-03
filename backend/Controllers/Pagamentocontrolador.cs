using barbearia.dados;
using barbearia.modelos;
using Microsoft.AspNetCore.Http.HttpResults;

//using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
//using System.Numerics;

namespace barbearia.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class Pagamentocontrolador : ControllerBase
    {
        private readonly Barbeariacontext _context;
        public Pagamentocontrolador(Barbeariacontext context)
        {
            _context = context;
        }


        [HttpGet]
        public async Task<ActionResult<IEnumerable<pagamento>>> get()
        {
            return await _context.pagamentos.ToListAsync();
        }


        [HttpPost]
        public async Task<ActionResult> post(pagamento pagamentos)
        {
            _context.pagamentos.Add(pagamentos);
            await _context.SaveChangesAsync();

            return Ok(pagamentos);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult> put(int id, pagamento pagamentos)
        {
            if (id != pagamentos.ID)
                return BadRequest("ID invalido");
            _context.Entry(pagamentos).State = EntityState.Modified;
            await _context.SaveChangesAsync();

            return Ok(pagamentos);
            {
            }

        }


        [HttpDelete("{id}")]
        public async Task<ActionResult> delete(int id)
        {
            var pagamentos = await _context.pagamentos.FindAsync(id);

            if (pagamentos == null)
                return NotFound("pagamento nao encontrado");

            _context.pagamentos.Remove(pagamentos);
            await _context.SaveChangesAsync();

            return Ok("pagamento removido com sucesso");

        }
    }
}