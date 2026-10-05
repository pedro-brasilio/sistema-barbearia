@echo off
setlocal
cd /d "%~dp0"

where flutter >nul 2>nul
if errorlevel 1 (
  echo [ERRO] O Flutter nao foi encontrado no PATH.
  echo Instale em https://docs.flutter.dev/get-started/install/windows
  echo e depois abra este arquivo de novo.
  pause
  exit /b 1
)

echo ==================================================
echo   BARBERSHOP - versao mobile (Flutter)
echo ==================================================
echo   Antes, deixe a API rodando:
echo   cd backend  e  dotnet run --launch-profile http
echo.
echo   1 - Celular ou emulador (Android / iOS)
echo   2 - Navegador Chrome (porta 5174, liberada no CORS da API)
echo.
set "OPCAO=1"
set /p "OPCAO=Escolha 1 ou 2 e tecle ENTER [1]: "

echo.
echo Baixando dependencias...
call flutter pub get
if errorlevel 1 (
  pause
  exit /b 1
)

if "%OPCAO%"=="2" (
  call flutter run -d chrome --web-port 5174
) else (
  call flutter run
)
pause
