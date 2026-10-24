# 📚 TugasKu — Student Schedule & Task Manager

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Hive-Local%20DB-FDB913?style=for-the-badge" alt="Hive" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-blue?style=for-the-badge" alt="Platform" />
  <img src="https://img.shields.io/badge/Version-1.3.0-brightgreen?style=for-the-badge" alt="Version" />
  <img src="https://img.shields.io/badge/Theme-Rainy%20Garden%20%26%20Matcha-2E3A42?style=for-the-badge" alt="Theme" />
</p>

---

## 🌟 Tentang TugasKu

**TugasKu** adalah aplikasi manajemen jadwal perkuliahan dan tugas harian yang dirancang khusus untuk mahasiswa agar tetap produktif, teratur, dan tidak ketinggalan deadline. 

Dibangun secara *offline-first* menggunakan **Flutter** dan database lokal **Hive**, TugasKu hadir dengan palet warna bernuansa **Rainy Garden & Matcha Paper** yang sejuk dan nyaman di mata, ditemani maskot **"Lumut"** yang interaktif, serta dilengkapi fitur **In-App Auto-Update langsung dari GitHub Releases**.

---

## ✨ Fitur Utama

### 1. 🏠 Dashboard Pintar
- **Hero Countdown Card:** Menampilkan jadwal kuliah terdekat secara *real-time* dengan hitung mundur dinamis (misal: *"dalam 30 Menit"* atau *"Sedang berlangsung"*), lengkap dengan badge jam, ruangan, jumlah SKS, dan nama dosen pengampu.
- **Sapaan Maskot Lumut:** Maskot Lumut yang melambai menyapa di header profil pengguna.
- **Tinjauan Tugas Mendesak:** Menampilkan daftar tugas yang belum tuntas, dengan kemampuan menyelesaikan tugas langsung lewat centang di beranda.
- **State Selesai Menenangkan:** Saat semua kuliah hari ini tuntas, kartu hero bertransformasi menampilkan Lumut yang sedang santai menikmati matcha.

### 2. 📅 Jadwal Kuliah Mingguan
- **Filter Hari Interaktif:** Navigasi cepat antara hari Senin hingga Sabtu dengan chip tanggal mingguan dinamis.
- **Informasi Akademik Lengkap:** Menampilkan mata kuliah, nama dosen pengampu, badge jenis (Teori/Praktikum/Asprak), badge ruangan, dan badge SKS.
- **Indikator Kelas Aktif:** Penanda visual highlight otomatis pada sesi kuliah yang sedang berlangsung.
- **Form Tambah Jadwal Ringkas:** Form bottom-sheet yang dikelompokkan secara logis dan hemat ruang (input Ruang & SKS berdampingan).

### 3. ✅ Pengelola & Pelacak Tugas (Task Manager)
- **Detail & Edit Tugas Interaktif:** Ketuk kartu tugas kapan saja untuk melihat detail instruksi lengkap, mengedit judul, mata kuliah, catatan tugas, mengubah deadline, hingga menandai status selesai.
- **Catatan & Instruksi Tugas Lengkap (Notes):** Kolom catatan multiline opsional untuk instruksi khusus dosen, format tugas, atau link pengumpulan, disertai indikator ikon catatan pada kartu tugas.
- **Filter Kategori:** Tinjau tugas berdasarkan *Semua*, *Belum Selesai*, dan *Selesai*.
- **Progress Bar Mingguan:** Indikator visual progres penyelesaian tugas minggu berjalan secara dinamis.
- **Pembersihan Otomatis (Auto-Cleanup):** Tugas yang sudah lewat deadline minggu sebelumnya dibersihkan secara otomatis setiap awal pekan (Senin).
- **Celebration State:** Saat seluruh tugas selesai, Lumut merayakan keberhasilanmu dengan animasi selebrasi.

### 4. 🌿 Gamifikasi & Maskot Interaktif "Lumut"
Aplikasi diperkaya dengan 11 pose ilustrasi SVG maskot **Lumut** yang hidup dan adaptif:
- 🕒 **Maskot Waktu Dinamis (Header):** Maskot di header beranda berganti ekspresi mengikuti waktu (Pagi: siap kuliah `lumut_berangkat`, Siang: `lumut_belajar`, Sore: `lumut_matcha`, Malam: `lumut_mengetik`, Larut Malam: `lumut_mengantuk`).
- 💬 **Interaktif Sapaan & Quote Motivasi:** Ketuk maskot di header kapan saja untuk mendapatkan sapaan ramah dan pesan motivasi acak dari Lumut.
- 🎉 **Task Celebration System:**
  - Tiap mencentang tugas selesai, muncul floating cheer snackbar dengan pesan apresiasi dan animasi maskot.
  - Saat **semua tugas tuntas**, dialog perayaan spesial muncul mengapresiasi kerja kerasmu!
