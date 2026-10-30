\set ON_ERROR_STOP on
INSERT INTO public."Agendamentos"
    (id, "Clienteid", "Barbeiroid", "Servicos", "Data", "Situacao", "DataHorainicio")
VALUES
    (-920001, 1, 1, 'Agendamento anterior ativo', DATE '2026-11-01', 'pendente', TIME '09:00'),
    (-920002, 1, 1, 'Agendamento anterior cancelado', DATE '2026-11-01', 'cancelado', TIME '10:00');
