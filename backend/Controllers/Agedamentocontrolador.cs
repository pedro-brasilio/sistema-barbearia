using barbearia.dados;
using barbearia.modelos;
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

        // Lista todos os agendamentos (admin)
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Agendamento>>> get()
        {
            return await _context.Agendamentos
                .OrderBy(a => a.Data)
                .ThenBy(a => a.DataHorainicio)
                .ToListAsync();
        }

        // Lista agendamentos de um cliente específico
        [HttpGet("cliente/{clienteId}")]
        public async Task<ActionResult<IEnumerable<Agendamento>>> getByCliente(int clienteId)
        {
            return await _context.Agendamentos
                .Where(a => a.Clienteid == clienteId)
                .OrderByDescending(a => a.Data)
                .ToListAsync();
        }

        // Criar agendamento com limite de 3 por mês
        [HttpPost]
        public async Task<ActionResult> post(Agendamento agendamento)
        {
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
        public async Task<ActionResult> put(int id, Agendamento agendamento)
        {
            if (id != agendamento.id)
                return BadRequest("ID invalido");

            _context.Entry(agendamento).State = EntityState.Modified;
            await _context.SaveChangesAsync();

            return Ok(agendamento);
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult> delete(int id)
        {
            var agendamento = await _context.Agendamentos.FindAsync(id);

            if (agendamento == null)
                return NotFound("agendamento nao encontrado.");

            _context.Agendamentos.Remove(agendamento);
            await _context.SaveChangesAsync();

            return Ok("agendamento removido com sucesso.");
        }
    }
}