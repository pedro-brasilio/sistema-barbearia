import { useCallback, useEffect, useState } from "react";
import {
  listarAgendamentos,
  listarAgendamentosCliente,
  confirmarAgendamento,
  deletarAgendamento,
  listarServicos,
  definirToken,
  type Servico,
} from "./api";
import { useHoje } from "./utils";
import { Header } from "./components/Header";
import { Home } from "./components/Home";
import { Login } from "./pages/Login";
import { BookingForm } from "./pages/BookingForm";
import { AdminPanel } from "./pages/AdminPanel";
import { Perfil } from "./pages/Perfil";
import "./styles/menu.css";
import "./styles/home.css";
import "./styles/login.css";
import "./styles/booking.css";
import "./styles/admin.css";
import "./styles/perfil.css";

interface Appointment {
  id: string;
  clientName: string;
  phone: string;
  service: string;
  date: string;
  time: string;
  status: "confirmed" | "pending";
}

interface User {
  id: number;
  name: string;
  email: string;
  telefone: string;
  isAdmin: boolean;
}

// Agendamento como vem da API
interface AgendamentoApi {
  id: number;
  servicos: string;
  data: string;           // "2026-11-10T00:00:00"
  dataHorainicio: string; // "09:00:00"
  situacao: string;       // "pendente" | "confirmado" | "cancelado"
  clienteNome?: string;   // só na lista completa (admin)
  clienteTelefone?: string;
}

function toAppointment(a: AgendamentoApi, user: User): Appointment {
  return {
    id: String(a.id),
    clientName: a.clienteNome ?? user.name,
    phone: a.clienteTelefone ?? user.telefone,
    service: a.servicos,
    date: a.data.slice(0, 10),
    time: a.dataHorainicio.slice(0, 5),
    status: a.situacao === "confirmado" ? "confirmed" : "pending",
  };
}

export default function App() {
  const [view, setView] = useState("home");
  const [user, setUser] = useState<User | null>(null);
  const [appointments, setAppointments] = useState<Appointment[]>([]);
  const [servicos, setServicos] = useState<Servico[] | null>(null); // null = carregando
  const hoje = useHoje();

  // Busca os agendamentos no banco: todos para o admin, só os do cliente para os demais
  const buscarAgendamentos = useCallback(async (): Promise<Appointment[]> => {
    if (!user) return [];
    const dados: AgendamentoApi[] = user.isAdmin
      ? await listarAgendamentos()
      : await listarAgendamentosCliente(user.id);
    return dados
      .filter((a) => a.situacao !== "cancelado")
      .map((a) => toAppointment(a, user));
  }, [user]);

  const carregarAgendamentos = useCallback(() => {
    buscarAgendamentos().then(setAppointments).catch(console.error);
  }, [buscarAgendamentos]);

  // Serviços do banco (o admin altera na aba ADMIN > SERVIÇOS)
  const carregarServicos = useCallback(() => {
    listarServicos()
      .then(setServicos)
      .catch((err) => {
        console.error(err);
        setServicos((atual) => atual ?? []);
      });
  }, []);

  useEffect(() => {
    carregarServicos();
  }, [carregarServicos, view]);

  // Recarrega ao entrar, a cada troca de tela e na virada do dia, para mostrar
  // também agendamentos feitos pelo app ou em outro navegador
  useEffect(() => {
    let ignorar = false; // descarta a resposta se o usuário já trocou de tela ou saiu
    buscarAgendamentos()
      .then((lista) => {
        if (!ignorar) setAppointments(lista);
      })
      .catch(console.error);
    return () => {
      ignorar = true;
    };
  }, [buscarAgendamentos, view, hoje]);

  const handleNavigate = (target: string) => {
    if (target === "login" && user) {
      setView("perfil");
      return;
    }
    setView(target);
  };

  const handleUpdateStatus = async (id: string, status: "confirmed" | "pending") => {
    if (status !== "confirmed") return; // a API só permite confirmar
    try {
      await confirmarAgendamento(Number(id));
    } catch (err) {
      alert(err instanceof Error ? err.message : "Erro ao confirmar.");
    }
    carregarAgendamentos();
  };

  const handleDeleteAppointment = async (id: string) => {
    try {
      await deletarAgendamento(Number(id));
    } catch (err) {
      alert(err instanceof Error ? err.message : "Erro ao deletar.");
    }
    carregarAgendamentos();
  };

  const handleLogout = () => {
    definirToken(null);
    setUser(null);
    setAppointments([]);
    setView("home");
  };

  return (
    <div>
      <Header currentView={view} onNavigate={handleNavigate} user={user} />
      <main>
        {view === "home" && (
          <Home servicos={servicos} onNavigateToBooking={() => setView("booking")} />
        )}

        {view === "login" && (
          <Login
            onNavigateBack={() => setView("home")}
            onLoginSuccess={(userData) => {
              setUser(userData);
              setView("home");
            }}
          />
        )}

        {view === "booking" && (
  <BookingForm
    user={user}
    appointments={appointments}
    servicos={servicos}
    hoje={hoje}
    onAddAppointment={carregarAgendamentos}
    onNavigateToLogin={() => setView("login")}
  />
)}
      
        {view === "admin" && (
  <AdminPanel
    appointments={appointments}
    isAdmin={user?.isAdmin ?? false}
    hoje={hoje}
    servicos={servicos}
    onServicosAlterados={carregarServicos}
    onUpdateStatus={handleUpdateStatus}
    onDeleteAppointment={handleDeleteAppointment}
  />
)}

        {view === "perfil" && user && (
          <Perfil
            user={user}
            appointments={appointments}
            hoje={hoje}
            onNavigateBack={() => setView("home")}
            onLogout={handleLogout}
            onCancelAppointment={handleDeleteAppointment}
          />
        )}
      </main>
    </div>
  );
}