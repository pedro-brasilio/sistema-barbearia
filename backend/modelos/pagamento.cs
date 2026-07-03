namespace barbearia.modelos
{
    public class pagamento
    {
        public int ID { get; set; }
        public int Agendamentoid { get; set; }
        public decimal ValorTotal { get; set; }
        public DateTime DataPagamento { get; set; }
    }
}
