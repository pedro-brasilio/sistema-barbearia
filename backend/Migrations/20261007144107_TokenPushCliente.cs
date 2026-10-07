using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace barbearia.Migrations
{
    /// <inheritdoc />
    public partial class TokenPushCliente : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "TokenPush",
                table: "clientes",
                type: "text",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "TokenPush",
                table: "clientes");
        }
    }
}
