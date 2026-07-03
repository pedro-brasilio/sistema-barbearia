using barbearia.modelos;
using Microsoft.EntityFrameworkCore;

namespace barbearia.dados
{
    public class Barbeariacontext : DbContext
    {
        public Barbeariacontext(DbContextOptions<Barbeariacontext> options)
        : base(options)

        {
        }
        public DbSet<Agendamento> Agendamentos { get; set; }

        public DbSet<agendamentoservico> agendamentoservicos { get; set; }

        public DbSet<barbeiro> barbeiros { get; set; }
        
        public DbSet<cliente> clientes { get; set; }

        public DbSet<pagamento> pagamentos { get; set; }

        public DbSet<produto> produtos { get; set; }

        public DbSet<servico> servicos { get; set; }
        }
}



