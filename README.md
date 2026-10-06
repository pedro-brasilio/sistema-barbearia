# Sistema de Barbearia

Projeto acadêmico desenvolvido para a disciplina de Projeto Integrado Multidisciplinar (PIM), com o objetivo de aplicar conceitos de desenvolvimento back-end em C#, front-end em React e modelagem de banco de dados relacional.

O sistema foi pensado para apoiar a organização de uma barbearia, centralizando informações de clientes, barbeiros, serviços, agendamentos, produtos e pagamentos.

## Funcionalidades

- Cadastro de clientes;
- Cadastro de barbeiros;
- Cadastro de serviços, com preço e duração;
- Controle de agendamentos;
- Registro da situação dos agendamentos: pendente, confirmado ou cancelado;
- Associação de serviços aos agendamentos;
- Cadastro e controle básico de estoque de produtos;
- Registro de pagamentos vinculados aos agendamentos.

## Estrutura do projeto

```
sistema-barbearia/
├── backend/          # API em C# (.NET) + Entity Framework Core
├── frontend/         # Interface web em React + TypeScript + Vite
├── mobile/           # Versão mobile em Flutter (Android, iOS e Web)
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

## Autores

- Pedro Luciano Brasilio dos Santos
- Moises Gomes
- Luis Laia
- João Victor

## Finalidade acadêmica

Este projeto foi desenvolvido exclusivamente para fins acadêmicos, como parte de um trabalho de faculdade.
