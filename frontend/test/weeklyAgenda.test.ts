import test from 'node:test';
import assert from 'node:assert/strict';
import { deslocarDia, inicioDaSemana } from '../src/weeklyAgenda.ts';

test('a semana ISO começa na segunda e inclui o domingo da virada do ano', () => {
  assert.equal(inicioDaSemana('2027-01-03'), '2026-12-28');
  assert.equal(inicioDaSemana('2027-01-04'), '2027-01-04');
  assert.equal(deslocarDia('2026-12-28', 6), '2027-01-03');
});

test('navegação semanal atravessa mês, ano e dia bissexto sem mudar o dia', () => {
  assert.equal(deslocarDia('2026-12-28', 7), '2027-01-04');
  assert.equal(deslocarDia('2027-01-04', -7), '2026-12-28');
  assert.equal(inicioDaSemana('2024-02-29'), '2024-02-26');
  assert.equal(deslocarDia('2024-02-26', 6), '2024-03-03');
});
