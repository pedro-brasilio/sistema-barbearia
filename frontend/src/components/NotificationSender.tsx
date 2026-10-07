import { useEffect, useState, type FormEvent } from 'react';
import { motion } from 'framer-motion';
import { Bell, Send, Users } from 'lucide-react';
import { contarPublicoNotificacao, enviarNotificacao } from '../api';

// Mesmos filtros do Notificacaocontrolador da API
const PUBLICOS = [
  { value: 'todos', label: 'Todos os clientes' },
  { value: 'sem_agendamento', label: 'Sem horário agendado' },
  { value: 'com_agendamento', label: 'Com horário agendado' },
  { value: 'nunca_agendou', label: 'Nunca agendaram' },
  { value: 'sumidos', label: 'Sumidos (último horário há mais de 30 dias)' },
];

// Quanto o Android mostra na notificação (a API confere os mesmos limites)
const MAX_TITULO = 65;
const MAX_MENSAGEM = 240;

type Publico = number | 'carregando' | 'erro';

// A API só aceita o administrador (pelo token do login)
export function NotificationSender() {
  const [titulo, setTitulo] = useState('');
  const [mensagem, setMensagem] = useState('');
  const [filtro, setFiltro] = useState('todos');
  const [publico, setPublico] = useState<Publico>('carregando');
  const [enviando, setEnviando] = useState(false);
  const [resultado, setResultado] = useState<{ ok: boolean; texto: string } | null>(null);

  // Mostra quantos clientes recebem a cada troca de filtro
  useEffect(() => {
    let ignorar = false; // descarta a resposta se o filtro mudou de novo
    setPublico('carregando');
    contarPublicoNotificacao(filtro)
      .then((dados) => {
        if (!ignorar) setPublico(dados.total);
      })
      .catch(() => {
        if (!ignorar) setPublico('erro');
      });
    return () => {
      ignorar = true;
    };
  }, [filtro]);

  const handleEnviar = async (e: FormEvent) => {
    e.preventDefault();
    const quem = typeof publico === 'number' ? `${publico} cliente(s)` : 'os clientes do filtro';
    if (!window.confirm(`Enviar "${titulo.trim()}" para ${quem}?`)) return;

    setEnviando(true);
    setResultado(null);
    try {
      const r = await enviarNotificacao({ Titulo: titulo, Mensagem: mensagem, Filtro: filtro });
      if (r.total === 0) {
        setResultado({ ok: false, texto: 'Nenhum cliente com o app se encaixa nesse filtro. Nada foi enviado.' });
      } else if (r.falhas === 0) {
        setResultado({ ok: true, texto: `Notificação enviada para ${r.enviados} celular(es).` });
        setTitulo('');
        setMensagem('');
      } else {
        setResultado({
          ok: r.enviados > 0,
          texto: `Enviada para ${r.enviados} de ${r.total} celular(es). Falhou em ${r.falhas}: ${r.erro}`,
        });
      }
    } catch (err) {
      setResultado({ ok: false, texto: err instanceof Error ? err.message : 'Erro ao enviar a notificação.' });
    } finally {
      setEnviando(false);
    }
  };

  const textoPublico =
    publico === 'carregando'
      ? 'Contando clientes...'
      : publico === 'erro'
        ? 'Não foi possível contar os clientes.'
        : publico === 0
          ? 'Nenhum cliente com o app nesse filtro.'
          : `${publico} cliente(s) com o app vão receber.`;

  return (
    <motion.form
      initial={{ y: 20, opacity: 0 }}
      animate={{ y: 0, opacity: 1 }}
      transition={{ delay: 0.1 }}
      className="admin-filters-card admin-notif-card"
      onSubmit={handleEnviar}
    >
      <h3 className="admin-filters-title">
        <Bell className="admin-filters-icon" />
        ENVIAR NOTIFICAÇÃO
      </h3>
      <p className="admin-notif-hint">
        Avisos e promoções chegam no celular de quem usa o app. Escreva <strong>{'{nome}'}</strong> para
        colocar o primeiro nome do cliente.
      </p>

      <div className="admin-notif-grid">
        <div className="admin-notif-campos">
          <label className="admin-field">
            <span className="admin-field-label">TÍTULO</span>
            <input
              type="text"
              value={titulo}
              onChange={(e) => setTitulo(e.target.value)}
              maxLength={MAX_TITULO}
              placeholder="Promoção de outubro"
              className="admin-input"
              required
            />
            <span className="admin-notif-contador">
              {titulo.length}/{MAX_TITULO}
            </span>
          </label>

          <label className="admin-field">
            <span className="admin-field-label">MENSAGEM</span>
            <textarea
              value={mensagem}
              onChange={(e) => setMensagem(e.target.value)}
              maxLength={MAX_MENSAGEM}
              placeholder="Olá {nome}! Corte + barba com 20% de desconto até sexta."
              className="admin-input admin-textarea"
              rows={4}
              required
            />
            <span className="admin-notif-contador">
              {mensagem.length}/{MAX_MENSAGEM}
            </span>
          </label>
        </div>

        <div className="admin-notif-envio">
          <label className="admin-field">
            <span className="admin-field-label">ENVIAR PARA</span>
            <select value={filtro} onChange={(e) => setFiltro(e.target.value)} className="admin-select">
              {PUBLICOS.map((p) => (
                <option key={p.value} value={p.value}>
                  {p.label}
                </option>
              ))}
            </select>
          </label>

          <div className={`admin-notif-publico ${publico === 0 || publico === 'erro' ? 'vazio' : ''}`}>
            <Users className="admin-row-icon" />
            {textoPublico}
          </div>

          <button
            type="submit"
            className="admin-notif-btn"
            disabled={enviando || publico === 0 || !titulo.trim() || !mensagem.trim()}
          >
            <Send className="admin-notif-btn-icon" />
            {enviando ? 'ENVIANDO...' : 'ENVIAR NOTIFICAÇÃO'}
          </button>

          {resultado && (
            <div className={`admin-notif-msg ${resultado.ok ? 'sucesso' : 'erro'}`}>{resultado.texto}</div>
          )}
        </div>
      </div>
    </motion.form>
  );
}
