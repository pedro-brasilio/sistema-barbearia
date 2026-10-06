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

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // O PostgreSQL só aceita DateTime com fuso (UTC) em "timestamp with time zone",
            // que é o padrão do Npgsql. As datas da API chegam sem fuso, então usamos
            // tipos sem fuso: "date" para o dia do agendamento (como no Barbearia.sql).
            modelBuilder.Entity<Agendamento>()
                .Property(a => a.Data)
                .HasColumnType("date");

            modelBuilder.Entity<pagamento>()
                .Property(p => p.DataPagamento)
                .HasColumnType("timestamp without time zone");
        }
        }
}



