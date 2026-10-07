import { useEffect, useState } from 'react';

// "R$ 45" ou "R$ 47,50"
export function formatarPreco(preco: number) {
  return Number.isInteger(preco) ? `R$ ${preco}` : `R$ ${preco.toFixed(2).replace('.', ',')}`;
}

// Data de hoje (AAAA-MM-DD) no fuso do aparelho. O toISOString() usa UTC
// e, no Brasil, já vira o dia seguinte depois das 21h.
export function hojeLocal() {
  const agora = new Date();
  const doisDigitos = (n: number) => String(n).padStart(2, '0');
  return `${agora.getFullYear()}-${doisDigitos(agora.getMonth() + 1)}-${doisDigitos(agora.getDate())}`;
}

// Data de hoje que se atualiza sozinha à meia-noite
export function useHoje() {
  const [hoje, setHoje] = useState(hojeLocal);

  useEffect(() => {
    const agora = new Date();
    const amanha = new Date(agora.getFullYear(), agora.getMonth(), agora.getDate() + 1);
    const timer = setTimeout(() => setHoje(hojeLocal()), amanha.getTime() - agora.getTime() + 1000);
    return () => clearTimeout(timer);
  }, [hoje]);

  return hoje;
}
