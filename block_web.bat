@echo off
Title Website Blocker Manager v3.0
color 0b
setlocal enabledelayedexpansion

REM ========================================
REM   WEBSITE BLOCKER MANAGER v3.0
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
set scheduledir=%scriptdir%schedules

REM Create directories if not exist
if not exist "%logdir%" mkdir "%logdir%"
if not exist "%backupdir%" mkdir "%backupdir%"
if not exist "%scheduledir%" mkdir "%scheduledir%"

REM Create default files if not exist
if not exist "%websitesfile%" call :CREATE_DEFAULT_WEBSITES
if not exist "%categoriesfile%" call :CREATE_DEFAULT_CATEGORIES
if not exist "%configfile%" call :CREATE_DEFAULT_CONFIG

:MENU
cls
echo.
echo  ============================================
echo    WEBSITE BLOCKER MANAGER v3.0  by adeism
echo  ============================================

REM Show live block status
call :SHOW_STATUS

echo.
echo  ---- AKSI CEPAT ----
echo   [1] Blokir SEMUA sekarang
echo   [2] Buka SEMUA blokir
echo   [3] Toggle kategori (pilih dan langsung on/off)
echo.
echo  ---- KELOLA ----
echo   [4] Tambah website
echo   [5] Hapus blokir satu website
echo   [6] Lihat daftar website diblokir
echo   [7] Lihat log history
echo.
echo  ---- LANJUTAN ----
echo   [8] Jadwalkan blokir otomatis
echo   [9] Restore backup
echo   [0] Pengaturan
echo   [Q] Keluar
echo.
echo  ============================================
set /p choice="  Pilihan: "

if /i "%choice%"=="1" goto BLOCK_ALL
if /i "%choice%"=="2" goto UNBLOCK_ALL
if /i "%choice%"=="3" goto TOGGLE_CATEGORY
if /i "%choice%"=="4" goto ADD_CUSTOM
if /i "%choice%"=="5" goto REMOVE_SPECIFIC
if /i "%choice%"=="6" goto VIEW_ACTIVE
if /i "%choice%"=="7" goto VIEW_LOG
if /i "%choice%"=="8" goto SCHEDULE_MENU
if /i "%choice%"=="9" goto RESTORE_BACKUP
if /i "%choice%"=="0" goto SETTINGS
if /i "%choice%"=="Q" goto EXIT
goto MENU

REM ============================================
REM   SHOW LIVE STATUS
REM ============================================
:SHOW_STATUS
set blockcount=0
for /f %%a in ('findstr /c:"127.0.0.1" "%hostspath%" ^| findstr /v "localhost" ^| find /c /v ""') do set blockcount=%%a
if %blockcount% GTR 0 (
    echo.
    echo  STATUS: [AKTIF] %blockcount% entri diblokir
) else (
    echo.
    echo  STATUS: [TIDAK ADA BLOKIR AKTIF]
)
goto :EOF

REM ============================================
REM   BLOCK ALL
REM ============================================
:BLOCK_ALL
cls
echo.
echo  BLOKIR SEMUA WEBSITE
echo  ====================
call :CREATE_BACKUP

set count=0
for /f "usebackq tokens=*" %%a in ("%websitesfile%") do (
    set line=%%a
    if not "!line!"=="" (
        echo !line! | findstr /r "^#" >nul
        if errorlevel 1 (
            REM Skip jika sudah ada di hosts
            findstr /i "!line!" "%hostspath%" >nul 2>&1
            if errorlevel 1 (
                echo 127.0.0.1 %%a >> "%hostspath%"
                echo 127.0.0.1 www.%%a >> "%hostspath%"
                set /a count+=1
            )
        )
    )
)

echo  Selesai! %count% website baru diblokir.
call :LOG_ACTION "BLOCK_ALL" "%count% websites blocked"
call :FLUSH_DNS
pause
goto MENU

REM ============================================
REM   UNBLOCK ALL (NEW)
REM ============================================
:UNBLOCK_ALL
cls
echo.
echo  BUKA SEMUA BLOKIR
echo  =================
echo.
set /p confirm="  Yakin ingin membuka SEMUA blokir? (y/n): "
if /i not "%confirm%"=="y" goto MENU

call :CREATE_BACKUP

REM Buat hosts bersih tanpa blokiran
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

