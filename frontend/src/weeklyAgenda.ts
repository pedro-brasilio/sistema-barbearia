// Datas civis: o cálculo em UTC evita mudanças de dia por horário de verão.
export function deslocarDia(data: string, dias: number): string {
  const [ano, mes, dia] = data.split('-').map(Number);
  const valor = new Date(Date.UTC(ano, mes - 1, dia + dias));
  return valor.toISOString().slice(0, 10);
}

export function inicioDaSemana(data: string): string {
  const [ano, mes, dia] = data.split('-').map(Number);
  const diaDaSemana = new Date(Date.UTC(ano, mes - 1, dia)).getUTCDay();
  return deslocarDia(data, -((diaDaSemana + 6) % 7));
}

export function formatarDia(data: string): string {
  const [ano, mes, dia] = data.split('-');
  return `${dia}/${mes}/${ano}`;
}
