import { useState } from "react";
import { motion } from "framer-motion";
import { Calendar, Clock, User, Check, LogIn } from "lucide-react";
import { criarAgendamento } from "../api";
import "../styles/booking.css";

interface Appointment {
  id: string;
  clientName: string;
  phone: string;
  service: string;
  date: string;
  time: string;
  status: "confirmed" | "pending";
}

interface BookingFormProps {
  user: { id: number; name: string; email: string; telefone: string; isAdmin: boolean } | null;
  appointments: Appointment[];
  onAddAppointment: (appointment: Omit<Appointment, "id" | "status">) => void;
  onNavigateToLogin: () => void;
}

export function BookingForm({
  user,
  appointments,
  onAddAppointment,
  onNavigateToLogin,
}: BookingFormProps) {

  const [formData, setFormData] = useState({
    service: "",
    date: "",
    time: "",
  });

  const [showSuccess, setShowSuccess] = useState(false);
  const [erro, setErro] = useState("");
  const [loading, setLoading] = useState(false);

  const services = [
    { name: "Corte Clássico", price: "R$ 45" },
    { name: "Corte + Barba", price: "R$ 70" },
    { name: "Barba Tradicional", price: "R$ 35" },
    { name: "Corte Premium", price: "R$ 80" },
  ];

  const timeSlots = [
    "09:00", "09:30",
    "10:00", "10:30",
    "11:00", "11:30",
    "14:00", "14:30",
    "15:00", "15:30",
    "16:00", "16:30",
    "17:00", "17:30",
    "18:00", "18:30",
    "19:00",
  ];

  const handleSubmit = async (e: React.FormEvent) => {
  e.preventDefault();
  if (!user) return;

  setErro("");

  if (!formData.service) {
    setErro("Selecione um serviço.");
    return;
  }
  if (!formData.date) {
    setErro("Selecione uma data.");
    return;
  }
  if (!formData.time) {
    setErro("Selecione um horário.");
    return;
  }

  setLoading(true);

  try {
    await criarAgendamento({
      Clienteid: user.id,
      Barbeiroid: 1,
      Servicos: formData.service,
      Data: formData.date,
      DataHorainicio: formData.time,
      Situacao: "pendente",
    });

    onAddAppointment({
      clientName: user.name,
      phone: user.telefone,
      service: formData.service,
      date: formData.date,
      time: formData.time,
    });

    setFormData({ service: "", date: "", time: "" });
    setShowSuccess(true);
    setTimeout(() => setShowSuccess(false), 3000);

  } catch (err: any) {
    setErro(err.message || "Erro ao realizar agendamento.");
  } finally {
    setLoading(false);
  }
};
  // Agendamentos do usuário logado
  const userAppointments = user
    ? appointments.filter(
        (apt) => apt.clientName.toLowerCase() === user.name.toLowerCase()
      )
    : [];

  return (
    <div className="booking-wrapper">
      <div className="booking-container">

        {/* HEADER */}
        <motion.div
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          className="booking-header"
        >
          <h2 className="booking-main-title">AGENDE SEU HORÁRIO</h2>
          <div className="booking-main-line" />
        </motion.div>

        {/* GRID */}
        <div className="booking-grid">

          {/* FORM */}
          <motion.div
            initial={{ x: -30, opacity: 0 }}
            animate={{ x: 0, opacity: 1 }}
            transition={{ delay: 0.2 }}
            className="booking-form-side"
          >
            {/* BLOQUEIO SE NÃO LOGADO */}
            {!user ? (
              <div className="booking-card booking-locked">
                <div className="booking-locked-content">
                  <LogIn size={48} className="booking-locked-icon" />
                  <h3 className="booking-locked-title">FAÇA LOGIN PARA AGENDAR</h3>
                  <p className="booking-locked-text">
                    Você precisa estar logado para realizar um agendamento.
                  </p>
                  <button
                    onClick={onNavigateToLogin}
                    className="booking-confirm-btn"
                    style={{ width: "auto", padding: "0 40px" }}
                  >
                    <LogIn size={18} />
                    IR PARA O LOGIN
                  </button>
                </div>
              </div>
            ) : (
              <form onSubmit={handleSubmit} className="booking-form">

                {/* CARD 1 — DADOS DO USUÁRIO LOGADO */}
                <div className="booking-card">
                  <h3 className="booking-card-title">
                    <User className="booking-title-icon" />
                    DADOS PESSOAIS
                  </h3>
                  <div className="booking-input-grid">
                    <div>
                      <label className="booking-label">NOME COMPLETO</label>
                      <input
                        type="text"
                        value={user.name}
                        className="booking-input booking-input-readonly"
                        readOnly
                      />
                    </div>
                    <div>
                      <label className="booking-label">TELEFONE</label>
                      <input
                        type="tel"
                        value={user.telefone}
                        className="booking-input booking-input-readonly"
                        readOnly
                      />
                    </div>
                  </div>
                </div>

                {/* CARD 2 — SERVIÇO */}
                <div className="booking-card">
                  <h3 className="booking-card-title">SERVIÇO</h3>
                  <div className="booking-services-grid">
                    {services.map((service) => (
                      <button
                        key={service.name}
                        type="button"
                        onClick={() => setFormData({ ...formData, service: service.name })}
                        className={`booking-service-btn ${formData.service === service.name ? "selected" : ""}`}
                      >
                        <div className="booking-service-content">
                          <span className={`booking-service-name ${formData.service === service.name ? "selected" : ""}`}>
                            {service.name}
                          </span>
                          <span className={`booking-service-price ${formData.service === service.name ? "selected" : ""}`}>
                            {service.price}
                          </span>
                        </div>
                      </button>
                    ))}
                  </div>
                </div>

                {/* CARD 3 — DATA E HORÁRIO */}
                <div className="booking-card">
                  <h3 className="booking-card-title">
                    <Calendar className="booking-title-icon" />
                    DATA E HORÁRIO
                  </h3>
                  <div className="booking-date-grid">
                    <div>
                      <label className="booking-label">DATA</label>
                      <input
                        type="date"
                        value={formData.date}
                        min={new Date().toISOString().split("T")[0]}
                        onChange={(e) => setFormData({ ...formData, date: e.target.value })}
                        className="booking-input"
                        required
                      />
                    </div>
                  </div>

                  <div className="booking-time-section">
                    <label className="booking-label booking-time-title">
                      <Clock className="booking-small-icon" />
                      HORÁRIO DISPONÍVEL
                    </label>
                    <div className="booking-times-grid">
                      {timeSlots.map((time) => (
                        <button
                          key={time}
                          type="button"
                          onClick={() => setFormData({ ...formData, time })}
                          className={`booking-time-btn ${formData.time === time ? "selected" : ""}`}
                        >
                          {time}
                        </button>
                      ))}
                    </div>
                  </div>
                </div>

                {/* ERRO */}
                {erro && <div className="booking-error">{erro}</div>}

                {/* BOTÃO */}
                <button
                  type="submit"
                  className="booking-confirm-btn"
                  disabled={loading}
                >
                  <Check className="booking-confirm-icon" />
                  {loading ? "AGUARDE..." : "CONFIRMAR AGENDAMENTO"}
                </button>

              </form>
            )}

            {/* SUCESSO */}
            {showSuccess && (
              <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                className="booking-success"
              >
                ✓ Agendamento realizado com sucesso!
              </motion.div>
            )}
          </motion.div>

          {/* SIDEBAR */}
          <motion.div
            initial={{ x: 30, opacity: 0 }}
            animate={{ x: 0, opacity: 1 }}
            transition={{ delay: 0.3 }}
            className="booking-sidebar"
          >
            <div className="booking-sidebar-card">
              <h3 className="booking-sidebar-title">MEUS AGENDAMENTOS</h3>

              <div className="booking-sidebar-list">
                {!user ? (
                  <p className="booking-empty-text">
                    Faça login para ver seus agendamentos.
                  </p>
                ) : userAppointments.length > 0 ? (
                  userAppointments.map((apt) => (
                    <div key={apt.id} className="appointment-card">
                      <div className="appointment-header">
                        <span className="appointment-service">{apt.service}</span>
                        <span className={`appointment-status ${apt.status}`}>
                          {apt.status === "confirmed" ? "CONFIRMADO" : "PENDENTE"}
                        </span>
                      </div>
                      <div className="appointment-details">
                        <div className="appointment-detail-row">
                          <Calendar className="appointment-icon" />
                          {new Date(apt.date).toLocaleDateString("pt-BR")}
                        </div>
                        <div className="appointment-detail-row">
                          <Clock className="appointment-icon" />
                          {apt.time}
                        </div>
                      </div>
                    </div>
                  ))
                ) : (
                  <p className="booking-empty-text">
                    Nenhum agendamento encontrado.
                  </p>
                )}
              </div>
            </div>
          </motion.div>

        </div>
      </div>
    </div>
  );
}