call :LOG_ACTION "UNBLOCK_ALL" "All blocks removed"
call :FLUSH_DNS
echo  Semua blokir berhasil dihapus!
pause
goto MENU

REM ============================================
REM   TOGGLE CATEGORY (NEW - 1 langkah)
REM ============================================
:TOGGLE_CATEGORY
cls
echo.
echo  TOGGLE KATEGORI
echo  ===============
echo  Pilih kategori untuk langsung ON/OFF:
echo.

set cats=SOCIAL_MEDIA ECOMMERCE GAMING STREAMING NEWS
set i=0
for %%c in (%cats%) do (
    set /a i+=1
    REM Cek status aktif
    set firstsite=
    for /f "usebackq skip=1 tokens=*" %%s in ("%categoriesfile%") do (
        if "!firstsite!"=="" (
            echo %%s | findstr /r "^\[" >nul
            if errorlevel 1 (
                set firstsite=%%s
            )
        )
    )
    echo   [!i!] %%c
)
echo   [6] Kembali
echo.
set /p catChoice="  Pilih kategori (1-6): "

set catname=
if "%catChoice%"=="1" set catname=SOCIAL_MEDIA
if "%catChoice%"=="2" set catname=ECOMMERCE
if "%catChoice%"=="3" set catname=GAMING
if "%catChoice%"=="4" set catname=STREAMING
if "%catChoice%"=="5" set catname=NEWS
if "%catChoice%"=="6" goto MENU
if "%catname%"=="" goto TOGGLE_CATEGORY

REM Cek apakah kategori ini sedang aktif (ada di hosts)
set inCat=0
set sample=
for /f "usebackq tokens=*" %%a in ("%categoriesfile%") do (
    set ln=%%a
    echo !ln! | findstr /r "^\[%catname%\]" >nul
    if not errorlevel 1 set inCat=1
    echo !ln! | findstr /r "^\[" >nul
    if not errorlevel 1 (
        echo !ln! | findstr /r "^\[%catname%\]" >nul
        if errorlevel 1 if !inCat!==1 set inCat=2
    )
    if !inCat!==1 (
        echo !ln! | findstr /r "^#" >nul
        if errorlevel 1 echo !ln! | findstr /r "^\[" >nul
        if errorlevel 1 if not "!ln!"=="" if "!sample!"=="" set sample=!ln!
    )
)

REM Cek apakah sample domain sudah ada di hosts
set isActive=0
if not "%sample%"=="" (
    findstr /i "%sample%" "%hostspath%" >nul 2>&1
    if not errorlevel 1 set isActive=1
)

echo.
if %isActive%==1 (
    echo  Kategori %catname% saat ini: [AKTIF]
    set /p toggleAct="  Matikan blokir kategori ini? (y/n): "
    if /i "%toggleAct%"=="y" (
        call :CREATE_BACKUP
        set inC=0
        type nul > "%hostspath%.tmp"
        for /f "usebackq tokens=*" %%a in ("%hostspath%") do (
            set ln2=%%a
            set skip=0
            for /f "usebackq tokens=*" %%d in ("%categoriesfile%") do (
                set dn=%%d
                echo !dn! | findstr /r "^#" >nul
                if errorlevel 1 echo !dn! | findstr /r "^\[" >nul
                if errorlevel 1 (
                    if not "!dn!"=="" (
                        echo !ln2! | findstr /i "!dn!" >nul
                        if not errorlevel 1 set skip=1
                    )
                )
            )
            if !skip!==0 echo %%a >> "%hostspath%.tmp"
        )
        move /Y "%hostspath%.tmp" "%hostspath%" >nul
        call :LOG_ACTION "TOGGLE_OFF" "Category %catname% unblocked"
        call :FLUSH_DNS
        echo  Kategori %catname% berhasil DIMATIKAN.
    )
) else (
    echo  Kategori %catname% saat ini: [TIDAK AKTIF]
    set /p toggleAct="  Aktifkan blokir kategori ini? (y/n): "
    if /i "%toggleAct%"=="y" (
        call :CREATE_BACKUP
        set inC2=0
        set cnt=0
        for /f "usebackq tokens=*" %%a in ("%categoriesfile%") do (
            set ln3=%%a
            echo !ln3! | findstr /r "^\[%catname%\]" >nul
            if not errorlevel 1 set inC2=1
            echo !ln3! | findstr /r "^\[" >nul
            if not errorlevel 1 (
                echo !ln3! | findstr /r "^\[%catname%\]" >nul
                if errorlevel 1 if !inC2!==1 set inC2=0
            )
            if !inC2!==1 (
                echo !ln3! | findstr /r "^#" >nul
                if errorlevel 1 echo !ln3! | findstr /r "^\[" >nul
                if errorlevel 1 if not "!ln3!"=="" (
                    findstr /i "!ln3!" "%hostspath%" >nul 2>&1
                    if errorlevel 1 (
                        echo 127.0.0.1 !ln3! >> "%hostspath%"
                        echo 127.0.0.1 www.!ln3! >> "%hostspath%"
                        set /a cnt+=1
                    )
                )
            )
        )
        call :LOG_ACTION "TOGGLE_ON" "Category %catname% blocked - %cnt% sites"
        call :FLUSH_DNS
        echo  Kategori %catname% berhasil DIAKTIFKAN (%cnt% situs).
    )
)
pause
goto MENU

