@echo off
Title Website Blocker Manager v2.0
color 0b
setlocal enabledelayedexpansion

REM ========================================
REM   WEBSITE BLOCKER MANAGER v2.0
REM   by adeism
REM ========================================

REM Auto-elevate to Administrator
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo Memerlukan hak Administrator...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit
)

REM Initialize variables
set hostspath=%windir%\System32\drivers\etc\hosts
set scriptdir=%~dp0
set websitesfile=%scriptdir%websites.txt
set categoriesfile=%scriptdir%categories.ini
set configfile=%scriptdir%config.ini
set logdir=%scriptdir%logs
set backupdir=%scriptdir%backups

REM Create directories if not exist
if not exist "%logdir%" mkdir "%logdir%"
if not exist "%backupdir%" mkdir "%backupdir%"

REM Create default files if not exist
if not exist "%websitesfile%" call :CREATE_DEFAULT_WEBSITES
if not exist "%categoriesfile%" call :CREATE_DEFAULT_CATEGORIES
if not exist "%configfile%" call :CREATE_DEFAULT_CONFIG

:MENU
cls
echo ========================================
echo    WEBSITE BLOCKER MANAGER v2.0
echo ========================================
echo.
echo  1. Blokir Semua Website
echo  2. Blokir Berdasarkan Kategori
echo  3. Tambah Website Custom
echo  4. Hapus Blokir Spesifik
echo  5. Lihat Daftar Blokir Aktif
echo  6. Lihat Log History
echo  7. Restore dari Backup
echo  8. Pengaturan
echo  9. Keluar
echo.
echo ========================================
set /p choice="Pilihan (1-9): "

if "%choice%"=="1" goto BLOCK_ALL
if "%choice%"=="2" goto BLOCK_CATEGORY
if "%choice%"=="3" goto ADD_CUSTOM
if "%choice%"=="4" goto REMOVE_SPECIFIC
if "%choice%"=="5" goto VIEW_ACTIVE
if "%choice%"=="6" goto VIEW_LOG
if "%choice%"=="7" goto RESTORE_BACKUP
if "%choice%"=="8" goto SETTINGS
if "%choice%"=="9" goto EXIT
goto MENU

:BLOCK_ALL
cls
echo ========================================
echo   BLOKIR SEMUA WEBSITE
echo ========================================
echo.
echo Membuat backup timestamped...
call :CREATE_BACKUP

echo.
echo Menambahkan semua website ke hosts file...

set count=0
for /f "usebackq tokens=*" %%a in ("%websitesfile%") do (
    set line=%%a
    REM Skip empty lines and comments
    if not "!line!"=="" (
        echo !line! | findstr /r "^#" >nul
        if errorlevel 1 (
            echo 127.0.0.1 %%a >> "%hostspath%"
            echo 127.0.0.1 www.%%a >> "%hostspath%"
            set /a count+=1
        )
    )
)

echo.
echo Total %count% website diblokir.
call :LOG_ACTION "BLOCK_ALL" "%count% websites blocked"
call :FLUSH_DNS

echo.
echo Selesai! Tekan tombol untuk kembali ke menu.
pause >nul
goto MENU

:BLOCK_CATEGORY
cls
echo ========================================
echo   BLOKIR BERDASARKAN KATEGORI
echo ========================================
echo.
echo Kategori yang tersedia:
echo.
echo  1. Social Media
echo  2. E-Commerce
echo  3. Gaming
echo  4. Streaming
echo  5. News
echo  6. Kembali
echo.
set /p catChoice="Pilih kategori (1-6): "

if "%catChoice%"=="1" set category=SOCIAL_MEDIA
if "%catChoice%"=="2" set category=ECOMMERCE
if "%catChoice%"=="3" set category=GAMING
if "%catChoice%"=="4" set category=STREAMING
if "%catChoice%"=="5" set category=NEWS
if "%catChoice%"=="6" goto MENU

if "%category%"=="" (
    echo Pilihan tidak valid!
    pause
    goto BLOCK_CATEGORY
)

echo.
echo Membuat backup...
call :CREATE_BACKUP

echo.
echo Memblokir kategori: %category%...

