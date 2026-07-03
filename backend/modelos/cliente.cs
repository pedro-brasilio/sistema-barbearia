namespace barbearia.modelos
{
    public class cliente
    {
        public int id { get; set; }
        public string Nome { get; set; }
        public string Telefone { get; set; }
        public string Email { get; set; }
        public string senha { get; set; }    

        public bool IsAdmin { get; set; } = false;    
    }

    
}