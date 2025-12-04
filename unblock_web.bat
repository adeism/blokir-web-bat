@echo off
Title Buka Blokir Website (Restore)
color 0a

REM Cek hak akses Administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Menjalankan sebagai Administrator...
) else (
    echo Gagal: Harap klik kanan file ini dan pilih "Run as Administrator".
    pause
    exit
)

set hostspath=%windir%\System32\drivers\etc\hosts

echo.
echo Memeriksa file backup (hosts.bak)...

if exist "%hostspath%.bak" (
    echo File backup ditemukan. Mengembalikan pengaturan awal...
    copy /Y "%hostspath%.bak" "%hostspath%"
    
    echo.
    echo Membersihkan cache DNS...
    ipconfig /flushdns
    
    echo.
    echo Berhasil! Website sudah bisa diakses kembali.
    echo Silakan restart browser.
) else (
    echo.
    echo Gagal: File backup "hosts.bak" tidak ditemukan.
    echo Anda mungkin harus mengedit file hosts secara manual atau file backup sudah terhapus.
)

pause