REM ============================================
REM   ADD CUSTOM
REM ============================================
:ADD_CUSTOM
cls
echo.
echo  TAMBAH WEBSITE
echo  ==============
echo  Masukkan satu atau lebih domain, pisah dengan koma.
echo  Contoh: tiktok.com,facebook.com
echo.
set /p customSites="  Domain: "

if "%customSites%"=="" (
    echo  Domain tidak boleh kosong!
    pause
    goto MENU
)

call :CREATE_BACKUP
set addcount=0

REM Parse CSV input
set templist=%customSites%
:ADD_LOOP
for /f "tokens=1* delims=," %%a in ("%templist%") do (
    set site=%%a
    set templist=%%b
    REM Strip spaces
    set site=!site: =!
    if not "!site!"=="" (
        findstr /i "!site!" "%hostspath%" >nul 2>&1
        if errorlevel 1 (
            echo 127.0.0.1 !site! >> "%hostspath%"
            echo 127.0.0.1 www.!site! >> "%hostspath%"
            echo !site! >> "%websitesfile%"
            set /a addcount+=1
            echo  + !site! ditambahkan
        ) else (
            echo  ~ !site! sudah ada di daftar blokir
        )
    )
)
if not "%templist%"=="" goto ADD_LOOP

call :LOG_ACTION "ADD_CUSTOM" "Added %addcount% sites: %customSites%"
call :FLUSH_DNS
echo.
echo  Selesai! %addcount% website ditambahkan.
pause
goto MENU

REM ============================================
REM   REMOVE SPECIFIC
REM ============================================
:REMOVE_SPECIFIC
cls
echo.
echo  HAPUS BLOKIR WEBSITE
echo  ====================
echo  Ketik sebagian nama domain, lalu konfirmasi.
echo.
set /p removeSite="  Domain (atau bagian dari nama): "

if "%removeSite%"=="" (
    echo  Domain tidak boleh kosong!
    pause
    goto MENU
)

echo.
echo  Website yang akan dihapus dari blokir:
findstr /i "%removeSite%" "%hostspath%" | findstr /v "localhost"
echo.
set /p removeConfirm="  Hapus semua yang cocok? (y/n): "
if /i not "%removeConfirm%"=="y" goto MENU

call :CREATE_BACKUP
type nul > "%hostspath%.tmp"
for /f "usebackq tokens=*" %%a in ("%hostspath%") do (
    set line=%%a
    echo !line! | findstr /i "%removeSite%" >nul
    if errorlevel 1 echo %%a >> "%hostspath%.tmp"
)
move /Y "%hostspath%.tmp" "%hostspath%" >nul

call :LOG_ACTION "REMOVE_SPECIFIC" "Removed entries matching: %removeSite%"
call :FLUSH_DNS
echo  Blokir untuk '%removeSite%' berhasil dihapus!
pause
goto MENU

REM ============================================
REM   VIEW ACTIVE
REM ============================================
:VIEW_ACTIVE
cls
echo.
echo  DAFTAR WEBSITE DIBLOKIR
echo  =======================
echo.
set n=0
for /f "tokens=2" %%a in ('findstr /i "127.0.0.1" "%hostspath%" ^| findstr /v "localhost"') do (
    set /a n+=1
    echo  !n!. %%a
)
if %n%==0 echo  Tidak ada website yang diblokir saat ini.
echo.
echo  Total: %n% entri
pause
goto MENU

