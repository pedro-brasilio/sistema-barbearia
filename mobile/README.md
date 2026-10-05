# Barbershop Mobile (Flutter)

Versão mobile do Sistema de Barbearia. Usa o mesmo layout, as mesmas cores, as mesmas fontes (Bebas Neue e Rajdhani) e os mesmos ícones (Lucide) do site em `frontend/`. A lógica das telas é a mesma do React e o app conversa com a mesma API em C# (`backend/`).

## Requisitos

- Flutter 3.24 ou mais recente. A pasta `android/` foi gerada com o Flutter 3.47.
- Para Android: Android Studio com um emulador, ou um celular com depuração USB.
- Para testar no computador sem emulador: Google Chrome.
- A API do `backend/` rodando, com o banco `BarbeariaDB` criado pelo `Barbearia.sql`.

## Como rodar

**1. Suba a API** (porta 5039, perfil http):

```bash
cd backend
dotnet run --launch-profile http
```

**2. Abra o app.** Escolha uma das formas:

- **Pelo arquivo:** dê dois cliques em `rodar.bat`. Ele baixa as dependências e pergunta se você quer abrir no celular/emulador ou no Chrome.
- **Pelo VS Code:** abra a pasta do projeto, vá em *Executar e Depurar* e escolha "Barbershop Mobile (celular/emulador)" ou "Barbershop Mobile (Chrome)".
- **Pelo terminal:**

```bash
cd mobile
flutter pub get
flutter run                                # celular ou emulador
flutter run -d chrome --web-port 5174      # navegador
```

No Chrome use sempre a porta 5174 ou 5173. São as únicas liberadas no CORS da API.

## Endereço da API

O app escolhe o endereço sozinho:

| Onde roda | Endereço usado |
|---|---|
| Emulador Android | `http://10.0.2.2:5039/api` (é o "localhost" do computador visto pelo emulador) |
| Chrome / simulador iOS | `http://localhost:5039/api` |

**Celular físico:** o celular precisa estar no mesmo Wi-Fi e a API precisa aceitar conexões da rede:

```bash
cd backend
dotnet run --urls http://0.0.0.0:5039
```

```bash
cd mobile
flutter run --dart-define=API_URL=http://IP_DO_COMPUTADOR:5039/api
```

Use o perfil **http** da API. No perfil https, o backend redireciona para `https://localhost:7205` e o celular não consegue seguir esse redirecionamento.

## Telas

| Site (React) | App (Flutter) |
|---|---|
| `components/Header.tsx` | `lib/widgets/header.dart` |
| `components/Home.tsx` | `lib/pages/home_page.dart` |
| `pages/Login.tsx` | `lib/pages/login_page.dart` |
| `pages/BookingForm.tsx` | `lib/pages/booking_page.dart` |
| `pages/AdminPanel.tsx` | `lib/pages/admin_page.dart` |
| `pages/Perfil.tsx` | `lib/pages/perfil_page.dart` |
| `App.tsx` | `lib/app.dart` |
| `api.ts` | `lib/api.dart` |
| `styles/*.css` (cores e fontes) | `lib/theme.dart` |

## Adaptações para celular

- O menu do topo (INÍCIO, AGENDAR, LOGIN, ADMIN) foi para a barra inferior, com os mesmos itens, cores e destaque do item ativo.
- Os grids de duas ou mais colunas viram uma coluna, como o próprio CSS do site faz em telas pequenas.
- No login aparece só o card, igual ao site abaixo de 1200px.
- No painel admin, cada linha da tabela vira um bloco com os mesmos dados, o status e o botão de ação.
- O botão "voltar" do Android volta para o início antes de fechar o app.

## Comportamento mantido do site

- Login e cadastro chamam `authcontrolador/login` e `Clientecontrolador/cadastro`.
- O agendamento chama `Agedamentocontrolador` e depois entra na lista da sessão.
- A lista de agendamentos fica só na memória enquanto o app está aberto, como no React. Confirmar, remover e cancelar mudam só essa lista.
- O ADMIN só aparece para usuários com `IsAdmin = true`.

## Testes

```bash
flutter test
```

## Problemas comuns

- **"Não foi possível conectar à API"**: confira se a API está rodando no perfil http e se o endereço da tabela acima é o certo para o seu dispositivo.
- **Erro de versão do Gradle, AGP ou Kotlin**: atualize o Flutter com `flutter upgrade`.
