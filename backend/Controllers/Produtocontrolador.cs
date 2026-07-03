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
    public class Produtocontrolador : ControllerBase
    {
        private readonly Barbeariacontext _context;

        public Produtocontrolador(Barbeariacontext context)
        {
            _context = context;
        }


        [HttpGet]
        public async Task<ActionResult<IEnumerable<produto>>> get()
        {
            return await _context.produtos.ToListAsync();
        }


        [HttpPost]
        public async Task<ActionResult> Post(produto produtos)
        {
            _context.produtos.Add(produtos);
            await _context.SaveChangesAsync();

            return Ok(produtos);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult> put(int id, produto produto)
        {
            if (id != produto.Id)
                return BadRequest("ID invalido");
            _context.Entry(produto).State = EntityState.Modified;
            await _context.SaveChangesAsync();

            return Ok(produto);
            {
            }

        }


        [HttpDelete("{id}")]
        public async Task<ActionResult> delete(int id)
        {
            var produto = await _context.produtos.FindAsync(id);

            if (produto == null)
                return NotFound("produto nao encontrado");

            _context.produtos.Remove(produto);
            await _context.SaveChangesAsync();

            return Ok("produto removido com sucesso");
        }
    }
}