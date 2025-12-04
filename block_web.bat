@echo off
Title Blokir Website - Windows 11
color 0c

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
echo Membuat backup file hosts asli ke hosts.bak...
copy /Y "%hostspath%" "%hostspath%.bak"

echo.
echo Sedang menambahkan daftar blokir...

REM --- DAFTAR WEBSITE ---
(
echo 127.0.0.1 blibli.com
echo 127.0.0.1 bukalapak.com
echo 127.0.0.1 canary.discord.com
echo 127.0.0.1 community.steampowered.com
echo 127.0.0.1 detik.com
echo 127.0.0.1 discord.com
echo 127.0.0.1 disneyplus.com
echo 127.0.0.1 epicgames.com
echo 127.0.0.1 facebook.com
echo 127.0.0.1 fb.com
echo 127.0.0.1 hulu.com
echo 127.0.0.1 idntimes.com
echo 127.0.0.1 instagram.com
echo 127.0.0.1 jd.id
echo 127.0.0.1 kapanlagi.com
echo 127.0.0.1 kompas.com
echo 127.0.0.1 kumparan.com
echo 127.0.0.1 lazada.co.id
echo 127.0.0.1 linkedin.com
echo 127.0.0.1 liputan6.com
echo 127.0.0.1 m.blibli.com
echo 127.0.0.1 m.bukalapak.com
echo 127.0.0.1 m.detik.com
echo 127.0.0.1 m.facebook.com
echo 127.0.0.1 m.idntimes.com
echo 127.0.0.1 m.instagram.com
echo 127.0.0.1 m.jd.id
echo 127.0.0.1 m.lazada.co.id
echo 127.0.0.1 m.linkedin.com
echo 127.0.0.1 m.liputan6.com
echo 127.0.0.1 m.netflix.com
echo 127.0.0.1 m.okezone.com
echo 127.0.0.1 m.quora.com
echo 127.0.0.1 m.reddit.com
echo 127.0.0.1 m.roblox.com
echo 127.0.0.1 m.shopee.co.id
echo 127.0.0.1 m.sindonews.com
echo 127.0.0.1 m.tiktok.com
echo 127.0.0.1 m.tokopedia.com
echo 127.0.0.1 m.twitch.tv
echo 127.0.0.1 m.wattpad.com
echo 127.0.0.1 m.youtube.com
echo 127.0.0.1 medium.com
echo 127.0.0.1 music.youtube.com
echo 127.0.0.1 netflix.com
echo 127.0.0.1 news.detik.com
echo 127.0.0.1 news.tribunnews.com
echo 127.0.0.1 okezone.com
echo 127.0.0.1 old.reddit.com
echo 127.0.0.1 spotify.com
echo 127.0.0.1 pin.it
echo 127.0.0.1 pinterest.com
echo 127.0.0.1 primevideo.com
echo 127.0.0.1 ptb.discord.com
echo 127.0.0.1 quora.com
echo 127.0.0.1 reddit.com
echo 127.0.0.1 roblox.com
echo 127.0.0.1 seller.jd.id
echo 127.0.0.1 seller.lazada.co.id
echo 127.0.0.1 seller.shopee.co.id
echo 127.0.0.1 seller.tokopedia.com
echo 127.0.0.1 shopee.co.id
echo 127.0.0.1 sindonews.com
echo 127.0.0.1 steampowered.com
echo 127.0.0.1 store.epicgames.com
echo 127.0.0.1 store.steampowered.com
echo 127.0.0.1 studio.youtube.com
echo 127.0.0.1 suara.com
echo 127.0.0.1 telegram.org
echo 127.0.0.1 tiktok.com
echo 127.0.0.1 tokopedia.com
echo 127.0.0.1 tribunnews.com
echo 127.0.0.1 twitch.tv
echo 127.0.0.1 twitter.com
echo 127.0.0.1 vt.tiktok.com
echo 127.0.0.1 wattpad.com
echo 127.0.0.1 web.telegram.org
echo 127.0.0.1 www.blibli.com
echo 127.0.0.1 www.bukalapak.com
echo 127.0.0.1 www.detik.com
echo 127.0.0.1 www.discord.com
echo 127.0.0.1 www.disneyplus.com
echo 127.0.0.1 www.epicgames.com
echo 127.0.0.1 www.facebook.com
echo 127.0.0.1 www.fb.com
echo 127.0.0.1 www.hulu.com
echo 127.0.0.1 www.idntimes.com
echo 127.0.0.1 www.instagram.com
echo 127.0.0.1 www.jd.id
echo 127.0.0.1 www.kapanlagi.com
echo 127.0.0.1 www.kompas.com
echo 127.0.0.1 www.kumparan.com
echo 127.0.0.1 www.lazada.co.id
echo 127.0.0.1 www.linkedin.com
echo 127.0.0.1 www.liputan6.com
echo 127.0.0.1 www.medium.com
echo 127.0.0.1 www.netflix.com
echo 127.0.0.1 www.okezone.com
echo 127.0.0.1 www.pinterest.com
echo 127.0.0.1 www.primevideo.com
echo 127.0.0.1 www.quora.com
echo 127.0.0.1 www.reddit.com
echo 127.0.0.1 www.roblox.com
echo 127.0.0.1 www.shopee.co.id
echo 127.0.0.1 www.sindonews.com
echo 127.0.0.1 www.spotify.com
echo 127.0.0.1 www.steampowered.com
echo 127.0.0.1 www.suara.com
echo 127.0.0.1 www.telegram.org
echo 127.0.0.1 www.tiktok.com
echo 127.0.0.1 www.tokopedia.com
echo 127.0.0.1 www.tribunnews.com
echo 127.0.0.1 www.twitch.tv
echo 127.0.0.1 www.twitter.com
echo 127.0.0.1 www.wattpad.com
echo 127.0.0.1 www.x.com
echo 127.0.0.1 www.youtube.com
echo 127.0.0.1 x.com
echo 127.0.0.1 youtube.com
echo 127.0.0.1 youtubekids.com
) >> "%hostspath%"

echo.
echo Membersihkan cache DNS...
ipconfig /flushdns

echo.
echo Selesai! Website telah diblokir.
echo Silakan restart browser kamu untuk melihat efeknya.
pause
