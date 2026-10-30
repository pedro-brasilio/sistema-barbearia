using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace barbearia.Migrations
{
    /// <inheritdoc />
    public partial class AgendaSemanal : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "agenda_semanal",
                columns: table => new
                {
                    agendamento_id = table.Column<int>(type: "integer", nullable: false),
                    inicio_semana = table.Column<DateTime>(type: "date", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_agenda_semanal", x => x.agendamento_id);
                    table.ForeignKey(
                        name: "FK_agenda_semanal_Agendamentos_agendamento_id",
                        column: x => x.agendamento_id,
                        principalTable: "Agendamentos",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_agenda_semanal_inicio_semana",
                table: "agenda_semanal",
                column: "inicio_semana");

            migrationBuilder.Sql("""
                CREATE OR REPLACE PROCEDURE public.sp_atualizar_agenda_semanal(
                    p_agendamento_id integer DEFAULT NULL)
                LANGUAGE plpgsql
                AS $procedure$
                BEGIN
                    -- A reconciliação completa é manutenção: impede escritas concorrentes
                    -- até terminar, para não classificar uma data que acabou de mudar.
                    IF p_agendamento_id IS NULL THEN
                        LOCK TABLE public."Agendamentos" IN SHARE ROW EXCLUSIVE MODE;
                    ELSE
                        -- A chamada manual por ID também serializa com remarcações.
                        -- No gatilho, a própria escrita já detém esse bloqueio.
                        PERFORM 1
                        FROM public."Agendamentos"
                        WHERE id = p_agendamento_id
                        FOR UPDATE;
                    END IF;

                    -- Uma linha por agendamento, sem duplicar dados do atendimento.
                    -- NULL reconcilia toda a agenda, inclusive para a carga inicial.
                    DELETE FROM public.agenda_semanal AS semana
                    WHERE (p_agendamento_id IS NULL OR semana.agendamento_id = p_agendamento_id)
                      AND NOT EXISTS (
                          SELECT 1
                          FROM public."Agendamentos" AS agendamento
                          WHERE agendamento.id = semana.agendamento_id
                            AND agendamento."Situacao" <> 'cancelado'
                      );

                    INSERT INTO public.agenda_semanal (agendamento_id, inicio_semana)
                    SELECT agendamento.id,
                           agendamento."Data" -
                               (EXTRACT(ISODOW FROM agendamento."Data")::integer - 1)
                    FROM public."Agendamentos" AS agendamento
                    WHERE (p_agendamento_id IS NULL OR agendamento.id = p_agendamento_id)
                      AND agendamento."Situacao" <> 'cancelado'
                    ON CONFLICT (agendamento_id) DO UPDATE
                    SET inicio_semana = EXCLUDED.inicio_semana;
                END;
                $procedure$;

                CREATE OR REPLACE FUNCTION public.fn_sincronizar_agenda_semanal()
                RETURNS trigger
                LANGUAGE plpgsql
                AS $trigger$
                BEGIN
                    CALL public.sp_atualizar_agenda_semanal(NEW.id);
                    RETURN NEW;
                END;
                $trigger$;

                CREATE TRIGGER trg_agendamentos_agenda_semanal
                AFTER INSERT OR UPDATE OF "Data", "Situacao"
                ON public."Agendamentos"
                FOR EACH ROW
                EXECUTE FUNCTION public.fn_sincronizar_agenda_semanal();

                -- Inclui também os agendamentos anteriores à instalação do gatilho.
                CALL public.sp_atualizar_agenda_semanal();
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("""
                DROP TRIGGER IF EXISTS trg_agendamentos_agenda_semanal ON public."Agendamentos";
                DROP FUNCTION IF EXISTS public.fn_sincronizar_agenda_semanal();
                DROP PROCEDURE IF EXISTS public.sp_atualizar_agenda_semanal(integer);
                """);

            migrationBuilder.DropTable(
                name: "agenda_semanal");
        }
    }
}