REM ============================================
REM   VIEW LOG
REM ============================================
:VIEW_LOG
cls
echo.
echo  LOG HISTORY (20 terakhir)
echo  =========================
echo.

if exist "%logdir%\block_log.txt" (
    REM Tampilkan 20 baris terakhir
    set loglines=
    set lcount=0
    for /f "usebackq tokens=*" %%a in ("%logdir%\block_log.txt") do (
        set /a lcount+=1
        set loglines=%%a
    )
    REM Simple: tampilkan semua, user bisa scroll
    more "%logdir%\block_log.txt"
) else (
    echo  Belum ada log history.
)
echo.
pause
goto MENU

REM ============================================
REM   SCHEDULE MENU (NEW)
REM ============================================
:SCHEDULE_MENU
cls
echo.
echo  JADWAL OTOMATIS
echo  ===============
echo  Buat jadwal Windows Task Scheduler untuk
echo  mengaktifkan/menonaktifkan blokir secara otomatis.
echo.
echo   [1] Blokir otomatis saat startup Windows
echo   [2] Buka blokir otomatis saat startup
echo   [3] Jadwal blokir harian (jam tertentu)
echo   [4] Lihat jadwal aktif
echo   [5] Hapus semua jadwal
echo   [6] Kembali
echo.
set /p schChoice="  Pilihan: "

if "%schChoice%"=="1" goto SCH_STARTUP_BLOCK
if "%schChoice%"=="2" goto SCH_STARTUP_UNBLOCK
if "%schChoice%"=="3" goto SCH_DAILY
if "%schChoice%"=="4" goto SCH_VIEW
if "%schChoice%"=="5" goto SCH_DELETE
if "%schChoice%"=="6" goto MENU
goto SCHEDULE_MENU

:SCH_STARTUP_BLOCK
echo.
echo  Membuat jadwal blokir saat startup...
schtasks /create /tn "WebBlocker_Startup_Block" /tr "cmd /c '%~f0'" /sc ONLOGON /f >nul
if not errorlevel 1 (
    echo  Jadwal startup blokir berhasil dibuat!
    call :LOG_ACTION "SCHEDULE" "Startup block task created"
) else (
    echo  Gagal membuat jadwal. Coba jalankan sebagai Administrator.
)
pause
goto SCHEDULE_MENU

:SCH_STARTUP_UNBLOCK
echo.
echo  Membuat jadwal buka blokir saat startup...
schtasks /create /tn "WebBlocker_Startup_Unblock" /tr "cmd /c 'cd /d %scriptdir% && call unblock_web.bat'" /sc ONLOGON /f >nul
if not errorlevel 1 (
    echo  Jadwal startup unblokir berhasil dibuat!
    call :LOG_ACTION "SCHEDULE" "Startup unblock task created"
) else (
    echo  Gagal membuat jadwal.
)
pause
goto SCHEDULE_MENU

:SCH_DAILY
echo.
set /p schHour="  Jam mulai blokir (0-23, contoh: 22 untuk jam 10 malam): "
set /p schHour2="  Jam buka blokir (0-23, contoh: 6 untuk jam 6 pagi): "
echo.
schtasks /create /tn "WebBlocker_Daily_Block" /tr "cmd /c cd /d %scriptdir%" /sc DAILY /st %schHour%:00 /f >nul
if not errorlevel 1 echo  Jadwal blokir jam %schHour%:00 dibuat!
echo.
call :LOG_ACTION "SCHEDULE" "Daily block at %schHour%:00, unblock at %schHour2%:00"
pause
goto SCHEDULE_MENU

:SCH_VIEW
echo.
echo  Jadwal WebBlocker aktif:
schtasks /query /fo list /v 2>nul | findstr /i "webblocker"
pause
goto SCHEDULE_MENU

:SCH_DELETE
echo.
set /p delSch="  Hapus semua jadwal WebBlocker? (y/n): "
if /i "%delSch%"=="y" (
    schtasks /delete /tn "WebBlocker_Startup_Block" /f >nul 2>&1
    schtasks /delete /tn "WebBlocker_Startup_Unblock" /f >nul 2>&1
    schtasks /delete /tn "WebBlocker_Daily_Block" /f >nul 2>&1
    echo  Semua jadwal WebBlocker dihapus.
    call :LOG_ACTION "SCHEDULE" "All schedules deleted"
)
pause
goto SCHEDULE_MENU

