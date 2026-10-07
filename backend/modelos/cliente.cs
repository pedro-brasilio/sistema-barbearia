using System.Text.Json.Serialization;

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

        // Token do Firebase (FCM) do celular onde o cliente entrou pelo app.
        // Fica fora do JSON da API: só o n8n precisa dele, pelo Notificacaocontrolador.
        [JsonIgnore]
        public string? TokenPush { get; set; }
    }

    
}