set inCategory=0
set count=0
for /f "usebackq tokens=*" %%a in ("%categoriesfile%") do (
    set line=%%a
    
    REM Check if entering category section
    echo !line! | findstr /r "^\[%category%\]" >nul
    if not errorlevel 1 set inCategory=1
    
    REM Check if entering different category section
    echo !line! | findstr /r "^\[" >nul
    if not errorlevel 1 (
        echo !line! | findstr /r "^\[%category%\]" >nul
        if errorlevel 1 set inCategory=0
    )
    
    REM Add website if in category
    if !inCategory!==1 (
        echo !line! | findstr /r "^#" >nul
        if errorlevel 1 (
            echo !line! | findstr /r "^\[" >nul
            if errorlevel 1 (
                if not "!line!"=="" (
                    echo 127.0.0.1 !line! >> "%hostspath%"
                    echo 127.0.0.1 www.!line! >> "%hostspath%"
                    set /a count+=1
                )
            )
        )
    )
)

echo.
echo Total %count% website dalam kategori %category% diblokir.
call :LOG_ACTION "BLOCK_CATEGORY" "Category %category% - %count% websites blocked"
call :FLUSH_DNS

echo.
echo Selesai! Tekan tombol untuk kembali.
pause >nul
goto MENU

:ADD_CUSTOM
cls
echo ========================================
echo   TAMBAH WEBSITE CUSTOM
echo ========================================
echo.
set /p customSite="Masukkan domain (tanpa www): "

if "%customSite%"=="" (
    echo Domain tidak boleh kosong!
    pause
    goto MENU
)

echo.
echo Membuat backup...
call :CREATE_BACKUP

echo.
echo Menambahkan %customSite% ke hosts...
echo 127.0.0.1 %customSite% >> "%hostspath%"
echo 127.0.0.1 www.%customSite% >> "%hostspath%"

echo.
echo Menambahkan ke websites.txt...
echo %customSite% >> "%websitesfile%"

call :LOG_ACTION "ADD_CUSTOM" "Added %customSite%"
call :FLUSH_DNS

echo.
echo %customSite% berhasil ditambahkan dan diblokir!
pause
goto MENU

:REMOVE_SPECIFIC
cls
echo ========================================
echo   HAPUS BLOKIR SPESIFIK
echo ========================================
echo.
set /p removeSite="Masukkan domain yang akan dibuka (tanpa www): "

if "%removeSite%"=="" (
    echo Domain tidak boleh kosong!
    pause
    goto MENU
)

echo.
echo Membuat backup...
call :CREATE_BACKUP

echo.
echo Menghapus %removeSite% dari hosts...

REM Create temp file without the blocked site
type nul > "%hostspath%.tmp"
for /f "usebackq tokens=*" %%a in ("%hostspath%") do (
    set line=%%a
    echo !line! | findstr /i "%removeSite%" >nul
    if errorlevel 1 (
        echo %%a >> "%hostspath%.tmp"
    )
)

move /Y "%hostspath%.tmp" "%hostspath%" >nul

call :LOG_ACTION "REMOVE_SPECIFIC" "Removed %removeSite%"
call :FLUSH_DNS

echo.
echo %removeSite% berhasil dihapus dari blokir!
pause
goto MENU

:VIEW_ACTIVE
cls
echo ========================================
echo   DAFTAR BLOKIR AKTIF
echo ========================================
echo.
echo Daftar website yang sedang diblokir:
echo.

findstr /i "127.0.0.1" "%hostspath%" | findstr /v "localhost"

echo.
echo ========================================
pause
goto MENU

:VIEW_LOG
cls
echo ========================================
echo   LOG HISTORY
echo ========================================
echo.

if exist "%logdir%\block_log.txt" (
    type "%logdir%\block_log.txt"
) else (
    echo Belum ada log history.
)

echo.
echo ========================================
pause
goto MENU

:RESTORE_BACKUP
cls
echo ========================================
echo   RESTORE DARI BACKUP
echo ========================================
echo.
echo Daftar backup yang tersedia:
echo.

dir /b "%backupdir%\*.bak" 2>nul
if errorlevel 1 (
    echo Tidak ada backup yang tersedia.
    pause
    goto MENU
)

echo.
set /p backupFile="Masukkan nama file backup (atau ketik 'latest' untuk backup terbaru): "

if "%backupFile%"=="latest" (
    for /f "delims=" %%a in ('dir /b /o-d "%backupdir%\*.bak" 2^>nul') do (
        set backupFile=%%a
        goto :RESTORE_EXECUTE
    )
)

