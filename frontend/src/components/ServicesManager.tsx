import { useRef, useState, type FormEvent } from 'react';
import { motion } from 'framer-motion';
import { Clock, Pencil, Plus, Save, Scissors, Trash2, X } from 'lucide-react';
import { atualizarServico, criarServico, removerServico, type Servico } from '../api';
import { formatarPreco } from '../utils';

interface ServicesManagerProps {
  servicos: Servico[] | null; // null = carregando
  onAlterado: () => void; // recarrega a lista do banco
}

const FORM_VAZIO = { nome: '', preco: '', duracao: '30' };

// Aba SERVIÇOS do painel: cadastra, altera e remove os serviços no banco.
// O início e o agendamento (site e app) leem a mesma lista.
// A API só aceita o administrador (pelo token do login).
export function ServicesManager({ servicos, onAlterado }: ServicesManagerProps) {
  const [editando, setEditando] = useState<Servico | null>(null);
  const [form, setForm] = useState(FORM_VAZIO);
  const [salvando, setSalvando] = useState(false);
  const [mensagem, setMensagem] = useState<{ ok: boolean; texto: string } | null>(null);
  const formRef = useRef<HTMLFormElement>(null);

  const editar = (servico: Servico) => {
    setEditando(servico);
    setForm({
      nome: servico.nameServico,
      preco: String(servico.preco),
      duracao: String(servico.duracaoMinutos),
    });
    setMensagem(null);
    // No celular o formulário fica acima da lista
    formRef.current?.scrollIntoView({ behavior: 'smooth', block: 'start' });
  };

  const cancelarEdicao = () => {
    setEditando(null);
    setForm(FORM_VAZIO);
    setMensagem(null);
  };

  const handleSalvar = async (e: FormEvent) => {
    e.preventDefault();
    const dados = {
      nameServico: form.nome.trim(),
      preco: Number(form.preco.replace(',', '.')),
      duracaoMinutos: Number(form.duracao),
    };

    setSalvando(true);
    setMensagem(null);
    try {
      if (editando) {
        await atualizarServico(editando.id, dados);
        setMensagem({ ok: true, texto: `"${dados.nameServico}" foi atualizado.` });
      } else {
        await criarServico(dados);
        setMensagem({ ok: true, texto: `"${dados.nameServico}" foi adicionado.` });
      }
      setEditando(null);
      setForm(FORM_VAZIO);
      onAlterado();
    } catch (err) {
      setMensagem({ ok: false, texto: err instanceof Error ? err.message : 'Erro ao salvar o serviço.' });
    } finally {
      setSalvando(false);
    }
  };

  const handleRemover = async (servico: Servico) => {
    if (!window.confirm(`Remover "${servico.nameServico}"? Os agendamentos já feitos continuam com esse nome.`)) {
      return;
    }
    setMensagem(null);
    try {
      await removerServico(servico.id);
      if (editando?.id === servico.id) {
        setEditando(null);
        setForm(FORM_VAZIO);
      }
      setMensagem({ ok: true, texto: `"${servico.nameServico}" foi removido.` });
      onAlterado();
    } catch (err) {
      setMensagem({ ok: false, texto: err instanceof Error ? err.message : 'Erro ao remover o serviço.' });
    }
  };

  return (
    <div className="admin-servicos">
      {/* FORMULÁRIO */}
      <motion.form
        ref={formRef}
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.1 }}
        className="admin-filters-card admin-servico-form"
        onSubmit={handleSalvar}
      >
        <h3 className="admin-filters-title">
          {editando ? <Pencil className="admin-filters-icon" /> : <Plus className="admin-filters-icon" />}
          {editando ? 'EDITAR SERVIÇO' : 'NOVO SERVIÇO'}
        </h3>

        <div className="admin-notif-campos">
          <label className="admin-field">
            <span className="admin-field-label">NOME</span>
            <input
              type="text"
              value={form.nome}
              onChange={(e) => setForm({ ...form, nome: e.target.value })}
              maxLength={40}
              placeholder="Ex.: Pigmentação de barba"
              className="admin-input"
              required
            />
          </label>

          <div className="admin-servico-numeros">
            <label className="admin-field">
              <span className="admin-field-label">PREÇO (R$)</span>
              <input
                type="number"
                value={form.preco}
                onChange={(e) => setForm({ ...form, preco: e.target.value })}
                min="0.01"
                max="10000"
                step="0.01"
                placeholder="45"
                className="admin-input"
                required
              />
            </label>
            <label className="admin-field">
              <span className="admin-field-label">DURAÇÃO (MIN)</span>
              <input
                type="number"
                value={form.duracao}
                onChange={(e) => setForm({ ...form, duracao: e.target.value })}
                min="5"
                max="480"
                step="5"
                className="admin-input"
                required
              />
            </label>
          </div>

          <button type="submit" className="admin-notif-btn" disabled={salvando}>
            {editando ? <Save className="admin-notif-btn-icon" /> : <Plus className="admin-notif-btn-icon" />}
            {salvando ? 'SALVANDO...' : editando ? 'SALVAR ALTERAÇÕES' : 'ADICIONAR SERVIÇO'}
          </button>

          {editando && (
            <button type="button" className="admin-servico-cancelar" onClick={cancelarEdicao}>
              <X className="admin-action-icon" />
              CANCELAR EDIÇÃO
            </button>
          )}

          {mensagem && <div className={`admin-notif-msg ${mensagem.ok ? 'sucesso' : 'erro'}`}>{mensagem.texto}</div>}
        </div>
      </motion.form>

      {/* LISTA */}
      <motion.div
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.2 }}
        className="admin-table-card admin-servico-lista"
      >
        <h3 className="admin-filters-title admin-servico-lista-titulo">
          <Scissors className="admin-filters-icon" />
          SERVIÇOS OFERECIDOS
        </h3>

        {servicos === null ? (
          <p className="admin-empty">Carregando serviços...</p>
        ) : servicos.length === 0 ? (
          <p className="admin-empty">Nenhum serviço cadastrado.</p>
        ) : (
          servicos.map((servico) => (
            <div
              key={servico.id}
              className={`admin-servico-item ${editando?.id === servico.id ? 'editando' : ''}`}
            >
              <div className="admin-servico-info">
                <span className="admin-servico-nome">{servico.nameServico}</span>
                <span className="admin-servico-detalhes">
                  <span className="admin-servico-preco">{formatarPreco(servico.preco)}</span>
                  <span className="admin-cell-icon-row">
                    <Clock className="admin-row-icon" />
                    {servico.duracaoMinutos} min
                  </span>
                </span>
              </div>
              <div className="admin-servico-acoes">
                <button
                  type="button"
                  className="admin-action-btn confirm"
                  title="Editar"
                  onClick={() => editar(servico)}
                >
                  <Pencil className="admin-action-icon" />
                </button>
                <button
                  type="button"
                  className="admin-action-btn delete"
                  title="Remover"
                  onClick={() => handleRemover(servico)}
                >
                  <Trash2 className="admin-action-icon" />
                </button>
              </div>
            </div>
          ))
        )}

        <div className="admin-table-footer">As mudanças aparecem na hora no início e no agendamento, no site e no app.</div>
      </motion.div>
    </div>
  );
}
