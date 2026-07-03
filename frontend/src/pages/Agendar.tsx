import { useState } from "react";
import { motion } from "framer-motion";
import {
  Calendar,
  Clock,
  User,
  Check,
} from "lucide-react";

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
  appointments: Appointment[];
  onAddAppointment: (
    appointment: Omit<Appointment, "id" | "status">
  ) => void;
}

export function BookingForm({
  appointments,
  onAddAppointment,
}: BookingFormProps) {
  const [formData, setFormData] = useState({
    clientName: "",
    phone: "",
    service: "",
    date: "",
    time: "",
  });

  const [showSuccess, setShowSuccess] = useState(false);

  const services = [
    { name: "Corte Clássico", price: "R$ 45" },
    { name: "Corte + Barba", price: "R$ 70" },
    { name: "Barba Tradicional", price: "R$ 35" },
    { name: "Corte Premium", price: "R$ 80" },
  ];

  const timeSlots = [
    "09:00",
    "09:30",
    "10:00",
    "10:30",
    "11:00",
    "11:30",
    "14:00",
    "14:30",
    "15:00",
    "15:30",
    "16:00",
    "16:30",
    "17:00",
    "17:30",
    "18:00",
    "18:30",
    "19:00",
  ];

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    if (
      !formData.clientName ||
      !formData.phone ||
      !formData.service ||
      !formData.date ||
      !formData.time
    ) {
      return;
    }

    onAddAppointment(formData);

    setFormData({
      clientName: "",
      phone: "",
      service: "",
      date: "",
      time: "",
    });

    setShowSuccess(true);

    setTimeout(() => {
      setShowSuccess(false);
    }, 3000);
  };

  const userAppointments = appointments.filter(
    (apt) =>
      apt.clientName
        .toLowerCase()
        .includes(formData.clientName.toLowerCase()) &&
      formData.clientName.length > 2
  );

  return (
    <div className="booking-wrapper">
      <div className="booking-container">

        {/* TITLE */}
        <motion.div
          initial={{ opacity: 0, y: 25 }}
          animate={{ opacity: 1, y: 0 }}
          className="booking-title-wrapper"
        >
          <h2 className="booking-title">
            AGENDE SEU HORÁRIO
          </h2>

          <div className="booking-line" />
        </motion.div>

        <div className="booking-grid">

          {/* LEFT */}
          <motion.div
            initial={{ opacity: 0, x: -25 }}
            animate={{ opacity: 1, x: 0 }}
          >
            <form onSubmit={handleSubmit} className="booking-form">

              {/* DADOS */}
              <div className="booking-card">
                <h3 className="booking-card-title">
                  <User size={18} />
                  DADOS PESSOAIS
                </h3>

                <div className="booking-input-grid">

                  <div>
                    <label>NOME COMPLETO</label>

                    <input
                      type="text"
                      placeholder="Digite seu nome"
                      value={formData.clientName}
                      onChange={(e) =>
                        setFormData({
                          ...formData,
                          clientName: e.target.value,
                        })
                      }
                    />
                  </div>

                  <div>
                    <label>TELEFONE</label>

                    <input
                      type="tel"
                      placeholder="(00) 00000-0000"
                      value={formData.phone}
                      onChange={(e) =>
                        setFormData({
                          ...formData,
                          phone: e.target.value,
                        })
                      }
                    />
                  </div>

                </div>
              </div>

              {/* SERVIÇOS */}
              <div className="booking-card">
                <h3 className="booking-card-title">
                  SERVIÇO
                </h3>

                <div className="service-grid">
                  {services.map((service) => (
                    <button
                      type="button"
                      key={service.name}
                      onClick={() =>
                        setFormData({
                          ...formData,
                          service: service.name,
                        })
                      }
                      className={`service-btn ${
                        formData.service === service.name
                          ? "active"
                          : ""
                      }`}
                    >
                      <span>{service.name}</span>

                      <strong>{service.price}</strong>
                    </button>
                  ))}
                </div>
              </div>

              {/* DATA */}
              <div className="booking-card">
                <h3 className="booking-card-title">
                  <Calendar size={18} />
                  DATA E HORÁRIO
                </h3>

                <div className="date-area">

                  <label>DATA</label>

                  <input
                    type="date"
                    value={formData.date}
                    min={
                      new Date()
                        .toISOString()
                        .split("T")[0]
                    }
                    onChange={(e) =>
                      setFormData({
                        ...formData,
                        date: e.target.value,
                      })
                    }
                  />

                </div>

                <div className="time-wrapper">

                  <div className="time-label">
                    <Clock size={15} />
                    HORÁRIO DISPONÍVEL
                  </div>

                  <div className="time-grid">
                    {timeSlots.map((time) => (
                      <button
                        type="button"
                        key={time}
                        onClick={() =>
                          setFormData({
                            ...formData,
                            time,
                          })
                        }
                        className={`time-btn ${
                          formData.time === time
                            ? "active"
                            : ""
                        }`}
                      >
                        {time}
                      </button>
                    ))}
                  </div>

                </div>
              </div>

              {/* BTN */}
              <button
                type="submit"
                className="confirm-btn"
              >
                <Check size={18} />
                CONFIRMAR AGENDAMENTO
              </button>

            </form>

            {showSuccess && (
              <motion.div
                initial={{ opacity: 0, y: 15 }}
                animate={{ opacity: 1, y: 0 }}
                className="success-message"
              >
                ✓ Agendamento realizado com sucesso!
              </motion.div>
            )}
          </motion.div>

          {/* SIDEBAR */}
          <motion.div
            initial={{ opacity: 0, x: 25 }}
            animate={{ opacity: 1, x: 0 }}
          >
            <div className="appointments-card">

              <h3 className="appointments-title">
                MEUS AGENDAMENTOS
              </h3>

              {userAppointments.length > 0 ? (
                <div className="appointments-list">
                  {userAppointments.map((apt) => (
                    <div
                      key={apt.id}
                      className="appointment-item"
                    >
                      <div className="appointment-top">
                        <span className="appointment-service">
                          {apt.service}
                        </span>

                        <span className="appointment-status">
                          CONFIRMADO
                        </span>
                      </div>

                      <div className="appointment-info">
                        <div>
                          <Calendar size={13} />
                          {new Date(
                            apt.date
                          ).toLocaleDateString("pt-BR")}
                        </div>

                        <div>
                          <Clock size={13} />
                          {apt.time}
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              ) : (
                <p className="empty-text">
                  {formData.clientName.length > 2
                    ? "Nenhum agendamento encontrado"
                    : "Logue para ver os seus agendamentos"}
                </p>
              )}

            </div>
          </motion.div>

        </div>
      </div>
    </div>
  );
}