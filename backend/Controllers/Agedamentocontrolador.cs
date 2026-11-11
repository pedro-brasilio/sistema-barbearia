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

        // Os mesmos horários dos botões do site (BookingForm.tsx) e do app (booking_page.dart)
        public static readonly HashSet<TimeOnly> HorariosAtendimento = new[]
        {
            "09:00", "09:30", "10:00", "10:30", "11:00", "11:30",
            "14:00", "14:30", "15:00", "15:30", "16:00", "16:30",
            "17:00", "17:30", "18:00", "18:30", "19:00",
        }.Select(TimeOnly.Parse).ToHashSet();

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
            agendamento.Data = agendamento.Data.Date;
            agendamento.Servicos = (agendamento.Servicos ?? "").Trim();

            // Só os horários que o site e o app oferecem
            if (!HorariosAtendimento.Contains(agendamento.DataHorainicio))
                return BadRequest("escolha um dos horarios de atendimento.");

            // Horário de Brasília (sem horário de verão desde 2019)
            var agora = DateTime.UtcNow.AddHours(-3);
            if (agendamento.Data.Add(agendamento.DataHorainicio.ToTimeSpan()) <= agora)
                return BadRequest("esse horario ja passou.");

            // Duração de cada serviço, para saber até quando o horário fica ocupado
            var duracoes = new Dictionary<string, int>();
            foreach (var s in await _context.servicos.ToListAsync())
                duracoes.TryAdd(s.NameServico.Trim().ToLower(), s.DuracaoMinutos);

            if (!duracoes.TryGetValue(agendamento.Servicos.ToLower(), out var duracaoNovo))
                return BadRequest("servico nao encontrado.");

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

            // Verifica se o horário bate com outro agendamento do dia, contando a duração
            // dos serviços (ex.: um "Corte + Barba" de 50 min às 10:00 ocupa também 10:30)
            var doDia = await _context.Agendamentos
                .Where(a => a.Data == agendamento.Data && a.Situacao != "cancelado")
                .Select(a => new { a.DataHorainicio, a.Servicos })
                .ToListAsync();

            int Minutos(TimeOnly hora) => hora.Hour * 60 + hora.Minute;
            // Serviço que não existe mais conta como 30 min (o intervalo entre horários)
            int Duracao(string servico) =>
                duracoes.TryGetValue((servico ?? "").Trim().ToLower(), out var d) ? d : 30;

            var inicioNovo = Minutos(agendamento.DataHorainicio);
            var fimNovo = inicioNovo + duracaoNovo;

            var horarioOcupado = doDia.Any(a =>
            {
                var inicio = Minutos(a.DataHorainicio);
                var fim = inicio + Duracao(a.Servicos);
                return inicio < fimNovo && inicioNovo < fim;
            });

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