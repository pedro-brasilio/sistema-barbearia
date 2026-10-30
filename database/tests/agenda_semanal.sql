-- Executar em banco de testes isolado após aplicar as migrations.
-- Os registros de teste usam IDs negativos e toda a execução termina em ROLLBACK.
-- Exemplo: psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f database/tests/agenda_semanal.sql
\set ON_ERROR_STOP on

BEGIN;

DO $test$
BEGIN
    IF EXISTS (SELECT 1 FROM public."Agendamentos" WHERE id BETWEEN -910099 AND -910001) THEN
        RAISE EXCEPTION 'Os IDs reservados para os testes já estão em uso.';
    END IF;
END;
$test$;

INSERT INTO public."Agendamentos"
    (id, "Clienteid", "Barbeiroid", "Servicos", "Data", "Situacao", "DataHorainicio")
VALUES
    (-910001, 1, 1, 'Teste: criação',       DATE '2026-10-30', 'pendente',   TIME '09:00'),
    (-910002, 1, 1, 'Teste: domingo',       DATE '2026-12-27', 'confirmado', TIME '09:00'),
    (-910003, 1, 1, 'Teste: segunda-feira', DATE '2026-12-28', 'pendente',   TIME '09:00'),
    (-910004, 1, 1, 'Teste: virada de ano', DATE '2027-01-03', 'pendente',   TIME '09:00'),
    (-910005, 1, 1, 'Teste: nova semana',   DATE '2027-01-04', 'pendente',   TIME '09:00'),
    (-910006, 1, 1, 'Teste: cancelado',     DATE '2026-10-30', 'cancelado',  TIME '09:00');

DO $test$
BEGIN
    IF (SELECT count(*) FROM public.agenda_semanal WHERE agendamento_id BETWEEN -910006 AND -910001) <> 5 THEN
        RAISE EXCEPTION 'INSERT: cinco agendamentos ativos deveriam entrar na agenda.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM public.agenda_semanal WHERE agendamento_id = -910001 AND inicio_semana = DATE '2026-10-26') THEN
        RAISE EXCEPTION 'INSERT: o agendamento não foi classificado na segunda-feira correta.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM public.agenda_semanal WHERE agendamento_id = -910002 AND inicio_semana = DATE '2026-12-21') THEN
        RAISE EXCEPTION 'Domingo deve pertencer à semana iniciada na segunda anterior.';
    END IF;
    IF (SELECT count(*) FROM public.agenda_semanal WHERE agendamento_id IN (-910003, -910004) AND inicio_semana = DATE '2026-12-28') <> 2 THEN
        RAISE EXCEPTION 'Segunda e domingo da virada de ano devem pertencer à mesma semana ISO.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM public.agenda_semanal WHERE agendamento_id = -910005 AND inicio_semana = DATE '2027-01-04') THEN
        RAISE EXCEPTION 'A segunda-feira seguinte deve iniciar uma nova semana.';
    END IF;
    IF EXISTS (SELECT 1 FROM public.agenda_semanal WHERE agendamento_id = -910006) THEN
        RAISE EXCEPTION 'Um agendamento criado como cancelado não pode entrar na agenda.';
    END IF;
    RAISE NOTICE 'PASS: INSERT, situação cancelada, domingo/segunda e virada de ano';
END;
$test$;

UPDATE public."Agendamentos" SET "Data" = DATE '2027-01-04' WHERE id = -910001;
UPDATE public."Agendamentos" SET "Situacao" = 'confirmado' WHERE id = -910001;

DO $test$
BEGIN
    IF (SELECT count(*) FROM public.agenda_semanal WHERE agendamento_id = -910001) <> 1 OR
       NOT EXISTS (SELECT 1 FROM public.agenda_semanal WHERE agendamento_id = -910001 AND inicio_semana = DATE '2027-01-04') THEN
        RAISE EXCEPTION 'UPDATE: remarcação/confirmação deve mover a semana sem duplicar a entrada.';
    END IF;
    RAISE NOTICE 'PASS: remarcação e confirmação sem duplicação';
END;
$test$;

UPDATE public."Agendamentos" SET "Situacao" = 'cancelado' WHERE id = -910001;
DO $test$
BEGIN
    IF EXISTS (SELECT 1 FROM public.agenda_semanal WHERE agendamento_id = -910001) THEN
        RAISE EXCEPTION 'UPDATE: o cancelamento deve remover a entrada da agenda.';
    END IF;
    RAISE NOTICE 'PASS: cancelamento retira o agendamento da agenda';
END;
$test$;

UPDATE public."Agendamentos" SET "Situacao" = 'pendente' WHERE id = -910001;
DO $test$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.agenda_semanal WHERE agendamento_id = -910001 AND inicio_semana = DATE '2027-01-04') THEN
        RAISE EXCEPTION 'UPDATE: a reativação deve restaurar o agendamento na semana correta.';
    END IF;
    RAISE NOTICE 'PASS: reativação recoloca o agendamento';