:RESTORE_EXECUTE
if not exist "%backupdir%\%backupFile%" (
    echo File backup tidak ditemukan!
    pause
    goto MENU
)

echo.
echo Mengembalikan dari backup: %backupFile%...
copy /Y "%backupdir%\%backupFile%" "%hostspath%" >nul

call :LOG_ACTION "RESTORE" "Restored from %backupFile%"
call :FLUSH_DNS

echo.
echo Restore berhasil!
pause
goto MENU

:SETTINGS
cls
echo ========================================
echo   PENGATURAN
echo ========================================
echo.
echo  1. Edit websites.txt
echo  2. Edit categories.ini
echo  3. Hapus semua backup lama
echo  4. Reset ke default
echo  5. Kembali
echo.
set /p setChoice="Pilihan (1-5): "

if "%setChoice%"=="1" notepad "%websitesfile%" & goto SETTINGS
if "%setChoice%"=="2" notepad "%categoriesfile%" & goto SETTINGS
if "%setChoice%"=="3" (
    del /q "%backupdir%\*.bak" 2>nul
    echo Semua backup dihapus.
    pause
    goto SETTINGS
)
if "%setChoice%"=="4" (
    call :CREATE_DEFAULT_WEBSITES
    call :CREATE_DEFAULT_CATEGORIES
    echo Pengaturan direset ke default.
    pause
    goto SETTINGS
)
if "%setChoice%"=="5" goto MENU
goto SETTINGS

:CREATE_BACKUP
set timestamp=%date:~-4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set timestamp=%timestamp: =0%
copy /Y "%hostspath%" "%backupdir%\hosts_%timestamp%.bak" >nul
echo Backup dibuat: hosts_%timestamp%.bak
goto :EOF

:FLUSH_DNS
echo.
echo Membersihkan cache DNS...
ipconfig /flushdns >nul
echo Cache DNS dibersihkan.
goto :EOF

:LOG_ACTION
set logfile=%logdir%\block_log.txt
echo [%date% %time%] %~1: %~2 >> "%logfile%"
goto :EOF

:CREATE_DEFAULT_WEBSITES
(
echo # Website Blocker - Default List
echo # Tambahkan website tanpa www, satu per baris
echo # Gunakan # untuk komentar
echo.
echo # Social Media
echo facebook.com
echo instagram.com
echo tiktok.com
echo twitter.com
echo x.com
echo.
echo # E-Commerce
echo shopee.co.id
echo tokopedia.com
echo lazada.co.id
echo bukalapak.com
echo.
echo # Gaming
echo roblox.com
echo epicgames.com
echo steampowered.com
echo.
echo # Streaming
echo youtube.com
echo netflix.com
echo spotify.com
echo twitch.tv
) > "%websitesfile%"
goto :EOF

:CREATE_DEFAULT_CATEGORIES
(
echo # Categories Configuration
echo # Format: [CATEGORY_NAME] diikuti list website
echo.
echo [SOCIAL_MEDIA]
echo facebook.com
echo instagram.com
echo tiktok.com
echo twitter.com
echo x.com
echo linkedin.com
echo pinterest.com
echo reddit.com
echo quora.com
echo discord.com
echo telegram.org
echo.
echo [ECOMMERCE]
echo shopee.co.id
echo tokopedia.com
echo lazada.co.id
echo bukalapak.com
echo blibli.com
echo jd.id
echo.
echo [GAMING]
echo roblox.com
echo epicgames.com
echo steampowered.com
echo.
echo [STREAMING]
echo youtube.com
echo netflix.com
echo spotify.com
echo twitch.tv
echo disneyplus.com
echo primevideo.com
echo hulu.com
echo.
echo [NEWS]
echo detik.com
echo kompas.com
echo tribunnews.com
echo liputan6.com
echo okezone.com
echo sindonews.com
echo kumparan.com
echo idntimes.com
) > "%categoriesfile%"
goto :EOF

:CREATE_DEFAULT_CONFIG
(
echo # Website Blocker Configuration
echo AUTO_BACKUP=1
echo MAX_BACKUPS=5
echo LOG_ENABLED=1
) > "%configfile%"
goto :EOF

:EXIT
cls
echo.
echo Terima kasih telah menggunakan Website Blocker Manager!
echo.
timeout /t 2 >nul
exit
