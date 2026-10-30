\set ON_ERROR_STOP on
DO $test$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.agenda_semanal WHERE agendamento_id = -920001 AND inicio_semana = DATE '2026-10-26') THEN
        RAISE EXCEPTION 'Backfill real: o agendamento anterior ativo não foi classificado.';
    END IF;
    IF EXISTS (SELECT 1 FROM public.agenda_semanal WHERE agendamento_id = -920002) THEN
        RAISE EXCEPTION 'Backfill real: um agendamento anterior cancelado entrou na agenda.';
    END IF;
    IF (SELECT count(*) FROM public."Agendamentos" WHERE id IN (-920001, -920002)) <> 2 THEN
        RAISE EXCEPTION 'A atualização não pode apagar os agendamentos anteriores.';
    END IF;
    RAISE NOTICE 'PASS: migration inclui registros anteriores ativos e preserva os cancelados na origem';
END;
$test$;
