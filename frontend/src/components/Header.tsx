import { Scissors, House, Calendar, User, LayoutGrid } from "lucide-react";
 
interface HeaderProps {
  currentView: string;
  onNavigate: (view: string) => void;
  user: { id: number; name: string; email: string; telefone: string; isAdmin: boolean } | null;
}
 
export function Header({ currentView, onNavigate, user }: HeaderProps) {
  return (
    <header className="header">
      <div className="header-bg" />
      <div className="header-container">
        <div className="header-inner">
 
          <button onClick={() => onNavigate("home")} className="logo">
            <div className="logo-icon-wrapper">
              <Scissors className="logo-icon" />
            </div>
            <div>
              <h1 className="logo-title">BARBERSHOP</h1>
              <p className="logo-subtitle">ESTILO & TRADIÇÃO</p>
            </div>
          </button>
 
          <nav className="nav">
            <button
              onClick={() => onNavigate("home")}
              className={`nav-btn ${currentView === "home" ? "active" : ""}`}
            >
              <House size={16} className="nav-icon-mobile" />
              <span className="nav-label">INÍCIO</span>
            </button>

            <button
              onClick={() => onNavigate("booking")}
              className={`nav-btn ${currentView === "booking" ? "active" : ""}`}
            >
              <Calendar size={16} />
              <span className="nav-label">AGENDAR</span>
            </button>
 
            {/* LOGIN vira nome do usuário após login */}
            <button
              onClick={() => onNavigate("login")}
              className={`nav-btn login-btn-header ${
                currentView === "login" || currentView === "perfil" ? "active" : ""
              }`}
            >
              <User size={16} />
              <span className="nav-label">
                {user ? user.name.split(" ")[0].toUpperCase() : "LOGIN"}
              </span>
            </button>
 
            {/* ADMIN só aparece se for admin */}
            {user?.isAdmin && (
              <button
                onClick={() => onNavigate("admin")}
                className={`nav-btn ${currentView === "admin" ? "active" : ""}`}
              >
                <LayoutGrid size={16} />
                <span className="nav-label">ADMIN</span>
              </button>
            )}
          </nav>
 
        </div>
      </div>
    </header>
  );
}