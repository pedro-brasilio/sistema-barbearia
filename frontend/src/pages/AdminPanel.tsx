import { useState } from 'react';
import { motion } from 'framer-motion';
import {
  User,
  Phone,
  Calendar,
  Clock,
  Filter,
  Check,
  X,
  Search,
} from 'lucide-react';
import '../styles/admin.css';

interface Appointment {
  id: string;
  clientName: string;
  phone: string;
  service: string;
  date: string;
  time: string;
  status: 'confirmed' | 'pending';
}

interface AdminPanelProps {
  appointments: Appointment[];
  isAdmin: boolean;
  onUpdateStatus: (id: string, status: 'confirmed' | 'pending') => void;
  onDeleteAppointment: (id: string) => void;
}

export function AdminPanel({
  appointments,
  isAdmin,
  onUpdateStatus,
  onDeleteAppointment,
}: AdminPanelProps) {
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [dateFilter, setDateFilter] = useState('');

  const total = appointments.length;
  const today = new Date().toISOString().split('T')[0];
  const todayCount = appointments.filter((a) => a.date === today).length;
  const confirmed = appointments.filter((a) => a.status === 'confirmed').length;
  const pending = appointments.filter((a) => a.status === 'pending').length;

  const filtered = appointments.filter((apt) => {
    const matchSearch =
      apt.clientName.toLowerCase().includes(search.toLowerCase()) ||
      apt.phone.includes(search);
    const matchStatus = statusFilter === 'all' || apt.status === statusFilter;
    const matchDate = !dateFilter || apt.date === dateFilter;
    return matchSearch && matchStatus && matchDate;
  });

  const formatDate = (dateStr: string) => {
    const [year, month, day] = dateStr.split('-');
    const months = [
      'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez',
    ];
    return `${parseInt(day)} de ${months[parseInt(month) - 1]}`;
  };

  const metrics = [
    { value: total,      label: 'TOTAL DE AGENDAMENTOS' },
    { value: todayCount, label: 'AGENDAMENTOS HOJE'     },
    { value: confirmed,  label: 'CONFIRMADOS'           },
    { value: pending,    label: 'PENDENTES'             },
  ];

  return (
    <div className="admin-wrapper">
      <div className="admin-container">

        {/* TÍTULO */}
        <motion.div
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          className="admin-header"
        >
          <h2 className="admin-main-title">PAINEL DE AGENDAMENTOS</h2>
          <div className="admin-main-line" />
        </motion.div>

        {/* MÉTRICAS */}
        <motion.div
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 0.1 }}
          className="admin-metrics"
        >
          {metrics.map((m, i) => (
            <div key={i} className={`admin-metric-card ${i === 1 ? 'highlight' : ''}`}>
              <span className="admin-metric-value">{m.value}</span>
              <span className="admin-metric-label">{m.label}</span>
            </div>
          ))}
        </motion.div>

        {/* FILTROS */}
        <motion.div
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 0.2 }}
          className="admin-filters-card"
        >
          <h3 className="admin-filters-title">
            <Filter className="admin-filters-icon" />
            FILTROS
          </h3>
          <div className="admin-filters-row">
            <div className="admin-search-wrapper">
              <Search className="admin-search-icon" />
              <input
                type="text"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                placeholder="Buscar por nome ou telefone..."
                className="admin-search-input"
              />
            </div>
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="admin-select"
            >
              <option value="all">Todos os Status</option>
              <option value="confirmed">Confirmado</option>
              <option value="pending">Pendente</option>
            </select>
            <input
              type="date"
              value={dateFilter}
              onChange={(e) => setDateFilter(e.target.value)}
              className="admin-date-input"
            />
          </div>
        </motion.div>

        {/* TABELA */}
        <motion.div
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 0.3 }}
          className="admin-table-card"
        >
          <table className="admin-table">
            <thead>
              <tr className="admin-table-head">
                <th className="admin-th">CLIENTE</th>
                <th className="admin-th">TELEFONE</th>
                <th className="admin-th">SERVIÇO</th>
                <th className="admin-th">DATA</th>
                <th className="admin-th">HORÁRIO</th>
                <th className="admin-th">STATUS</th>
                {isAdmin && <th className="admin-th admin-th-actions">AÇÕES</th>}
              </tr>
            </thead>
            <tbody>
              {filtered.length > 0 ? (
                filtered.map((apt) => (
                  <tr key={apt.id} className="admin-table-row">
                    <td className="admin-td">
                      <div className="admin-cell-icon-row">
                        <User className="admin-row-icon" />
                        {apt.clientName}
                      </div>
                    </td>
                    <td className="admin-td">
                      <div className="admin-cell-icon-row">
                        <Phone className="admin-row-icon" />
                        {apt.phone}
                      </div>
                    </td>
                    <td className="admin-td">{apt.service}</td>
                    <td className="admin-td">
                      <div className="admin-cell-icon-row">
                        <Calendar className="admin-row-icon" />
                        {formatDate(apt.date)}
                      </div>
                    </td>
                    <td className="admin-td">
                      <div className="admin-cell-icon-row">
                        <Clock className="admin-row-icon" />
                        {apt.time}
                      </div>
                    </td>
                    <td className="admin-td">
                      <span className={`admin-status-badge ${apt.status}`}>
                        {apt.status === 'confirmed' ? 'CONFIRMADO' : 'PENDENTE'}
                      </span>
                    </td>
                    {isAdmin && (
                      <td className="admin-td admin-td-actions">
                        {apt.status === 'pending' ? (
                          <button
                            onClick={() => onUpdateStatus(apt.id, 'confirmed')}
                            className="admin-action-btn confirm"
                            title="Confirmar"
                          >
                            <Check className="admin-action-icon" />
                          </button>
                        ) : (
                          <button
                            onClick={() => onDeleteAppointment(apt.id)}
                            className="admin-action-btn delete"
                            title="Remover"
                          >
                            <X className="admin-action-icon" />
                          </button>
                        )}
                      </td>
                    )}
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan={isAdmin ? 7 : 6} className="admin-empty">
                    Nenhum agendamento encontrado
                  </td>
                </tr>
              )}
            </tbody>
          </table>

          <div className="admin-table-footer">
            Exibindo {filtered.length} de {total} agendamentos
          </div>
        </motion.div>

      </div>
    </div>
  );
}