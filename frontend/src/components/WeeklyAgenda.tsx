import { useEffect, useState } from 'react';
import { ArrowLeft, ArrowRight, Check, RefreshCw, X } from 'lucide-react';
import { listarAgendaSemanal, type AgendaSemanalApi } from '../api';
import { deslocarDia, formatarDia, inicioDaSemana } from '../weeklyAgenda';

interface WeeklyAgendaProps {
  hoje: string;
  revision: unknown;
  onUpdateStatus: (id: string, status: 'confirmed' | 'pending') => Promise<void>;
  onDeleteAppointment: (id: string) => Promise<void>;
}

export function WeeklyAgenda({ hoje, revision, onUpdateStatus, onDeleteAppointment }: WeeklyAgendaProps) {
  const [data, setData] = useState(() => inicioDaSemana(hoje));
  const [agenda, setAgenda] = useState<AgendaSemanalApi | null>(null);
  const [carregando, setCarregando] = useState(true);
  const [erro, setErro] = useState('');
  const [refresh, setRefresh] = useState(0);
  const [ocupado, setOcupado] = useState<string | null>(null);

  useEffect(() => {
    let ignorar = false;
    listarAgendaSemanal(data)
      .then((resposta) => {
        if (!ignorar) { setAgenda(resposta); setErro(''); }
      })
      .catch((error: unknown) => {
        if (!ignorar) { setAgenda(null); setErro(error instanceof Error ? error.message : 'Erro ao carregar a agenda.'); }
      })
      .finally(() => { if (!ignorar) setCarregando(false); });
    return () => { ignorar = true; };
  }, [data, revision, refresh]);

  function carregar(novaData: string) {
    setCarregando(true);
    setAgenda(null);
    setErro('');
    setData(inicioDaSemana(novaData));
    setRefresh((valor) => valor + 1);
  }

  async function executar(id: string, confirmar: boolean) {
    setOcupado(id);
    setErro('');
    try {
      if (confirmar) await onUpdateStatus(id, 'confirmed');
      else await onDeleteAppointment(id);
      setRefresh((valor) => valor + 1);
    } catch (error) {
      setErro(error instanceof Error ? error.message : 'Não foi possível alterar o agendamento.');
    } finally { setOcupado(null); }
  }

  const inicio = agenda?.inicioSemana ?? inicioDaSemana(data);
  const fim = agenda?.fimSemana ?? deslocarDia(inicio, 6);
  return <section aria-label="Agenda semanal">
    <div className="admin-filters-card">
      <div className="weekly-agenda-controls">
        <button type="button" className="admin-tab" aria-label="Semana anterior" onClick={() => carregar(deslocarDia(data, -7))}><ArrowLeft size={18} /> ANTERIOR</button>
        <label className="weekly-agenda-date">SEMANA DE
          <input type="date" value={data} onChange={(e) => { if (e.target.value) carregar(e.target.value); }} className="admin-date-input" />
        </label>
        <button type="button" className="admin-tab" aria-label="Próxima semana" onClick={() => carregar(deslocarDia(data, 7))}>PRÓXIMA <ArrowRight size={18} /></button>
        <button type="button" className="admin-tab" aria-label="Atualizar agenda semanal" onClick={() => carregar(data)}><RefreshCw size={18} /> ATUALIZAR</button>
      </div>
      <p className="weekly-agenda-period">{formatarDia(inicio)} a {formatarDia(fim)} · segunda-feira a domingo</p>
    </div>
    {erro && <p className="weekly-agenda-error" role="alert">{erro}</p>}
    {carregando ? <p className="admin-empty" role="status">Carregando agenda semanal...</p> : agenda && <div className="admin-table-card">
      <table className="admin-table">
        <thead><tr className="admin-table-head"><th className="admin-th">DATA / HORÁRIO</th><th className="admin-th">CLIENTE</th><th className="admin-th">SERVIÇO</th><th className="admin-th">STATUS</th><th className="admin-th">AÇÕES</th></tr></thead>
        <tbody>{agenda.agendamentos.length === 0 ? <tr><td colSpan={5} className="admin-empty">Nenhum agendamento nesta semana.</td></tr> : agenda.agendamentos.map((item) => <tr key={item.id} className="admin-table-row">
          <td className="admin-td">{formatarDia(item.data.slice(0, 10))}<br />{item.dataHorainicio.slice(0, 5)}</td>
          <td className="admin-td">{item.clienteNome}<br /><small>{item.clienteTelefone}</small></td>
          <td className="admin-td">{item.servicos}</td>
          <td className="admin-td"><span className={`admin-status-badge ${item.situacao === 'confirmado' ? 'confirmed' : 'pending'}`}>{item.situacao === 'confirmado' ? 'CONFIRMADO' : 'PENDENTE'}</span></td>
          <td className="admin-td admin-td-actions">
            {item.situacao !== 'confirmado' && <button type="button" disabled={ocupado !== null} className="admin-action-btn confirm" aria-label={`Confirmar agendamento de ${item.clienteNome}`} onClick={() => void executar(String(item.id), true)}><Check size={16} /></button>}
            <button type="button" disabled={ocupado !== null} className="admin-action-btn delete" aria-label={`Remover agendamento de ${item.clienteNome}`} onClick={() => void executar(String(item.id), false)}><X size={16} /></button>
          </td>
        </tr>)}</tbody>
      </table>
      <div className="admin-table-footer">{agenda.agendamentos.length} agendamento(s) na semana</div>
    </div>}
  </section>;
}
