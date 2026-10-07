import { motion } from "framer-motion";
import { Scissors, Clock, Star, MapPin, Download } from "lucide-react";
import type { Servico } from "../api";
import { formatarPreco } from "../utils";

// APK da release mais recente, publicado pelo GitHub Actions (.github/workflows/app-android.yml).
// VITE_APK_URL permite testar com outro arquivo, ex.: /barbershop.apk em public/.
const APK_URL =
  import.meta.env.VITE_APK_URL ||
  "https://github.com/pedro-brasilio/sistema-barbearia/releases/latest/download/barbershop.apk";

interface HomeProps {
  servicos: Servico[] | null; // null = carregando
  onNavigateToBooking: () => void;
}

export function Home({ servicos, onNavigateToBooking }: HomeProps) {

  return (
    <div className="home">

      {/* HERO */}
      <motion.section
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ duration: 0.8 }}
        className="hero"
      >

        <div className="hero-background">
          <div className="hero-gradient" />
          <div className="hero-lines" />
        </div>

        <div className="hero-container">
          <div className="hero-grid">

            <motion.div
              initial={{ x: -50, opacity: 0 }}
              animate={{ x: 0, opacity: 1 }}
              transition={{ delay: 0.2, duration: 0.8 }}
            >
              <div className="badge">
                DESDE 1998
              </div>

              <h2 className="hero-title">
                ESTILO <br />
                <span>ATEMPORAL</span>
              </h2>

              <p className="hero-text">
                Tradição e excelência em cada corte. Profissionais experientes,
                ambiente acolhedor e o melhor atendimento da cidade.
              </p>

              <div className="hero-actions">
                <button
                  onClick={onNavigateToBooking}
                  className="hero-button"
                >
                  AGENDAR HORÁRIO
                </button>

                <a href={APK_URL} download="barbershop.apk" className="hero-button-app">
                  <Download size={18} />
                  BAIXAR APP
                </a>
              </div>
            </motion.div>

            <motion.div
              initial={{ x: 50, opacity: 0 }}
              animate={{ x: 0, opacity: 1 }}
              transition={{ delay: 0.4, duration: 0.8 }}
              className="hero-right"
            >
              <div className="hero-visual">
                <div className="hero-visual-bg" />

                <div className="hero-visual-card">
                  <Scissors className="hero-scissors" />
                </div>
              </div>
            </motion.div>

          </div>
        </div>
      </motion.section>


      {/* SERVICES */}
      <section className="services">
        <div className="container">

          <motion.div
            initial={{ y: 30, opacity: 0 }}
            whileInView={{ y: 0, opacity: 1 }}
            transition={{ duration: 0.6 }}
            className="section-header"
          >
            <h3 className="section-title">
              SERVIÇOS
            </h3>

            <div className="section-line" />
          </motion.div>


          {!servicos?.length && (
            <p className="services-status">
              {servicos ? "Nenhum serviço disponível no momento." : "Carregando serviços..."}
            </p>
          )}

          <div className="services-grid">
            {servicos?.map((service, index) => (
              <motion.div
                key={service.id}
                initial={{ y: 30, opacity: 0 }}
                whileInView={{ y: 0, opacity: 1 }}
                transition={{ delay: index * 0.1 }}
                className="service-card"
              >

                {/* quadrado laranja */}
                <div className="service-corner" />

                <h4>
                  {service.nameServico}
                </h4>

                <div className="service-info">
                  <span className="price">
                    {formatarPreco(service.preco)}
                  </span>

                  <div className="duration">
                    <Clock size={14} />
                    {service.duracaoMinutos} min
                  </div>
                </div>

                <div className="service-line" />
              </motion.div>
            ))}
          </div>
        </div>
      </section>


      {/* INFO */}
      <section className="info">
        <div className="container">
          <div className="info-grid">

            <motion.div
              initial={{ y: 30, opacity: 0 }}
              whileInView={{ y: 0, opacity: 1 }}
              className="info-card"
            >
              <Star className="info-icon" />
              <h4>Excelência</h4>
              <p>Mais de 25 anos de tradição e qualidade</p>
            </motion.div>

            <motion.div
              initial={{ y: 30, opacity: 0 }}
              whileInView={{ y: 0, opacity: 1 }}
              transition={{ delay: 0.1 }}
              className="info-card"
            >
              <Clock className="info-icon" />
              <h4>Horários Flexíveis</h4>
              <p>Seg-Sex: 9h-20h | Sáb: 9h-18h</p>
            </motion.div>

            <motion.div
              initial={{ y: 30, opacity: 0 }}
              whileInView={{ y: 0, opacity: 1 }}
              transition={{ delay: 0.2 }}
              className="info-card"
            >
              <MapPin className="info-icon" />
              <h4>Localização</h4>
              <p>Av. Principal, 1234 - Centro</p>
            </motion.div>

          </div>
        </div>
      </section>

    </div>
  );
}