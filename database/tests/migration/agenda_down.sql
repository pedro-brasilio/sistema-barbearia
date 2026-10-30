START TRANSACTION;
DROP TRIGGER IF EXISTS trg_agendamentos_agenda_semanal ON public."Agendamentos";
DROP FUNCTION IF EXISTS public.fn_sincronizar_agenda_semanal();
DROP PROCEDURE IF EXISTS public.sp_atualizar_agenda_semanal(integer);

DROP TABLE agenda_semanal;

DELETE FROM "__EFMigrationsHistory"
WHERE "MigrationId" = '20261030183451_AgendaSemanal';

COMMIT;
