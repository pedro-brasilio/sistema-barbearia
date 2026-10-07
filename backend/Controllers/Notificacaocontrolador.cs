using System.Text.Json;
using barbearia.dados;
using barbearia.modelos;
using barbearia.seguranca;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace barbearia.Controllers
{
    // Envio de avisos e promoções pela aba ADMIN do site e do app.
    // A API escolhe os clientes pelo filtro e o n8n (workflow em n8n/ na raiz
    // do repositório) manda a notificação para cada celular pelo Firebase.
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = Tokens.PapelAdmin)]
    public class Notificacaocontrolador : ControllerBase
    {
        private readonly Barbeariacontext _context;
        private readonly IHttpClientFactory _httpClientFactory;
        private readonly IConfiguration _config;

        public Notificacaocontrolador(Barbeariacontext context, IHttpClientFactory httpClientFactory, IConfiguration config)
        {
            _context = context;
            _httpClientFactory = httpClientFactory;
            _config = config;
        }

        // Quantos clientes com o app recebem a notificação, para o painel mostrar antes de enviar
        [HttpGet("publico")]
        public async Task<ActionResult> publico([FromQuery] string filtro)
        {
            var clientes = FiltrarClientes(filtro);
            if (clientes == null)
                return BadRequest("filtro invalido.");

            return Ok(new { filtro, total = await clientes.CountAsync() });
        }

        [HttpPost("enviar")]
        public async Task<ActionResult> enviar([FromBody] EnviarNotificacaoDto dados)
        {
            var titulo = dados.Titulo.Trim();
            var mensagem = dados.Mensagem.Trim();

            // Limites de quanto o Android mostra na notificação
            if (titulo.Length == 0 || mensagem.Length == 0)
                return BadRequest("escreva o titulo e a mensagem.");
            if (titulo.Length > 65 || mensagem.Length > 240)
                return BadRequest("o titulo pode ter ate 65 caracteres e a mensagem ate 240.");

            var clientes = FiltrarClientes(dados.Filtro);
            if (clientes == null)
                return BadRequest("filtro invalido.");

            var destinatarios = await clientes
                .OrderBy(c => c.Nome)
                .Select(c => new { clienteId = c.id, nome = c.Nome, token = c.TokenPush })
                .ToListAsync();

            if (destinatarios.Count == 0)
                return Ok(new { total = 0, enviados = 0, falhas = 0, erro = "" });

            // No Render: variáveis N8n__WebhookUrl e N8n__Chave (a mesma chave da credencial do webhook no n8n)
            var webhookUrl = _config["N8n:WebhookUrl"];
            if (string.IsNullOrWhiteSpace(webhookUrl))
                return StatusCode(503, "o envio de notificacoes nao esta configurado na API (N8n:WebhookUrl).");

            using var requisicao = new HttpRequestMessage(HttpMethod.Post, webhookUrl)
            {
                Content = JsonContent.Create(new { titulo, mensagem, destinatarios }),
            };
            requisicao.Headers.Add("X-Chave-Notificacoes", _config["N8n:Chave"] ?? "");

            HttpResponseMessage resposta;
            try
            {
                resposta = await _httpClientFactory.CreateClient().SendAsync(requisicao);
            }
            catch (HttpRequestException)
            {
                return StatusCode(502, "nao foi possivel falar com o n8n. Confira se ele esta no ar.");
            }

            if (!resposta.IsSuccessStatusCode)
                return StatusCode(502, $"o n8n recusou o envio (HTTP {(int)resposta.StatusCode}).");

            // Se o workflow quebrar antes do fim, o n8n responde 200 sem corpo
            ResultadoEnvio? resultado = null;
            try
            {
                resultado = await resposta.Content.ReadFromJsonAsync<ResultadoEnvio>();
            }
            catch (JsonException)
            {
            }

            if (resultado == null)
                return StatusCode(502, "o n8n nao devolveu o resultado do envio. Veja a execucao com erro no n8n.");

            return Ok(new
            {
                total = destinatarios.Count,
                enviados = resultado.Enviados,
                falhas = resultado.Falhas,
                erro = resultado.PrimeiroErro ?? "",
            });
        }

        // Só clientes que já entraram pelo app (têm token); o administrador fica de fora
        private IQueryable<cliente>? FiltrarClientes(string filtro)
        {
            // Horário de Brasília (sem horário de verão desde 2019)
            var agora = DateTime.UtcNow.AddHours(-3);
            var hoje = new DateTime(agora.Year, agora.Month, agora.Day);
            var trintaDiasAtras = hoje.AddDays(-30);

            var clientes = _context.clientes.Where(c => !c.IsAdmin && c.TokenPush != null);
            var agendamentos = _context.Agendamentos.Where(a => a.Situacao != "cancelado");

            return filtro switch
            {
                "todos" => clientes,

                // Nenhum horário de hoje em diante
                "sem_agendamento" => clientes.Where(c =>
                    !agendamentos.Any(a => a.Clienteid == c.id && a.Data >= hoje)),

                // Pelo menos um horário de hoje em diante
                "com_agendamento" => clientes.Where(c =>
                    agendamentos.Any(a => a.Clienteid == c.id && a.Data >= hoje)),

                "nunca_agendou" => clientes.Where(c =>
                    !agendamentos.Any(a => a.Clienteid == c.id)),

                // Já agendou, mas o último horário foi há mais de 30 dias e não tem outro marcado
                "sumidos" => clientes.Where(c =>
                    agendamentos.Any(a => a.Clienteid == c.id) &&
                    !agendamentos.Any(a => a.Clienteid == c.id && a.Data >= trintaDiasAtras)),

                _ => null,
            };
        }

        // Resposta do workflow do n8n
        private record ResultadoEnvio(int Enviados, int Falhas, string? PrimeiroErro);
    }

    public record EnviarNotificacaoDto(string Titulo, string Mensagem, string Filtro);
}
