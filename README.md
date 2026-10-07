# Sistema de Barbearia

Projeto acadêmico desenvolvido para a disciplina de Projeto Integrado Multidisciplinar (PIM), com o objetivo de aplicar conceitos de desenvolvimento back-end em C#, front-end em React e modelagem de banco de dados relacional.

O sistema foi pensado para apoiar a organização de uma barbearia, centralizando informações de clientes, barbeiros, serviços, agendamentos, produtos e pagamentos.

## Funcionalidades

- Cadastro de clientes;
- Cadastro de barbeiros;
- Cadastro de serviços, com preço e duração, pela aba ADMIN > SERVIÇOS (o início e o agendamento leem a lista do banco);
- No perfil do administrador, "Meus agendamentos" mostra os próximos agendamentos da barbearia e o histórico do dia, que renova à meia-noite;
- Controle de agendamentos;
- Registro da situação dos agendamentos: pendente, confirmado ou cancelado;
- Associação de serviços aos agendamentos;
- Cadastro e controle básico de estoque de produtos;
- Registro de pagamentos vinculados aos agendamentos;
- Envio de avisos e promoções por notificação no app Android, pela aba ADMIN, com filtro de público (n8n + Firebase).

## Estrutura do projeto

```
sistema-barbearia/
├── backend/          # API em C# (.NET) + Entity Framework Core
├── frontend/         # Interface web em React + TypeScript + Vite
├── mobile/           # Versão mobile em Flutter (Android, iOS e Web)
├── n8n/              # Workflow de notificações push (importar no n8n)
├── Barbearia.sql     # Modelagem original do banco (SQL Server, só referência)
├── render.yaml       # Configuração do deploy no Render
└── PIM3ºSEMESTRE.sln # Solução do Visual Studio
```

## Tecnologias utilizadas

**Back-end**
- C# / .NET
- Entity Framework Core
- PostgreSQL

**Front-end**
- React
- TypeScript
- Vite

**Mobile**
- Flutter / Dart

## Estrutura do banco de dados

O banco de dados `BarbeariaDB` possui as seguintes tabelas:

- `clientes`
- `barbeiros`
- `servicos`
- `Agendamentos`
- `agendamentoservicos`
- `produtos`
- `pagamentos`

O script também inclui dados iniciais de um barbeiro padrão e serviços para teste.

## Como executar

### Banco de dados

O banco é PostgreSQL. A forma mais simples de ter um localmente é com Docker:

```bash
docker run -d --name barbearia-pg -p 5432:5432 -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=barbearia postgres:17
```

As tabelas, o barbeiro padrão e os serviços são criados automaticamente quando a API inicia (migrations do Entity Framework). Em desenvolvimento também é criado o administrador `admin@barbearia.com` / `admin123` (definido em `backend/appsettings.Development.json`).

O arquivo `Barbearia.sql` é a modelagem original em SQL Server e fica no repositório apenas como referência.

### Back-end (API)

1. Abra a solução `PIM3ºSEMESTRE.sln` no Visual Studio, ou navegue até a pasta `backend/`.
2. Verifique e configure a string de conexão em `appsettings.json`, caso necessário (o padrão é o Postgres do comando acima).
3. Execute o projeto (Visual Studio ou `dotnet run` dentro de `backend/`).

### Front-end

```bash
cd frontend
npm install
npm run dev
```

### Mobile (Flutter)

Com a API rodando (`dotnet run --launch-profile http` dentro de `backend/`), dê dois cliques em `mobile/rodar.bat` ou rode:

```bash
cd mobile
flutter pub get
flutter run
```

Os detalhes (emulador, celular físico e Chrome) estão em [`mobile/README.md`](mobile/README.md).

## Deploy no Render

O arquivo `render.yaml` cria tudo de uma vez: o banco PostgreSQL, a API (via Docker) e o site (estático).

