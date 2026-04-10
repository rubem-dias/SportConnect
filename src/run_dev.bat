@echo off
echo.
echo  SportConnect - DEV (mock)
echo  Escolha o dispositivo:
echo  [1] Windows (desktop)
echo  [2] Edge (web)
echo.
set /p choice="Digite 1 ou 2: "

if "%choice%"=="1" (
    flutter run -t lib/main_dev.dart -d windows
) else if "%choice%"=="2" (
    flutter run -t lib/main_dev.dart -d edge
) else (
    echo Opcao invalida.
    pause
)