- 🐱 **Empty States Tematik:**
  - Hari Sabtu & Minggu libur: Lumut santai bermain bersama kucing (`lumut_kucing`).
  - Semua tugas selesai: Lumut menikmati matcha hangat (`lumut_matcha`).
  - Belum ada tugas selesai: Lumut fokus mengetik (`lumut_mengetik`).

### 5. 🚀 In-App GitHub Auto-Update & Installer
- **Pengecekan Otomatis (Silent Check):** Aplikasi otomatis mengecek rilis terbaru dari repositori GitHub [`inikumadayo/TugasKu`](https://github.com/inikumadayo/TugasKu) saat pertama kali dibuka.
- **Pengecekan Manual:** Tombol *"Periksa Pembaruan"* di tab Pengaturan lengkap dengan badge versi terpasang.
- **In-App Download:** Mengunduh file APK langsung di dalam aplikasi disertai progress bar real-time (persentase & ukuran MB).
- **Auto-Install:** Otomatis memicu package installer Android untuk memasang pembaruan tanpa perlu membuka browser manual.

### 6. 🎨 Tema & Personalisasi
- **Pilihan Tema Elegan:**
  - 🌧️ **Rainy Garden (Dark):** Nuansa arang kehijauan (`#1A1F1C`), hijau lumut (`#46624D`), dan aksen amber hangat (`#E3A65C`).
  - 🍵 **Matcha Paper (Light):** Nuansa kertas lukisan tinta (`#F0EFE7`) dan hijau teh matcha yang lembut.
- **Kustomisasi Profil:** Ganti foto avatar dan banner langsung dari galeri dengan penyimpanan lokal Base64.
- **Pengingat & Suara Kustom:** Atur jeda waktu notifikasi kuliah & tugas serta pilih file audio nada dering sendiri.

---

## 🏗️ Struktur Proyek

```text
lib/
├── assets/                          # Folder aset internal
├── core/
│   ├── constants/
│   │   └── mascot_assets.dart       # Path konstanta ilustrasi maskot Lumut
│   ├── theme/
│   │   ├── app_theme.dart           # Definisi ThemeData M3 (Light & Dark)
│   │   └── colors.dart              # Palet warna Rainy Garden & Matcha Paper
│   └── utils/
│       ├── date_time_helper.dart    # Helper format tanggal, waktu, & heartbeat
│       └── image_helper.dart        # Helper kompresi & konversi Base64 gambar
├── database/
│   └── database_helper.dart         # Database helper NoSQL lokal (Hive) & listenables
├── models/
│   ├── schedule_model.dart          # Model jadwal kuliah (+ dosenPengampu & SKS)
│   ├── task_model.dart              # Model tugas kuliah
│   └── user_profile_model.dart      # Model profil pengguna
├── presentation/
│   ├── screens/
│   │   ├── dashboard.dart           # Layar Beranda utama & sapaan Lumut
│   │   ├── homepage.dart            # Navigasi tab bar bawah & reactive stack
│   │   ├── schedule.dart            # Layar Jadwal kuliah harian/mingguan
│   │   ├── setting.dart             # Layar Pengaturan, profil, tema, & cek update
│   │   └── task.dart                # Layar Daftar tugas & progress bar
│   └── widgets/
│       ├── cards/
│       │   ├── hero_card.dart       # Kartu hitung mundur jadwal kuliah terdekat
│       │   ├── schedule_item.dart   # Kartu item jadwal (badge jenis, ruang, SKS)
│       │   └── task_item.dart       # Kartu item tugas dengan checkbox
│       ├── dialogs/
│       │   ├── add_schedule_dialog.dart # Form tambah jadwal (streamlined layout)
│       │   ├── add_task_dialog.dart     # Form tambah tugas kuliah
│       │   ├── delete_confirm_dialog.dart # Dialog konfirmasi hapus data
│       │   ├── edit_profile_dialog.dart # Dialog edit nama, bio, & avatar
│       │   └── update_dialog.dart       # Dialog in-app download update & installer
│       ├── filters/
│       │   ├── filter.dart          # Filter chip kategori tugas
│       │   └── filter_date.dart     # Filter chip tanggal mingguan
│       └── sheets/
│           ├── about_sheet.dart     # Modal informasi aplikasi & kredit
│           ├── notification_config_sheet.dart # Modal konfigurasi alarm & suara
│           └── theme_picker_sheet.dart  # Modal pemilih tema Light/Dark
├── services/
│   ├── notification_service.dart    # Handler notifikasi lokal & alarm
│   └── update_service.dart          # Service GitHub Releases API & APK downloader
└── main.dart                        # Entry point aplikasi (Inisialisasi Hive & tema)
```

---

## 🛠️ Teknologi & Dependensi

| Paket | Versi | Fungsi |
|---|---|---|
| **[flutter](https://flutter.dev/)** | SDK | Framework UI multi-platform utama |
| **[hive_flutter](https://pub.dev/packages/hive_flutter)** | `^1.1.0` | Database NoSQL lokal super cepat & reactive listenables |
| **[flutter_svg](https://pub.dev/packages/flutter_svg)** | `^2.0.17` | Rendering aset vektor SVG maskot Lumut |
| **[dio](https://pub.dev/packages/dio)** | `^5.7.0` | HTTP client & downloader APK dengan progress bar |
| **[open_filex](https://pub.dev/packages/open_filex)** | `^4.5.0` | Memicu package installer Android untuk update otomatis |
| **[package_info_plus](https://pub.dev/packages/package_info_plus)** | `^10.2.2` | Membaca versi aplikasi terpasang secara dinamis |
| **[path_provider](https://pub.dev/packages/path_provider)** | `^2.1.5` | Mengakses direktori penyimpanan sementara untuk unduhan APK |
| **[flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)** | `^22.3.2` | Alarm & push notifications lokal tanpa server |
| **[timezone](https://pub.dev/packages/timezone)** | `^0.11.2` | Penanganan zona waktu akurat untuk alarm kuliah & tugas |
| **[image_picker](https://pub.dev/packages/image_picker)** | `^1.2.4` | Mengambil foto avatar dan banner profil |
| **[file_picker](https://pub.dev/packages/file_picker)** | `^13.1.0` | Memilih nada dering kustom |
| **[url_launcher](https://pub.dev/packages/url_launcher)** | `^6.3.3` | Membuka tautan GitHub & dukungan Trakteer |
| **[google_fonts](https://pub.dev/packages/google_fonts)** | `^9.0.0` | Tipografi Google Fonts |

---

## 🚀 Memulai (Getting Started)

### Prasyarat
- Flutter SDK (`^3.13.5` atau yang lebih baru)
- Dart SDK
- Android Studio / VS Code dengan ekstensi Flutter & Dart
- Perangkat Android (OS 8.0+) / Emulator

### Langkah Instalasi

1. **Clone repositori ini:**
   ```bash
   git clone https://github.com/inikumadayo/TugasKu.git
   cd TugasKu
   ```

2. **Unduh dependensi proyek:**
   ```bash
   flutter pub get
   ```

3. **Jalankan aplikasi:**
   ```bash
   flutter run
   ```

---

## 📦 Build Aplikasi (Production APK)

Untuk membuat file installer Android (APK Release):

```bash
flutter build apk --release
```

Hasil file APK release dapat ditemukan di:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 📜 Riwayat Versi (Changelog)

### v1.3.0
- 📝 **Detail & Edit Tugas Interaktif (Task Detail Dialog):**
  - Ketuk kartu tugas di Beranda atau tab Tugas untuk membuka dialog detail & editor tugas.
  - Penambahan kolom `notes` (Catatan / Instruksi Detail) opsional untuk mencatat instruksi spesifik dosen/link pengumpulan.
  - Kartu tugas menampilkan indikator ikon catatan jika tugas memiliki detail tambahan.
  - Form tambah tugas (`add_task_dialog.dart`) kini juga mendukung input catatan tugas sejak awal.
- 🌿 **Gamifikasi & Maskot Interaktif "Lumut":**
  - Maskot header dinamis mengikuti waktu hari (Pagi, Siang, Sore, Malam, Larut Malam).
  - Ketuk maskot untuk membuka dialog sapaan dan kutipan motivasi belajar dari Lumut.
  - Sistem perayaan tugas: floating cheer notification saat tugas diselesaikan, dan dialog selebrasi akbar saat seluruh tugas tuntas.
  - Empty state tematik: ilustrasi kucing di akhir pekan dan matcha saat semua tugas beres.
- ⚡ **Peningkatan Reaktivitas Edit Profil:** Edit profil kini 100% reaktif secara instan di seluruh layar via `DatabaseHelper.profileListenable()`.

---

## 🤝 Dukungan & Pengembang

Dibuat dengan ❤️ untuk membantu mahasiswa tetap terorganisir dan produktif.

- **Pengembang:** [Kumadayo](https://github.com/inikumadayo)
- **Repositori:** [github.com/inikumadayo/TugasKu](https://github.com/inikumadayo/TugasKu)
- **Dukungan Kopi:** [Trakteer Kumadayo](https://trakteer.id/kumadayo) ☕

---

## 📄 Lisensi

Proyek ini bersifat open-source dan bebas digunakan untuk keperluan pembelajaran maupun produktivitas pribadi.
