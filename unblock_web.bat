@echo off
Title Website Unblock - All Clear
color 0a
setlocal enabledelayedexpansion

REM Auto-elevate to Administrator
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo Memerlukan hak Administrator...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit
)

set hostspath=%windir%\System32\drivers\etc\hosts
set scriptdir=%~dp0
set backupdir=%scriptdir%backups
set logdir=%scriptdir%logs

cls
echo.
echo  ================================
echo    BUKA SEMUA BLOKIR WEBSITE
echo  ================================
echo.

REM Hitung berapa yang diblokir
set blockcount=0
for /f %%a in ('findstr /c:"127.0.0.1" "%hostspath%" ^| findstr /v "localhost" ^| find /c /v ""') do set blockcount=%%a

if %blockcount%==0 (
    echo  Tidak ada blokir aktif saat ini.
    pause
    exit
)

echo  Ditemukan %blockcount% entri blokir.
echo.
set /p confirm="  Hapus semua? (y/n): "
if /i not "%confirm%"=="y" (
    echo  Dibatalkan.
    pause
    exit
)

REM Backup dulu
if not exist "%backupdir%" mkdir "%backupdir%"
for /f "tokens=2 delims==" %%a in ('wmic os get localdatetime /value') do set dt=%%a
set timestamp=%dt:~0,8%_%dt:~8,6%
copy /Y "%hostspath%" "%backupdir%\hosts_%timestamp%.bak" >nul
echo  Backup dibuat.

REM Hapus semua baris 127.0.0.1 kecuali localhost
type nul > "%hostspath%.tmp"
for /f "usebackq tokens=*" %%a in ("%hostspath%") do (
    set line=%%a
    echo !line! | findstr /r "^127.0.0.1" >nul
    if errorlevel 1 (
        echo %%a >> "%hostspath%.tmp"
    ) else (
        echo !line! | findstr /i "localhost" >nul
        if not errorlevel 1 echo %%a >> "%hostspath%.tmp"
    )
)
move /Y "%hostspath%.tmp" "%hostspath%" >nul

REM Flush DNS
ipconfig /flushdns >nul

REM Log
if not exist "%logdir%" mkdir "%logdir%"
echo [%date% %time%] UNBLOCK_ALL: Removed %blockcount% entries >> "%logdir%\block_log.txt"

echo.
echo  Selesai! Semua %blockcount% blokir dihapus.
echo  Cache DNS sudah dibersihkan.
echo.
pause
exit
