const BASE_URL = 'http://localhost:5039/api';

async function parseResponse(res: Response) {
  const text = await res.text();
  if (!text) return null;
  try {
    return JSON.parse(text);
  } catch {
    return text;
  }
}

export async function cadastrarCliente(dados: {
  Nome: string;
  Telefone: string;
  Email: string;
  senha: string;
}) {
  const res = await fetch(`${BASE_URL}/Clientecontrolador/cadastro`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(dados),
  });
  const data = await parseResponse(res);
  if (!res.ok) throw new Error(typeof data === 'string' ? data : data?.message || 'Erro ao cadastrar.');
  return data;
}

export async function loginCliente(dados: {
  Email: string;
  senha: string;
}) {
  const res = await fetch(`${BASE_URL}/authcontrolador/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(dados),
  });
  const data = await parseResponse(res);
  if (!res.ok) throw new Error(typeof data === 'string' ? data : data?.message || 'Email ou senha incorretos.');
  return data;
}

export async function listarAgendamentos() {
  const res = await fetch(`${BASE_URL}/Agedamentocontrolador`);
  if (!res.ok) throw new Error('Erro ao buscar agendamentos.');
  return parseResponse(res);
}

export async function listarAgendamentosCliente(clienteId: number) {
  const res = await fetch(`${BASE_URL}/Agedamentocontrolador/cliente/${clienteId}`);
  if (!res.ok) throw new Error('Erro ao buscar agendamentos.');
  return parseResponse(res);
}

export async function criarAgendamento(dados: {
  Clienteid: number;
  Barbeiroid: number;
  Servicos: string;
  Data: string;
  DataHorainicio: string;
  Situacao: string;
}) {
  const res = await fetch(`${BASE_URL}/Agedamentocontrolador`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(dados),
  });
  const data = await parseResponse(res);
  if (!res.ok) throw new Error(typeof data === 'string' ? data : data?.message || 'Erro ao criar agendamento.');
  return data;
}

export async function confirmarAgendamento(id: number) {
  const res = await fetch(`${BASE_URL}/Agedamentocontrolador/${id}/confirmar`, { method: 'PATCH' });
  const data = await parseResponse(res);
  if (!res.ok) throw new Error(typeof data === 'string' ? data : 'Erro ao confirmar.');
  return data;
}

export async function deletarAgendamento(id: number) {
  const res = await fetch(`${BASE_URL}/Agedamentocontrolador/${id}`, { method: 'DELETE' });
  const data = await parseResponse(res);
  if (!res.ok) throw new Error(typeof data === 'string' ? data : 'Erro ao deletar.');
  return data;
}