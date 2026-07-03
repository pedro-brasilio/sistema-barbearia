namespace barbearia.modelos
{
    public class Agendamento
    {
        public int id { get; set; }
        public int Clienteid { get; set; }
        public int Barbeiroid { get; set; }
        public string Servicos { get; set; }
        public DateTime Data { get; set; }
        public string Situacao { get; set; }
        public TimeOnly DataHorainicio { get; set; }
    }

}