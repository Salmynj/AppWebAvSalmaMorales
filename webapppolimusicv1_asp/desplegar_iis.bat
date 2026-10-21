@echo off
REM ============================================================
REM  PoliMusic - Despliegue en IIS  (ejecutar como ADMINISTRADOR)
REM  Copia el sitio ASP clasico a C:/inetpub/wwwroot
REM ============================================================
setlocal

set "ORIGEN=%~dp0"
set "DESTINO=C:/inetpub/wwwroot"

echo.
echo  Origen : %ORIGEN%
echo  Destino: %DESTINO%
echo.

net session >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Esta ventana no tiene permisos de administrador.
    echo         Clic derecho ^> "Ejecutar como administrador".
    pause
    exit /b 1
)

echo [1/3] Copiando archivos .asp, css, js, img ...
xcopy "%ORIGEN%*.asp" "%DESTINO%\" /Y /R /D
xcopy "%ORIGEN%css\*"  "%DESTINO%css\"  /Y /R /D /I /E
xcopy "%ORIGEN%js\*"   "%DESTINO%js\"   /Y /R /D /I /E
xcopy "%ORIGEN%img\*"  "%DESTINO%img\"  /Y /R /D /I /E

echo [2/3] Copiando assets (SongFiles, UserImages, PlaylistImages) ...
xcopy "%ORIGEN%SongFiles\*"      "%DESTINO%SongFiles\"      /Y /R /D /I /E
xcopy "%ORIGEN%UserImages\*"     "%DESTINO%UserImages\"     /Y /R /D /I /E
xcopy "%ORIGEN%PlaylistImages\*" "%DESTINO%PlaylistImages\" /Y /R /D /I /E

echo [3/3] Dando permisos de lectura a IIS_IUSRS ...
icacls "%DESTINO%" /grant "BUILTIN\IIS_IUSRS:(OI)(CI)(RX)" /T /C /Q >nul 2>&1
icacls "%DESTINO%" /grant "IUSR:(OI)(CI)(RX)" /T /C /Q >nul 2>&1

echo.
echo  LISTO. Abre en el navegador:
echo     http://localhost/prueba_conexion.asp
echo     http://localhost/login.asp
echo.
pause