1. No [Render](https://render.com), clique em **New > Blueprint** e selecione este repositório.
2. Preencha `Admin__Email` e `Admin__Senha` (login do administrador do site).
3. Confirme. O primeiro deploy da API leva alguns minutos.
4. Se o Render tiver acrescentado um sufixo aos nomes dos serviços, ajuste no painel:
   - na API, `Cors__Origins` = endereço do site (ex.: `https://barbearia-pim-web.onrender.com`);
   - no site, `VITE_API_URL` = endereço da API + `/api` (ex.: `https://barbearia-pim-api.onrender.com/api`), e faça **Manual Deploy**.

Limitações do plano gratuito: a API "dorme" após 15 minutos sem acesso (a primeira requisição depois disso leva cerca de 1 minuto) e o banco gratuito expira 30 dias após a criação.

### Login e permissões

O login e o cadastro devolvem um token (JWT), que o site e o app mandam em toda chamada à API. Sem login dá para ver só os serviços e os barbeiros; o cliente vê, cria e cancela apenas os próprios agendamentos; o administrador acessa o resto (todos os agendamentos, serviços, notificações, barbeiros, produtos e pagamentos). A lista de clientes nunca devolve a senha.

Os tokens são assinados com a chave `Jwt:Chave`, e a API não sobe sem ela:

- no Render, a variável `Jwt__Chave` é gerada automaticamente pelo `render.yaml`. Se ela não aparecer na API, crie-a no painel com um texto aleatório de pelo menos 32 caracteres;
- no PC, `appsettings.Development.json` já traz uma chave só para desenvolvimento.

Para o app Flutter usar a API publicada:

```bash
flutter run --dart-define=API_URL=https://barbearia-pim-api.onrender.com/api
```

## App Android (APK)

O botão **BAIXAR APP** da página inicial do site baixa o APK da [release mais recente](https://github.com/pedro-brasilio/sistema-barbearia/releases/latest), já apontando para a API do Render.

O APK é gerado pelo GitHub Actions ([`.github/workflows/app-android.yml`](.github/workflows/app-android.yml)) a cada push que altera `mobile/`. Em qualquer branch o APK fica disponível como artefato da execução; na `main` ele também é publicado como uma nova release.

O APK é assinado sempre com a mesma chave, para que uma versão nova instale por cima da anterior. A chave fica nos secrets do repositório (**Settings > Secrets and variables > Actions**):

- `ANDROID_KEYSTORE_BASE64`: keystore PKCS12 (`.p12`) em base64;
- `ANDROID_KEYSTORE_PASSWORD`: senha da keystore.

No celular, o Android pede permissão para instalar apps baixados pelo navegador; basta permitir.

## Notificações push (n8n + Firebase)

Na aba **ADMIN** do site e do app, o administrador abre **NOTIFICAÇÕES**, escreve título e mensagem (`{nome}` vira o primeiro nome do cliente) e escolhe o público. O painel mostra quantos clientes com o app vão receber antes do envio. Os públicos são:

- todos os clientes;
- sem horário agendado (nenhum de hoje em diante);
- com horário agendado;
- nunca agendaram;
- sumidos (último horário há mais de 30 dias e nenhum marcado).

Como funciona:

1. Depois do login, o app Android envia o token do Firebase do celular para a API (`PUT /api/Clientecontrolador/{id}/token-push`).
2. O painel chama `POST /api/Notificacaocontrolador/enviar` (a contagem vem de `GET /api/Notificacaocontrolador/publico`). A API confere se quem pede é o administrador e escolhe os clientes pelo filtro.
3. A API chama o webhook do n8n ([`n8n/notificacoes-push.json`](n8n/notificacoes-push.json)) com o título, a mensagem e os celulares, usando a chave `X-Chave-Notificacoes`.
4. O n8n envia para cada celular pelo Firebase Cloud Messaging e devolve quantos deram certo, e o painel mostra o resultado.

Configuração (uma vez):

1. No [console do Firebase](https://console.firebase.google.com), crie um projeto e adicione um app **Android** com o pacote `com.barbearia.barbershop_mobile` (não precisa de SHA-1).
2. Baixe o `google-services.json` que o Firebase oferece. Ele **não** vai para o projeto: só copie estes valores para as variáveis do repositório (**Settings > Secrets and variables > Actions > Variables**):
   - `FIREBASE_API_KEY` = `client[0].api_key[0].current_key`
   - `FIREBASE_APP_ID` = `client[0].client_info.mobilesdk_app_id`
   - `FIREBASE_SENDER_ID` = `project_info.project_number`
   - `FIREBASE_PROJECT_ID` = `project_info.project_id`

   O próximo APK gerado pelo GitHub Actions já vem com notificações. Sem essas variáveis, o app funciona normalmente, mas não recebe notificações.
3. Em **Configurações do projeto > Contas de serviço**, gere uma chave privada (arquivo JSON, **não** coloque no repositório).
4. No n8n, importe [`n8n/notificacoes-push.json`](n8n/notificacoes-push.json) e:
   - no nó **Chamada da API**, crie uma credencial **Header Auth** com nome `X-Chave-Notificacoes` e uma chave secreta qualquer (ex.: `openssl rand -hex 24`);
   - no nó **Configurações**, preencha `FIREBASE_PROJECT_ID`;
   - no nó **Envia pelo Firebase (FCM)**, crie uma credencial **Google Service Account API** com o `client_email` e a `private_key` do JSON, ligue **Set up for use in HTTP Request node** e use o escopo `https://www.googleapis.com/auth/firebase.messaging`;
   - publique o workflow.
5. Na API, configure o endereço do webhook e a mesma chave:
   - no Render: variáveis `N8n__WebhookUrl` (ex.: `https://SEU-N8N/webhook/barbershop-notificacoes`) e `N8n__Chave`. O n8n precisa estar acessível pela internet para a API do Render alcançá-lo;
   - rodando no PC: o endereço já vem em `appsettings.Development.json` (`http://localhost:5678/...`); a chave fica nos *user secrets*, fora do repositório: `cd backend` e `dotnet user-secrets set "N8n:Chave" "SUA-CHAVE"`.

Para o celular receber, o cliente precisa entrar na conta pelo app pelo menos uma vez e permitir as notificações. Com o app aberto, o aviso aparece numa barra na parte de baixo da tela; com ele fechado, aparece na barra de notificações do Android.

## Autores

- Pedro Luciano Brasilio dos Santos
- Moises Gomes
- Luis Laia
- João Victor

## Finalidade acadêmica

Este projeto foi desenvolvido exclusivamente para fins acadêmicos, como parte de um trabalho de faculdade.
