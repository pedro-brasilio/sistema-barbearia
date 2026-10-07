using barbearia.dados;
using barbearia.modelos;
using barbearia.seguranca;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace barbearia.Controllers
{
    // Serviços mostrados no site e no app (início e agendamento).
    // Só o administrador cadastra, altera e remove, pela aba ADMIN > SERVIÇOS.
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
            return await _context.servicos.OrderBy(s => s.ID).ToListAsync();
        }


        [HttpPost]
        [Authorize(Roles = Tokens.PapelAdmin)]
        public async Task<ActionResult> Post(servico servico)
        {
            servico.ID = 0;
            var erro = await Validar(servico);
            if (erro != null)
                return BadRequest(erro);

            _context.servicos.Add(servico);
            await _context.SaveChangesAsync();

            return Ok(servico);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = Tokens.PapelAdmin)]
        public async Task<ActionResult> put(int id, servico servico)
        {
            if (id != servico.ID)
                return BadRequest("ID invalido");

            if (!await _context.servicos.AnyAsync(s => s.ID == id))
                return NotFound("servico nao encontrado");

            var erro = await Validar(servico);
            if (erro != null)
                return BadRequest(erro);

            _context.Entry(servico).State = EntityState.Modified;
            await _context.SaveChangesAsync();

            return Ok(servico);
        }


        [HttpDelete("{id}")]
        [Authorize(Roles = Tokens.PapelAdmin)]
        public async Task<ActionResult> delete(int id)
        {
            var servico = await _context.servicos.FindAsync(id);

            if (servico == null)
                return NotFound("servico nao encontrado");
            _context.servicos.Remove(servico);
            await _context.SaveChangesAsync();

            return Ok("servico removido");
        }

        // Os agendamentos guardam o nome do serviço, então o nome não pode se repetir
        private async Task<string?> Validar(servico servico)
        {
            servico.NameServico = (servico.NameServico ?? "").Trim();

            if (servico.NameServico.Length == 0 || servico.NameServico.Length > 40)
                return "o nome do servico precisa ter entre 1 e 40 caracteres.";
            if (servico.Preco <= 0 || servico.Preco > 10000)
                return "o preco precisa ser maior que zero.";
            if (servico.DuracaoMinutos < 5 || servico.DuracaoMinutos > 480)
                return "a duracao precisa ficar entre 5 e 480 minutos.";

            var nome = servico.NameServico.ToLower();
            if (await _context.servicos.AnyAsync(s => s.ID != servico.ID && s.NameServico.ToLower() == nome))
                return "ja existe um servico com esse nome.";

            servico.Preco = Math.Round(servico.Preco, 2);
            return null;
        }
    }
}
