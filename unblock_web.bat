@echo off
Title Unblock All Websites - Restore
color 0a

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
echo ========================================
echo   RESTORE HOSTS FILE
echo ========================================
echo.

REM Check if backup directory exists
if not exist "%backupdir%" (
    echo Folder backup tidak ditemukan!
    echo Tidak ada backup yang tersedia untuk restore.
    pause
    exit
)

REM Find latest backup
set latestBackup=
for /f "delims=" %%a in ('dir /b /o-d "%backupdir%\*.bak" 2^>nul') do (
    if not defined latestBackup set latestBackup=%%a
)

if not defined latestBackup (
    echo Tidak ada file backup yang ditemukan!
    echo.
    echo Opsi:
    echo 1. Buat hosts file baru (default Windows)
    echo 2. Keluar
    echo.
    set /p choice="Pilihan (1-2): "
    
    if "!choice!"=="1" (
        echo # Copyright (c) 1993-2009 Microsoft Corp. > "%hostspath%"
        echo # >> "%hostspath%"
        echo # This is a sample HOSTS file used by Microsoft TCP/IP for Windows. >> "%hostspath%"
        echo # >> "%hostspath%"
        echo 127.0.0.1       localhost >> "%hostspath%"
        echo ::1             localhost >> "%hostspath%"
        
        echo.
        echo Hosts file default telah dibuat.
        ipconfig /flushdns >nul
        echo Cache DNS dibersihkan.
        
        if exist "%logdir%\block_log.txt" (
            echo [%date% %time%] RESTORE: Created default hosts file >> "%logdir%\block_log.txt"
        )
    )
    
    pause
    exit
)

echo File backup terbaru ditemukan: %latestBackup%
echo.
set /p confirm="Restore dari backup ini? (Y/N): "

if /i "%confirm%" NEQ "Y" (
    echo.
    echo Restore dibatalkan.
    pause
    exit
)

echo.
echo Mengembalikan hosts file dari backup...
copy /Y "%backupdir%\%latestBackup%" "%hostspath%" >nul

if %errorLevel% EQU 0 (
    echo Berhasil! Hosts file telah dikembalikan.
    echo.
    echo Membersihkan cache DNS...
    ipconfig /flushdns >nul
    echo Cache DNS dibersihkan.
    
    if not exist "%logdir%" mkdir "%logdir%"
    echo [%date% %time%] RESTORE: Restored from %latestBackup% >> "%logdir%\block_log.txt"
    
    echo.
    echo Website sudah bisa diakses kembali!
    echo Silakan restart browser Anda.
) else (
    echo.
    echo Gagal mengembalikan hosts file!
    echo Periksa hak akses Administrator.
)

echo.
pause
