# 🚫 Website Blocker Manager v2.0

Tool powerful untuk memblokir website melalui modifikasi file hosts di Windows. Dilengkapi dengan menu interaktif, sistem kategori, backup otomatis, dan banyak fitur lainnya.

![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Version](https://img.shields.io/badge/version-2.0-orange)

## ✨ Fitur Utama

### 🎯 Fitur Blocking
- **Block All**: Blokir semua website dalam daftar sekaligus
- **Block by Category**: Blokir berdasarkan kategori (Social Media, E-Commerce, Gaming, dll)
- **Custom Website**: Tambah website spesifik yang ingin diblokir
- **Selective Unblock**: Hapus blokir untuk website tertentu saja

### 💾 Backup & Restore
- **Timestamped Backup**: Backup otomatis dengan timestamp setiap kali melakukan perubahan
- **Multiple Backups**: Simpan beberapa backup sekaligus
- **Easy Restore**: Kembalikan ke backup tertentu atau backup terbaru

### 📊 Monitoring
- **View Active Blocks**: Lihat daftar website yang sedang diblokir
- **Activity Log**: Catat semua aktivitas blocking/unblocking dengan timestamp
- **History Tracking**: Lacak perubahan yang pernah dilakukan

### ⚙️ Konfigurasi
- **External Website List**: Edit daftar website via `websites.txt`
- **Category System**: Kelompokkan website berdasarkan kategori di `categories.ini`
- **User Settings**: Konfigurasi perilaku aplikasi via `config.ini`
- **Easy Management**: Edit file teks untuk customisasi tanpa perlu edit script

## 📋 Persyaratan

- Windows 10 atau Windows 11
- Hak akses Administrator
- File hosts yang dapat dimodifikasi

## 🚀 Cara Penggunaan

### Quick Start

1. **Download/Clone repository ini**
   ```bash
   git clone https://github.com/adeism/blokir-web-bat.git
   cd blokir-web-bat
   ```

2. **Jalankan script utama**
   - Klik kanan `block_web.bat`
   - Pilih **"Run as Administrator"**
   - Atau double-click (akan auto-elevate)

3. **Pilih menu yang diinginkan**
   ```
   1. Blokir Semua Website
   2. Blokir Berdasarkan Kategori
   3. Tambah Website Custom
   4. Hapus Blokir Spesifik
   5. Lihat Daftar Blokir Aktif
   6. Lihat Log History
   7. Restore dari Backup
   8. Pengaturan
   9. Keluar
   ```

### Blokir Semua Website

1. Pilih menu **1** dari menu utama
2. Script akan otomatis:
   - Membuat backup hosts file
   - Menambahkan semua website dari `websites.txt`
   - Flush DNS cache
   - Mencatat aktivitas ke log
3. Restart browser untuk melihat efek

### Blokir Berdasarkan Kategori

1. Pilih menu **2**
2. Pilih kategori:
   - **1**: Social Media (Facebook, Instagram, TikTok, dll)
   - **2**: E-Commerce (Shopee, Tokopedia, Lazada, dll)
   - **3**: Gaming (Roblox, Epic Games, Steam, dll)
   - **4**: Streaming (YouTube, Netflix, Spotify, dll)
   - **5**: News (Detik, Kompas, Tribunnews, dll)
3. Script akan memblokir hanya website dalam kategori tersebut

### Tambah Website Custom

1. Pilih menu **3**
2. Masukkan domain (tanpa www), contoh: `example.com`
3. Website akan ditambahkan ke hosts file dan `websites.txt`

### Restore/Unblock

#### Restore dari Backup
1. Pilih menu **7**
2. Pilih file backup yang ingin di-restore
3. Atau ketik `latest` untuk backup terbaru

#### Unblock Semua (Quick Restore)
1. Jalankan `unblock_web.bat` sebagai Administrator
2. Script akan otomatis restore dari backup terbaru

## 📁 Struktur File

```
blokir-web-bat/
├── block_web.bat          # Script utama dengan menu interaktif
├── unblock_web.bat        # Script restore cepat
├── websites.txt           # Daftar website (editable)
├── categories.ini         # Kategori website (editable)
├── config.ini             # Konfigurasi aplikasi
├── logs/                  # Folder log aktivitas
│   └── block_log.txt      # File log
├── backups/               # Folder backup otomatis
│   ├── hosts_20260130_083000.bak
│   └── hosts_20260130_091500.bak
└── README.md              # Dokumentasi (file ini)
```

## ⚙️ Konfigurasi

### Edit Daftar Website

Edit file `websites.txt`:
```
# Website Blocker - Default List
# Tambahkan website tanpa www, satu per baris
# Gunakan # untuk komentar

facebook.com
instagram.com
yourdomain.com
```

### Edit Kategori

Edit file `categories.ini`:
```ini
[SOCIAL_MEDIA]
facebook.com
instagram.com
tiktok.com

[CUSTOM_CATEGORY]
website1.com
website2.com
```

### Edit Pengaturan

Edit file `config.ini`:
```ini
# Auto Backup: 1=Aktif, 0=Nonaktif
AUTO_BACKUP=1

# Maksimal backup yang disimpan
MAX_BACKUPS=5

# Logging: 1=Aktif, 0=Nonaktif
LOG_ENABLED=1
```

## 🔧 Troubleshooting

### Website masih bisa diakses setelah diblokir

**Solusi:**
1. Clear cache browser:
   - Chrome: `Ctrl + Shift + Delete`
   - Firefox: `Ctrl + Shift + Delete`
   - Edge: `Ctrl + Shift + Delete`
2. Restart browser
3. Coba akses dalam mode Incognito/Private
4. Flush DNS manual: `ipconfig /flushdns` di CMD

### Script tidak bisa dijalankan

**Solusi:**
1. Pastikan menjalankan sebagai Administrator
2. Nonaktifkan antivirus sementara
3. Periksa apakah file hosts tidak di-lock oleh program lain
4. Cek permission folder `C:\Windows\System32\drivers\etc`

### Backup tidak terbuat

**Solusi:**
1. Periksa permission folder `backups`
2. Pastikan ada space disk yang cukup
3. Jalankan dengan hak Administrator

### File hosts tidak bisa dimodifikasi

**Solusi:**
1. Nonaktifkan antivirus/Windows Defender sementara
2. Hapus attribute read-only pada file hosts:
   ```cmd
   attrib -r C:\Windows\System32\drivers\etc\hosts
   ```
3. Periksa permission file dengan klik kanan > Properties > Security

## 🛡️ Keamanan

### Cara Kerja
Script ini bekerja dengan:
1. Menambahkan entry `127.0.0.1 domain.com` ke file hosts Windows
2. Membuat backup sebelum setiap perubahan
3. Flush DNS cache untuk aplikasi langsung

### Aman atau Tidak?
- ✅ **100% Aman**: Hanya memodifikasi file hosts sistem
- ✅ **Reversible**: Bisa dikembalikan kapan saja
- ✅ **No Malware**: Open source, bisa diperiksa kodenya
- ✅ **No Network**: Tidak mengirim data ke internet

### Batasan
- Hanya bekerja di device lokal
- Tidak bekerja jika website menggunakan IP address langsung
- Tidak bekerja jika ada VPN/proxy yang bypass hosts file
- Mudah di-bypass oleh user yang tech-savvy

## 💡 Tips & Tricks

### Untuk Orang Tua
- Gunakan kategori untuk memblokir akses anak ke social media saat jam belajar
- Combine dengan Windows Parental Controls untuk hasil maksimal
- Simpan backup dan jangan beri tahu lokasi script ke anak

### Untuk Produktivitas
- Blokir social media saat jam kerja
- Gunakan dengan Pomodoro technique
- Buat kategori custom untuk website yang menggangu fokus

### Untuk Admin/IT
- Deploy script ini ke multiple PC via Group Policy
- Gunakan categories.ini untuk manajemen centralized
- Schedule backup regular dengan Task Scheduler

## 🔄 Changelog

### Version 2.0 (Current)
- ✅ Menu interaktif
- ✅ Sistem kategori
- ✅ Timestamped backup
- ✅ Activity logging
- ✅ External configuration files
- ✅ Selective block/unblock
- ✅ Auto-elevate Administrator
- ✅ Multiple restore points

### Version 1.0
- ✅ Basic block all
- ✅ Simple restore
- ✅ Hardcoded website list

## 🤝 Kontribusi

Kontribusi sangat diterima! Silakan:

1. Fork repository ini
2. Buat branch fitur (`git checkout -b feature/AmazingFeature`)
3. Commit perubahan (`git commit -m 'Add some AmazingFeature'`)
4. Push ke branch (`git push origin feature/AmazingFeature`)
5. Buat Pull Request

### Ide Kontribusi
- [ ] GUI version dengan PowerShell Forms
- [ ] Schedule blocking (time-based)
- [ ] Password protection untuk unblock
- [ ] Cloud sync konfigurasi
- [ ] Export/import configuration
- [ ] Statistics dan analytics
- [ ] Whitelist mode
- [ ] Support untuk Linux/Mac

## 📝 License

MIT License - Feel free to use, modify, and distribute.

## 👨‍💻 Author

**adeism**
- GitHub: [@adeism](https://github.com/adeism)
- Repository: [blokir-web-bat](https://github.com/adeism/blokir-web-bat)

## ⭐ Support

Jika project ini membantu, berikan ⭐ di GitHub!

## 📞 Support & FAQ

### Pertanyaan Umum

**Q: Apakah ini bekerja di Windows 11?**  
A: Ya, 100% kompatibel dengan Windows 10 dan 11.

**Q: Apakah data saya aman?**  
A: Ya, script ini hanya memodifikasi file hosts lokal dan tidak mengirim data kemana-mana.

**Q: Bisa digunakan untuk network/router?**  
A: Tidak, ini hanya bekerja di device lokal. Untuk network-wide blocking, gunakan Pi-Hole.

**Q: Apakah gratis?**  
A: Ya, 100% gratis dan open source.

**Q: Bisa request fitur?**  
A: Tentu! Buat issue di GitHub atau submit pull request.

---

**Made with ❤️ for productivity and focus**