END;
$test$;

DELETE FROM public."Agendamentos" WHERE id = -910001;
DO $test$
BEGIN
    IF EXISTS (SELECT 1 FROM public.agenda_semanal WHERE agendamento_id = -910001) THEN
        RAISE EXCEPTION 'DELETE: a FK deveria remover a entrada em cascata.';
    END IF;
    RAISE NOTICE 'PASS: exclusão em cascata';
END;
$test$;

CALL public.sp_atualizar_agenda_semanal(-910003);
CALL public.sp_atualizar_agenda_semanal(-910003);
DELETE FROM public.agenda_semanal WHERE agendamento_id = -910003;
CALL public.sp_atualizar_agenda_semanal();
CALL public.sp_atualizar_agenda_semanal();

DO $test$
BEGIN
    IF (SELECT count(*) FROM public.agenda_semanal WHERE agendamento_id = -910003) <> 1 THEN
        RAISE EXCEPTION 'Procedure: reconciliação deve restaurar exatamente uma entrada.';
    END IF;
    IF EXISTS (SELECT 1 FROM public.agenda_semanal WHERE agendamento_id IN (-910001, -910006)) THEN
        RAISE EXCEPTION 'Procedure: não pode recriar agendamentos excluídos ou cancelados.';
    END IF;
    RAISE NOTICE 'PASS: chamadas repetidas e reconciliação idempotente';
END;
$test$;

-- Simula registros anteriores ao gatilho para validar a reconciliação da carga inicial.
ALTER TABLE public."Agendamentos" DISABLE TRIGGER trg_agendamentos_agenda_semanal;
INSERT INTO public."Agendamentos"
    (id, "Clienteid", "Barbeiroid", "Servicos", "Data", "Situacao", "DataHorainicio")
VALUES
    (-910007, 1, 1, 'Teste: registro anterior ativo', DATE '2026-11-01', 'pendente', TIME '10:00'),
    (-910008, 1, 1, 'Teste: registro anterior cancelado', DATE '2026-11-01', 'cancelado', TIME '11:00');
ALTER TABLE public."Agendamentos" ENABLE TRIGGER trg_agendamentos_agenda_semanal;
CALL public.sp_atualizar_agenda_semanal();

DO $test$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.agenda_semanal WHERE agendamento_id = -910007 AND inicio_semana = DATE '2026-10-26') OR
       EXISTS (SELECT 1 FROM public.agenda_semanal WHERE agendamento_id = -910008) THEN
        RAISE EXCEPTION 'Carga inicial: incluir ativos anteriores e excluir cancelados.';
    END IF;
    RAISE NOTICE 'PASS: reconciliação dos registros anteriores ao gatilho';
END;
$test$;

SAVEPOINT antes_agendamento;
INSERT INTO public."Agendamentos"
    (id, "Clienteid", "Barbeiroid", "Servicos", "Data", "Situacao", "DataHorainicio")
VALUES (-910009, 1, 1, 'Teste: rollback', DATE '2026-10-30', 'pendente', TIME '13:00');
DO $test$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.agenda_semanal WHERE agendamento_id = -910009) THEN
        RAISE EXCEPTION 'Rollback: o gatilho deveria executar antes do retorno do INSERT.';
    END IF;
END;
$test$;
ROLLBACK TO SAVEPOINT antes_agendamento;
DO $test$
BEGIN
    IF EXISTS (SELECT 1 FROM public."Agendamentos" WHERE id = -910009) OR
       EXISTS (SELECT 1 FROM public.agenda_semanal WHERE agendamento_id = -910009) THEN
        RAISE EXCEPTION 'Rollback: origem e agenda precisam ser revertidas atomicamente.';
    END IF;
    RAISE NOTICE 'PASS: rollback atômico do agendamento e da agenda';
END;
$test$;

DO $test$
BEGIN
    BEGIN
        INSERT INTO public.agenda_semanal (agendamento_id, inicio_semana)
        VALUES (-910099, DATE '2026-10-26');
        RAISE EXCEPTION 'FK: uma entrada sem agendamento deveria ser recusada.';
    EXCEPTION WHEN foreign_key_violation THEN
        RAISE NOTICE 'PASS: FK impede entrada órfã';
    END;
END;
$test$;

ROLLBACK;

DO $test$
BEGIN
    IF EXISTS (SELECT 1 FROM public."Agendamentos" WHERE id BETWEEN -910099 AND -910001) OR
       EXISTS (SELECT 1 FROM public.agenda_semanal WHERE agendamento_id BETWEEN -910099 AND -910001) THEN
        RAISE EXCEPTION 'Limpeza: os testes não podem deixar registros persistidos.';
    END IF;
    RAISE NOTICE 'PASS: todos os testes concluídos sem deixar registros';
END;
$test$;
