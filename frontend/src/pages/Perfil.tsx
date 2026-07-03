import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  User, Mail, Phone, Lock, Save, LogOut,
  ArrowLeft, Eye, EyeOff, Calendar, Clock,
  X, CheckCircle, AlertCircle, ChevronDown, ChevronUp
} from "lucide-react";
import "../styles/perfil.css";

interface Appointment {
  id: string;
  clientName: string;
  phone: string;
  service: string;
  date: string;
  time: string;
  status: "confirmed" | "pending";
}

interface PerfilProps {
  user: { id: number; name: string; email: string; telefone: string; isAdmin: boolean };
  appointments: Appointment[];
  onNavigateBack: () => void;
  onLogout: () => void;
  onCancelAppointment: (id: string) => void;
}

export function Perfil({
  user,
  appointments,
  onNavigateBack,
  onLogout,
  onCancelAppointment,
}: PerfilProps) {
  const [showPersonalInfo, setShowPersonalInfo] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [showNewPassword, setShowNewPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [erro, setErro] = useState("");
  const [sucesso, setSucesso] = useState("");

  const [formData, setFormData] = useState({
  nome: user.name,
  email: user.email,
  telefone: user.telefone,
  currentPassword: "",
  newPassword: "",
  confirmPassword: "",
});

  const today = new Date().toISOString().split("T")[0];

  const proximosAgendamentos = appointments.filter(
    (a) => a.clientName.toLowerCase() === user.name.toLowerCase() && a.date >= today
  );

  const historicoAgendamentos = appointments.filter(
    (a) => a.clientName.toLowerCase() === user.name.toLowerCase() && a.date < today
  );

  const formatDate = (dateStr: string) => {
    const [year, month, day] = dateStr.split("-").map(Number);
    const date = new Date(year, month - 1, day);
    return date.toLocaleDateString("pt-BR", {
      weekday: "long",
      day: "numeric",
      month: "long",
      year: "numeric",
    });
  };

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    setErro("");
    setSucesso("");

    if (formData.newPassword) {
      if (!formData.currentPassword) {
        setErro("Digite sua senha atual para confirmar a alteração.");
        return;
      }
      if (formData.newPassword !== formData.confirmPassword) {
        setErro("As novas senhas não coincidem.");
        return;
      }
    }

    setSucesso("Informações atualizadas com sucesso!");
    setTimeout(() => setSucesso(""), 3000);
  };

  return (
    <div className="perfil-wrapper">
      <div className="perfil-container">

        {/* VOLTAR */}
        <button onClick={onNavigateBack} className="perfil-back">
          <ArrowLeft size={15} />
          VOLTAR
        </button>

        {/* TÍTULO */}
        <div className="perfil-header">
          <h2 className="perfil-title">MEU PERFIL</h2>
          <div className="perfil-line" />
        </div>

        {/* CARD DO USUÁRIO */}
        <div className="perfil-user-card">
          <div className="perfil-user-info">
            <div className="perfil-avatar">
              <User size={48} strokeWidth={1.5} />
            </div>
            <div className="perfil-user-details">
              <h3 className="perfil-user-name">{user.name}</h3>
              <div className="perfil-user-meta">
                <span className="perfil-meta-row">
                  <Mail size={14} />
                  {formData.email || "email@exemplo.com"}
                </span>
                <span className="perfil-meta-row">
                  <Phone size={14} />
                  {formData.telefone || "(00) 00000-0000"}
                </span>
              </div>
            </div>
          </div>
          <button onClick={onLogout} className="perfil-logout-btn">
            <LogOut size={16} />
            SAIR
          </button>
        </div>

        {/* INFORMAÇÕES PESSOAIS */}
        <div className="perfil-section-card">
          <button
            className="perfil-section-toggle"
            onClick={() => setShowPersonalInfo(!showPersonalInfo)}
          >
            <span className="perfil-section-toggle-left">
              <User size={18} className="perfil-section-icon" />
              INFORMAÇÕES PESSOAIS
            </span>
            {showPersonalInfo ? <ChevronUp size={20} /> : <ChevronDown size={20} />}
          </button>

          <AnimatePresence>
            {showPersonalInfo && (
              <motion.div
                initial={{ height: 0, opacity: 0 }}
                animate={{ height: "auto", opacity: 1 }}
                exit={{ height: 0, opacity: 0 }}
                transition={{ duration: 0.3 }}
                className="perfil-section-body"
              >
                {erro && <div className="perfil-error">{erro}</div>}
                {sucesso && <div className="perfil-success">{sucesso}</div>}

                <form onSubmit={handleSave} className="perfil-form">
                  <div className="perfil-form-grid">

                    {/* Nome */}
                    <div className="perfil-field">
                      <label>NOME COMPLETO</label>
                      <div className="perfil-input-box">
                        <User className="perfil-input-icon" size={16} />
                        <input
                          type="text"
                          value={formData.nome}
                          onChange={(e) => setFormData({ ...formData, nome: e.target.value })}
                          placeholder="Seu nome"
                        />
                      </div>
                    </div>

                    {/* Email */}
                    <div className="perfil-field">
                      <label>E-MAIL</label>
                      <div className="perfil-input-box">
                        <Mail className="perfil-input-icon" size={16} />
                        <input
                          type="email"
                          value={formData.email}
                          onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                          placeholder="seu@email.com"
                        />
                      </div>
                    </div>

                    {/* Telefone */}
                    <div className="perfil-field">
                      <label>TELEFONE</label>
                      <div className="perfil-input-box">
                        <Phone className="perfil-input-icon" size={16} />
                        <input
                          type="tel"
                          value={formData.telefone}
                          onChange={(e) => setFormData({ ...formData, telefone: e.target.value })}
                          placeholder="(11) 99999-9999"
                        />
                      </div>
                    </div>

                  </div>

                  {/* SENHAS */}
                  <div className="perfil-password-section">
                    <p className="perfil-password-label">ALTERAR SENHA</p>
                    <div className="perfil-form-grid">

                      {/* Senha Atual */}
                      <div className="perfil-field">
                        <label>SENHA ATUAL</label>
                        <div className="perfil-input-box">
                          <Lock className="perfil-input-icon" size={16} />
                          <input
                            type={showPassword ? "text" : "password"}
                            value={formData.currentPassword}
                            onChange={(e) => setFormData({ ...formData, currentPassword: e.target.value })}
                            placeholder="••••••••"
                          />
                          <button type="button" className="perfil-eye" onClick={() => setShowPassword(!showPassword)}>
                            {showPassword ? <EyeOff size={14} /> : <Eye size={14} />}
                          </button>
                        </div>
                      </div>

                      {/* Nova Senha */}
                      <div className="perfil-field">
                        <label>NOVA SENHA</label>
                        <div className="perfil-input-box">
                          <Lock className="perfil-input-icon" size={16} />
                          <input
                            type={showNewPassword ? "text" : "password"}
                            value={formData.newPassword}
                            onChange={(e) => setFormData({ ...formData, newPassword: e.target.value })}
                            placeholder="••••••••"
                          />
                          <button type="button" className="perfil-eye" onClick={() => setShowNewPassword(!showNewPassword)}>
                            {showNewPassword ? <EyeOff size={14} /> : <Eye size={14} />}
                          </button>
                        </div>
                      </div>

                      {/* Confirmar Nova Senha */}
                      <div className="perfil-field">
                        <label>CONFIRMAR NOVA SENHA</label>
                        <div className="perfil-input-box">
                          <Lock className="perfil-input-icon" size={16} />
                          <input
                            type={showConfirmPassword ? "text" : "password"}
                            value={formData.confirmPassword}
                            onChange={(e) => setFormData({ ...formData, confirmPassword: e.target.value })}
                            placeholder="••••••••"
                          />
                          <button type="button" className="perfil-eye" onClick={() => setShowConfirmPassword(!showConfirmPassword)}>
                            {showConfirmPassword ? <EyeOff size={14} /> : <Eye size={14} />}
                          </button>
                        </div>
                      </div>

                    </div>
                  </div>

                  <button type="submit" className="perfil-save-btn">
                    <Save size={16} />
                    SALVAR ALTERAÇÕES
                  </button>
                </form>
              </motion.div>
            )}
          </AnimatePresence>
        </div>

        {/* MEUS AGENDAMENTOS */}
        <div className="perfil-section-card">
          <div className="perfil-appointments-header">
            <Calendar size={18} className="perfil-section-icon" />
            MEUS AGENDAMENTOS
          </div>

          {/* PRÓXIMOS */}
          <div className="perfil-appointments-group">
            <div className="perfil-group-title">
              <CheckCircle size={14} />
              PRÓXIMOS
            </div>

            {proximosAgendamentos.length > 0 ? (
              proximosAgendamentos.map((apt) => (
                <div key={apt.id} className="perfil-apt-card">
                  <div className="perfil-apt-info">
                    <span className="perfil-apt-service">{apt.service}</span>
                    <div className="perfil-apt-details">
                      <span><Calendar size={12} /> {formatDate(apt.date)}</span>
                      <span><Clock size={12} /> {apt.time}</span>
                    </div>
                  </div>
                  <div className="perfil-apt-actions">
                    <span className={`perfil-apt-status ${apt.status}`}>
                      {apt.status === "confirmed" ? "CONFIRMADO" : "PENDENTE"}
                    </span>
                    <button
                      onClick={() => onCancelAppointment(apt.id)}
                      className="perfil-cancel-btn"
                    >
                      <X size={14} />
                      CANCELAR
                    </button>
                  </div>
                </div>
              ))
            ) : (
              <p className="perfil-empty">Nenhum agendamento próximo.</p>
            )}
          </div>

          {/* HISTÓRICO */}
          <div className="perfil-appointments-group">
            <div className="perfil-group-title">
              <AlertCircle size={14} />
              HISTÓRICO
            </div>

            {historicoAgendamentos.length > 0 ? (
              historicoAgendamentos.map((apt) => (
                <div key={apt.id} className="perfil-apt-card historico">
                  <div className="perfil-apt-info">
                    <span className="perfil-apt-service">{apt.service}</span>
                    <div className="perfil-apt-details">
                      <span><Calendar size={12} /> {formatDate(apt.date)}</span>
                      <span><Clock size={12} /> {apt.time}</span>
                    </div>
                  </div>
                  <span className={`perfil-apt-status ${apt.status}`}>
                    {apt.status === "confirmed" ? "CONCLUÍDO" : "CANCELADO"}
                  </span>
                </div>
              ))
            ) : (
              <p className="perfil-empty">Nenhum agendamento no histórico.</p>
            )}
          </div>
        </div>

      </div>
    </div>
  );
}