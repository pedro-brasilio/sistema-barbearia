namespace barbearia.modelos
{
    // Classificação semanal do agendamento, mantida pelo gatilho do PostgreSQL.
    // Os dados do cliente e do atendimento permanecem nas tabelas originais.
    public class AgendaSemanal
    {
        public int AgendamentoId { get; set; }
        public DateTime InicioSemana { get; set; }
    }
}
