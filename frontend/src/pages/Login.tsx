import { useState } from "react";
import { motion } from "framer-motion";
import { User, Lock, Mail, ArrowLeft, Phone, Eye, EyeOff } from "lucide-react";
import { loginCliente, cadastrarCliente } from "../api";
import "../styles/login.css";

interface LoginProps {
  onNavigateBack: () => void;
  onLoginSuccess: (user: { id: number; name: string; email: string; telefone: string; isAdmin: boolean }) => void;
}

export function Login({ onNavigateBack, onLoginSuccess }: LoginProps) {
  const [isLoginMode, setIsLoginMode] = useState(true);
  const [loading, setLoading] = useState(false);
  const [erro, setErro] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);

  const [formData, setFormData] = useState({
    email: "",
    password: "",
    confirmPassword: "",
    name: "",
    phone: "",
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setErro("");

    if (!isLoginMode && formData.password !== formData.confirmPassword) {
      setErro("As senhas não coincidem.");
      return;
    }

    setLoading(true);

    try {
      if (isLoginMode) {
        const user = await loginCliente({
          Email: formData.email,
          senha: formData.password,
        });

        onLoginSuccess({
          id: user.id ?? user.Id,
          name: user.Nome ?? user.nome ?? formData.email.split('@')[0],
          email: user.Email ?? user.email ?? formData.email,
          telefone: user.Telefone ?? user.telefone ?? "",
          isAdmin: user.IsAdmin ?? user.isAdmin ?? false,
        });

      } else {
        const user = await cadastrarCliente({
          Nome: formData.name,
          Telefone: formData.phone,
          Email: formData.email,
          senha: formData.password,
        });

        onLoginSuccess({
          id: user?.id ?? user?.Id ?? 0,
          name: user?.Nome ?? user?.nome ?? formData.name,
          email: user?.Email ?? user?.email ?? formData.email,
          telefone: user?.Telefone ?? user?.telefone ?? formData.phone,
          isAdmin: user?.IsAdmin ?? user?.isAdmin ?? false,
        });
      }

    } catch (err: any) {
      setErro(err.message || "Algo deu errado. Tente novamente.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="login-page">
      <div className="login-container">

        {/* LEFT */}
        <motion.div
          initial={{ x: -40, opacity: 0 }}
          animate={{ x: 0, opacity: 1 }}
          transition={{ duration: 0.7 }}
          className="login-left"
        >
          <div className="login-left-content">
            <h2 className="login-big-title">
              BEM <br />
              <span>VINDO</span>
            </h2>
            <p className="login-description">
              Entre na sua conta para agendar horários,
              ver seu histórico e aproveitar benefícios exclusivos.
            </p>
            <div className="login-visual">
              <div className="login-visual-bg" />
              <div className="login-visual-card">
                <User size={82} strokeWidth={1.5} />
              </div>
            </div>
          </div>
        </motion.div>

        {/* RIGHT */}
        <motion.div
          initial={{ x: 40, opacity: 0 }}
          animate={{ x: 0, opacity: 1 }}
          transition={{ duration: 0.7, delay: 0.15 }}
          className="login-right"
        >
          <div className="login-card">

            <button onClick={onNavigateBack} className="login-back">
              <ArrowLeft size={15} />
              VOLTAR
            </button>

            <div className="login-header">
              <h3 className="login-title">
                {isLoginMode ? "LOGIN" : "CADASTRO"}
              </h3>
              <div className="login-line" />
            </div>

            {erro && <div className="login-error">{erro}</div>}

            <form onSubmit={handleSubmit} className="login-form">

              {!isLoginMode && (
                <div className="input-group">
                  <label>NOME COMPLETO</label>
                  <div className="input-box">
                    <User className="input-icon" size={18} />
                    <input
                      type="text"
                      placeholder="Seu nome"
                      value={formData.name}
                      onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                      required
                    />
                  </div>
                </div>
              )}

              <div className="input-group">
                <label>E-MAIL</label>
                <div className="input-box">
                  <Mail className="input-icon" size={18} />
                  <input
                    type="email"
                    placeholder="seu@email.com"
                    value={formData.email}
                    onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                    required
                  />
                </div>
              </div>

              {!isLoginMode && (
                <div className="input-group">
                  <label>TELEFONE</label>
                  <div className="input-box">
                    <Phone className="input-icon" size={18} />
                    <input
                      type="tel"
                      placeholder="(11) 99999-9999"
                      value={formData.phone}
                      onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                      required
                    />
                  </div>
                </div>
              )}

              <div className="input-group">
                <label>SENHA</label>
                <div className="input-box">
                  <Lock className="input-icon" size={18} />
                  <input
                    type={showPassword ? "text" : "password"}
                    placeholder="••••••••"
                    value={formData.password}
                    onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                    required
                  />
                  <button
                    type="button"
                    className="input-eye"
                    onClick={() => setShowPassword(!showPassword)}
                  >
                    {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
                  </button>
                </div>
              </div>

              {!isLoginMode && (
                <div className="input-group">
                  <label>CONFIRMAR SENHA</label>
                  <div className="input-box">
                    <Lock className="input-icon" size={18} />
                    <input
                      type={showConfirmPassword ? "text" : "password"}
                      placeholder="••••••••"
                      value={formData.confirmPassword}
                      onChange={(e) => setFormData({ ...formData, confirmPassword: e.target.value })}
                      required
                    />
                    <button
                      type="button"
                      className="input-eye"
                      onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                    >
                      {showConfirmPassword ? <EyeOff size={16} /> : <Eye size={16} />}
                    </button>
                  </div>
                </div>
              )}

              {isLoginMode && (
                <div className="forgot-password">Esqueceu a senha?</div>
              )}

              <button type="submit" className="login-btn" disabled={loading}>
                {loading ? "AGUARDE..." : isLoginMode ? "ENTRAR" : "CRIAR CONTA"}
              </button>

              <div className="login-divider" />

              <div className="login-toggle">
                <p>
                  {isLoginMode ? "Não tem uma conta ainda?" : "Já tem uma conta?"}
                </p>
                <button
                  type="button"
                  onClick={() => {
                    setIsLoginMode(!isLoginMode);
                    setErro("");
                    setShowPassword(false);
                    setShowConfirmPassword(false);
                  }}
                >
                  {isLoginMode ? "CLIQUE AQUI" : "FAZER LOGIN"}
                </button>
              </div>

            </form>
          </div>
        </motion.div>

      </div>
    </div>
  );
}