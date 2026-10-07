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
    public class Agedamentocontrolador : ControllerBase
    {
        private readonly Barbeariacontext _context;

        public Agedamentocontrolador(Barbeariacontext context)
        {
            _context = context;
        }

        // Lista todos os agendamentos (admin), com nome e telefone do cliente
        [HttpGet]
        [Authorize(Roles = Tokens.PapelAdmin)]
        public async Task<ActionResult> get()
        {
            var agendamentos = await (
                from a in _context.Agendamentos
                join c in _context.clientes on a.Clienteid equals c.id into clientes
                from c in clientes.DefaultIfEmpty()
                orderby a.Data, a.DataHorainicio
                select new
                {
                    a.id,
                    a.Clienteid,
                    a.Barbeiroid,
                    a.Servicos,
                    a.Data,
                    a.Situacao,
                    a.DataHorainicio,
                    ClienteNome = c != null ? c.Nome : "",
                    ClienteTelefone = c != null ? c.Telefone : "",
                })
                .ToListAsync();

            return Ok(agendamentos);
        }

        // Lista agendamentos de um cliente específico
        [HttpGet("cliente/{clienteId}")]
        [Authorize]
        public async Task<ActionResult<IEnumerable<Agendamento>>> getByCliente(int clienteId)
        {
            if (!User.PodeAcessarCliente(clienteId))
                return StatusCode(403, "sem permissao.");

            return await _context.Agendamentos
                .Where(a => a.Clienteid == clienteId)
                .OrderByDescending(a => a.Data)
                .ToListAsync();
        }

        // Criar agendamento com limite de 3 por mês
        [HttpPost]
        [Authorize]
        public async Task<ActionResult> post(Agendamento agendamento)
        {
            // O cliente só agenda para ele mesmo; o administrador pode agendar para qualquer um
            if (!User.EhAdmin())
                agendamento.Clienteid = User.Id();
            agendamento.id = 0;

            // Limite de 3 agendamentos no mês
            var inicio = new DateTime(agendamento.Data.Year, agendamento.Data.Month, 1);
            var fim = inicio.AddMonths(1);

            var countMes = await _context.Agendamentos
                .CountAsync(a =>
                    a.Clienteid == agendamento.Clienteid &&
                    a.Data >= inicio &&
                    a.Data < fim);

            if (countMes >= 3)
                return BadRequest("limite de 3 agendamentos por mes atingido.");

            // Verifica se horário já está ocupado
            var horarioOcupado = await _context.Agendamentos
                .AnyAsync(a =>
                    a.Data == agendamento.Data.Date &&
                    a.DataHorainicio == agendamento.DataHorainicio &&
                    a.Situacao != "cancelado");

            if (horarioOcupado)
                return BadRequest("horario ja esta ocupado.");

            agendamento.Situacao = "pendente";

            _context.Agendamentos.Add(agendamento);
            await _context.SaveChangesAsync();

            return Ok(agendamento);
        }

        // Admin confirma agendamento
        [HttpPatch("{id}/confirmar")]
        [Authorize(Roles = Tokens.PapelAdmin)]
        public async Task<ActionResult> confirmar(int id)
        {
            var agendamento = await _context.Agendamentos.FindAsync(id);

            if (agendamento == null)
                return NotFound("agendamento nao encontrado.");

            agendamento.Situacao = "confirmado";
            await _context.SaveChangesAsync();

            return Ok(agendamento);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = Tokens.PapelAdmin)]
        public async Task<ActionResult> put(int id, Agendamento agendamento)
        {
            if (id != agendamento.id)
                return BadRequest("ID invalido");

            _context.Entry(agendamento).State = EntityState.Modified;
            await _context.SaveChangesAsync();

            return Ok(agendamento);
        }

        // O cliente cancela os dele; o administrador remove qualquer um
        [HttpDelete("{id}")]
        [Authorize]
        public async Task<ActionResult> delete(int id)
        {
            var agendamento = await _context.Agendamentos.FindAsync(id);

            if (agendamento == null)
                return NotFound("agendamento nao encontrado.");

            if (!User.PodeAcessarCliente(agendamento.Clienteid))
                return StatusCode(403, "sem permissao.");

            _context.Agendamentos.Remove(agendamento);
            await _context.SaveChangesAsync();

            return Ok("agendamento removido com sucesso.");
        }
    }
}