# Website Blocker Manager v3.0

> Blokir daftar situs web dengan memodifikasi file `hosts` di Windows. Ringan, tanpa install, langsung jalan.

## ✨ Fitur v3.0

| Fitur | v2.0 | v3.0 |
|---|---|---|
| Blokir semua website | ✅ | ✅ |
| Blokir per kategori | ✅ | ✅ |
| **Toggle kategori ON/OFF 1 langkah** | ❌ | ✅ |
| **Buka semua blokir cepat** | ❌ | ✅ |
| **Tambah multiple domain sekaligus** | ❌ | ✅ |
| **Status live di menu utama** | ❌ | ✅ |
| **Cegah duplikat blokir** | ❌ | ✅ |
| **Konfirmasi sebelum hapus** | ❌ | ✅ |
| **Preview sebelum hapus spesifik** | ❌ | ✅ |
| **Jadwal otomatis (Task Scheduler)** | ❌ | ✅ |
| **Buka folder backup/log langsung** | ❌ | ✅ |
| **Auto-cleanup backup (simpan 5 terbaru)** | ❌ | ✅ |
| Backup otomatis setiap aksi | ✅ | ✅ |
| Log history | ✅ | ✅ |
| Restore dari backup | ✅ | ✅ |

## 📂 File yang Digunakan

```
blokir-web-bat/
├── block_web.bat       # Menu utama
├── unblock_web.bat     # Buka semua blokir (standalone)
├── websites.txt        # Daftar domain yang diblokir
├── categories.ini      # Kelompok kategori website
├── config.ini          # Konfigurasi
├── backups/            # Backup otomatis hosts
├── logs/               # Log semua aksi
└── schedules/          # Folder untuk data jadwal
```

## 🚀 Cara Pakai

1. **Klik kanan** `block_web.bat` → **Run as administrator**
2. Pilih menu yang diinginkan:

### Menu Utama

```
---- AKSI CEPAT ----
[1] Blokir SEMUA sekarang
[2] Buka SEMUA blokir
[3] Toggle kategori (pilih dan langsung on/off)

---- KELOLA ----
[4] Tambah website
[5] Hapus blokir satu website
[6] Lihat daftar website diblokir
[7] Lihat log history

---- LANJUTAN ----
[8] Jadwalkan blokir otomatis
[9] Restore backup
[0] Pengaturan
[Q] Keluar
```

### Tips

- **Tambah banyak domain sekaligus**: Pisahkan dengan koma → `tiktok.com,facebook.com,youtube.com`
- **Toggle cepat**: Menu `[3]` untuk ON/OFF satu kategori tanpa langkah panjang
- **Unblock darurat**: Jalankan langsung `unblock_web.bat` tanpa buka menu utama
- **Jadwal otomatis**: Menu `[8]` untuk atur blokir saat startup atau jam tertentu

## ✏️ Tambah Website Kustom

Edit `websites.txt`, tambah domain satu per baris:

```
# Ini komentar
games.com
sosmed-baru.com
```

## 🗂️ Tambah Kategori Baru

Edit `categories.ini`:

```ini
[NAMA_KATEGORI]
domain1.com
domain2.com
```

## ⚠️ Catatan

- Wajib dijalankan sebagai **Administrator**
- File yang dimodifikasi: `C:\Windows\System32\drivers\etc\hosts`
- Backup otomatis dibuat sebelum setiap perubahan
- Hanya backup **5 terbaru** yang disimpan (otomatis dibersihkan)

## 📋 Lisensi

MIT License — bebas digunakan dan dimodifikasi.
