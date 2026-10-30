\set ON_ERROR_STOP on
DO $test$
BEGIN
    IF to_regclass('public.agenda_semanal') IS NOT NULL OR
       to_regprocedure('public.sp_atualizar_agenda_semanal(integer)') IS NOT NULL OR
       to_regprocedure('public.fn_sincronizar_agenda_semanal()') IS NOT NULL THEN
        RAISE EXCEPTION 'Downgrade deve remover a tabela e as rotinas da agenda.';
    END IF;
    IF (SELECT count(*) FROM public."Agendamentos" WHERE id IN (-920001, -920002)) <> 2 THEN
        RAISE EXCEPTION 'Downgrade não pode apagar os agendamentos originais.';
    END IF;
    RAISE NOTICE 'PASS: downgrade remove a agenda e preserva os agendamentos';
END;
$test$;
