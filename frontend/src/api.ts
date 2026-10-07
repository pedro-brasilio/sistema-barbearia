// Em produção (Render) a URL vem de VITE_API_URL, definida no momento do build.
const BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:5039/api';

// Token de login devolvido pela API no login e no cadastro. Fica só na memória,
// como o usuário logado: ao recarregar a página é preciso entrar de novo.
let tokenAtual: string | null = null;

export function definirToken(token: string | null) {
  tokenAtual = token;
}

function cabecalhos(json = false): HeadersInit {
  return {
    ...(json ? { 'Content-Type': 'application/json' } : {}),
    ...(tokenAtual ? { Authorization: `Bearer ${tokenAtual}` } : {}),
  };
}

async function parseResponse(res: Response) {
  const text = await res.text();
  if (!text) return null;
  try {
    return JSON.parse(text);
  } catch {
    return text;
  }
}

// typeof data === 'string' ? data : fallback, com um aviso claro quando o login venceu
function mensagemDeErro(res: Response, data: unknown, fallback: string) {
  if (res.status === 401) return 'Sua sessão expirou. Saia e entre de novo.';
  if (res.status === 403) return 'Você não tem permissão para isso.';
  return typeof data === 'string' && data ? data : fallback;
}

export async function cadastrarCliente(dados: {
  Nome: string;
  Telefone: string;
  Email: string;
  senha: string;
}) {
  const res = await fetch(`${BASE_URL}/Clientecontrolador/cadastro`, {
    method: 'POST',
    headers: cabecalhos(true),
    body: JSON.stringify(dados),
  });
  const data = await parseResponse(res);
  if (!res.ok) throw new Error(typeof data === 'string' ? data : data?.message || 'Erro ao cadastrar.');
  definirToken(data?.token ?? null);
  return data;
}

export async function loginCliente(dados: {
  Email: string;
  senha: string;
}) {
  const res = await fetch(`${BASE_URL}/authcontrolador/login`, {
    method: 'POST',
    headers: cabecalhos(true),
    body: JSON.stringify(dados),
  });
  const data = await parseResponse(res);
  if (!res.ok) throw new Error(typeof data === 'string' ? data : data?.message || 'Email ou senha incorretos.');
  definirToken(data?.token ?? null);
  return data;
}

export async function listarAgendamentos() {
  const res = await fetch(`${BASE_URL}/Agedamentocontrolador`, { headers: cabecalhos() });
  if (!res.ok) throw new Error(mensagemDeErro(res, null, 'Erro ao buscar agendamentos.'));
  return parseResponse(res);
}

export async function listarAgendamentosCliente(clienteId: number) {
  const res = await fetch(`${BASE_URL}/Agedamentocontrolador/cliente/${clienteId}`, { headers: cabecalhos() });
  if (!res.ok) throw new Error(mensagemDeErro(res, null, 'Erro ao buscar agendamentos.'));
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
    headers: cabecalhos(true),
    body: JSON.stringify(dados),
  });
  const data = await parseResponse(res);
  if (!res.ok) throw new Error(mensagemDeErro(res, data, 'Erro ao criar agendamento.'));
  return data;
}

export async function confirmarAgendamento(id: number) {
  const res = await fetch(`${BASE_URL}/Agedamentocontrolador/${id}/confirmar`, {
    method: 'PATCH',
    headers: cabecalhos(),
  });
  const data = await parseResponse(res);
  if (!res.ok) throw new Error(mensagemDeErro(res, data, 'Erro ao confirmar.'));
  return data;
}

export async function deletarAgendamento(id: number) {
  const res = await fetch(`${BASE_URL}/Agedamentocontrolador/${id}`, {
    method: 'DELETE',
    headers: cabecalhos(),
  });
  const data = await parseResponse(res);
  if (!res.ok) throw new Error(mensagemDeErro(res, data, 'Erro ao deletar.'));
  return data;
}

// Serviço como vem da API (ServicosControlador)
export interface Servico {
  id: number;
  nameServico: string;
  preco: number;
  duracaoMinutos: number;
}

export type DadosServico = Omit<Servico, 'id'>;

export async function listarServicos(): Promise<Servico[]> {
  const res = await fetch(`${BASE_URL}/ServicosControlador`);
  if (!res.ok) throw new Error('Erro ao buscar os serviços.');
  return parseResponse(res);
}

// Cadastrar, alterar e remover serviços: só o administrador (aba ADMIN > SERVIÇOS)
function corpoServico(id: number, dados: DadosServico) {
  return JSON.stringify({
    ID: id,
    NameServico: dados.nameServico,
    Preco: dados.preco,
    DuracaoMinutos: dados.duracaoMinutos,
  });
}

export async function criarServico(dados: DadosServico): Promise<Servico> {
  const res = await fetch(`${BASE_URL}/ServicosControlador`, {
    method: 'POST',
    headers: cabecalhos(true),
    body: corpoServico(0, dados),
  });
  const data = await parseResponse(res);
  if (!res.ok) throw new Error(mensagemDeErro(res, data, 'Erro ao cadastrar o serviço.'));
  return data;
}

export async function atualizarServico(id: number, dados: DadosServico): Promise<Servico> {
  const res = await fetch(`${BASE_URL}/ServicosControlador/${id}`, {
    method: 'PUT',
    headers: cabecalhos(true),
    body: corpoServico(id, dados),
  });
  const data = await parseResponse(res);
  if (!res.ok) throw new Error(mensagemDeErro(res, data, 'Erro ao salvar o serviço.'));
  return data;
}

export async function removerServico(id: number) {
  const res = await fetch(`${BASE_URL}/ServicosControlador/${id}`, {
    method: 'DELETE',
    headers: cabecalhos(),
  });
  const data = await parseResponse(res);
  if (!res.ok) throw new Error(mensagemDeErro(res, data, 'Erro ao remover o serviço.'));
  return data;
}

// Notificações push (aba ADMIN): quantos clientes com o app recebem e o envio pelo n8n
export async function contarPublicoNotificacao(filtro: string) {
  const res = await fetch(`${BASE_URL}/Notificacaocontrolador/publico?filtro=${encodeURIComponent(filtro)}`, {
    headers: cabecalhos(),
  });
  const data = await parseResponse(res);
  if (!res.ok) throw new Error(mensagemDeErro(res, data, 'Erro ao contar os clientes.'));
  return data as { total: number };
}

export async function enviarNotificacao(dados: {
  Titulo: string;
  Mensagem: string;
  Filtro: string;
}) {
  const res = await fetch(`${BASE_URL}/Notificacaocontrolador/enviar`, {
    method: 'POST',
    headers: cabecalhos(true),
    body: JSON.stringify(dados),
  });
  const data = await parseResponse(res);
  if (!res.ok) throw new Error(mensagemDeErro(res, data, 'Erro ao enviar a notificação.'));
  return data as { total: number; enviados: number; falhas: number; erro: string };
}