REM ============================================
REM   RESTORE BACKUP
REM ============================================
:RESTORE_BACKUP
cls
echo.
echo  RESTORE DARI BACKUP
echo  ===================
echo.
echo  Daftar backup tersedia:
echo.
dir /b /o-d "%backupdir%\*.bak" 2>nul
if errorlevel 1 (
    echo  Tidak ada backup.
    pause
    goto MENU
)
echo.
set /p backupFile="  Nama file backup (atau 'latest'): "

if /i "%backupFile%"=="latest" (
    for /f "delims=" %%a in ('dir /b /o-d "%backupdir%\*.bak" 2^>nul') do (
        set backupFile=%%a
        goto :RESTORE_EXECUTE
    )
)

:RESTORE_EXECUTE
if not exist "%backupdir%\%backupFile%" (
    echo  File backup tidak ditemukan!
    pause
    goto MENU
)
copy /Y "%backupdir%\%backupFile%" "%hostspath%" >nul
call :LOG_ACTION "RESTORE" "Restored from %backupFile%"
call :FLUSH_DNS
echo  Restore dari '%backupFile%' berhasil!
pause
goto MENU

REM ============================================
REM   SETTINGS
REM ============================================
:SETTINGS
cls
echo.
echo  PENGATURAN
echo  ==========
echo   [1] Edit daftar website (Notepad)
echo   [2] Edit kategori (Notepad)
echo   [3] Bersihkan backup lama (simpan 5 terbaru)
echo   [4] Buka folder backups
echo   [5] Buka folder logs
echo   [6] Reset ke default
echo   [7] Kembali
echo.
set /p setChoice="  Pilihan: "

if "%setChoice%"=="1" notepad "%websitesfile%" & goto SETTINGS
if "%setChoice%"=="2" notepad "%categoriesfile%" & goto SETTINGS
if "%setChoice%"=="3" call :CLEANUP_BACKUPS & goto SETTINGS
if "%setChoice%"=="4" explorer "%backupdir%" & goto SETTINGS
if "%setChoice%"=="5" explorer "%logdir%" & goto SETTINGS
if "%setChoice%"=="6" (
    set /p resetConfirm="  Yakin reset ke default? Websites.txt akan direset. (y/n): "
    if /i "!resetConfirm!"=="y" (
        call :CREATE_DEFAULT_WEBSITES
        call :CREATE_DEFAULT_CATEGORIES
        echo  Reset selesai.
    )
    pause
    goto SETTINGS
)
if "%setChoice%"=="7" goto MENU
goto SETTINGS

REM ============================================
REM   HELPERS
REM ============================================
:CREATE_BACKUP
for /f "tokens=2 delims==" %%a in ('wmic os get localdatetime /value') do set dt=%%a
set timestamp=%dt:~0,8%_%dt:~8,6%
copy /Y "%hostspath%" "%backupdir%\hosts_%timestamp%.bak" >nul
echo  Backup dibuat: hosts_%timestamp%.bak
goto :EOF

:CLEANUP_BACKUPS
set bcount=0
for /f "delims=" %%a in ('dir /b /o-d "%backupdir%\*.bak" 2^>nul') do (
    set /a bcount+=1
    if !bcount! GTR 5 del "%backupdir%\%%a" >nul 2>&1
)
echo  Backup dibersihkan, tersisa 5 terbaru.
goto :EOF

:FLUSH_DNS
echo  Membersihkan cache DNS...
ipconfig /flushdns >nul
echo  Cache DNS dibersihkan.
goto :EOF

:LOG_ACTION
set logfile=%logdir%\block_log.txt
echo [%date% %time%] %~1: %~2 >> "%logfile%"
goto :EOF

:CREATE_DEFAULT_WEBSITES
(
echo # Website Blocker - Default List
echo # Tambahkan domain tanpa www, satu per baris
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
echo discord.com
echo.
echo [ECOMMERCE]
echo shopee.co.id
echo tokopedia.com
echo lazada.co.id
echo bukalapak.com
echo blibli.com
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
echo.
echo [NEWS]
echo detik.com
echo kompas.com
echo tribunnews.com
echo liputan6.com
echo okezone.com
echo kumparan.com
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
echo  Terima kasih telah menggunakan Website Blocker Manager!
echo.
timeout /t 2 >nul
exit
