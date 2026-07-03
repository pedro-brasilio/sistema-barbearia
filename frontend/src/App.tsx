import { useState } from "react";
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

export default function App() {
  const [view, setView] = useState("home");
  const [user, setUser] = useState<User | null>(null);
  const [appointments, setAppointments] = useState<Appointment[]>([]);

  const handleNavigate = (target: string) => {
    if (target === "login" && user) {
      setView("perfil");
      return;
    }
    setView(target);
  };

  const handleAddAppointment = (
    appointment: Omit<Appointment, "id" | "status">
  ) => {
    const newAppointment: Appointment = {
      ...appointment,
      id: crypto.randomUUID(),
      status: "pending",
    };
    setAppointments((prev) => [...prev, newAppointment]);
  };

  const handleUpdateStatus = (id: string, status: "confirmed" | "pending") => {
    setAppointments((prev) =>
      prev.map((apt) => (apt.id === id ? { ...apt, status } : apt))
    );
  };

  const handleDeleteAppointment = (id: string) => {
    setAppointments((prev) => prev.filter((apt) => apt.id !== id));
  };

  const handleLogout = () => {
    setUser(null);
    setView("home");
  };

  return (
    <div>
      <Header currentView={view} onNavigate={handleNavigate} user={user} />
      <main>
        {view === "home" && (
          <Home onNavigateToBooking={() => setView("booking")} />
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
    onAddAppointment={handleAddAppointment}
    onNavigateToLogin={() => setView("login")}
  />
)}
      
        {view === "admin" && (
  <AdminPanel
    appointments={appointments}
    isAdmin={user?.isAdmin ?? false}
    onUpdateStatus={handleUpdateStatus}
    onDeleteAppointment={handleDeleteAppointment}
  />
)}

        {view === "perfil" && user && (
          <Perfil
            user={user}
            appointments={appointments}
            onNavigateBack={() => setView("home")}
            onLogout={handleLogout}
            onCancelAppointment={handleDeleteAppointment}
          />
        )}
      </main>
    </div>
  );
}