# 📚 TugasKu — Student Schedule & Task Manager

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Hive-Local%20DB-FDB913?style=for-the-badge" alt="Hive" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-blue?style=for-the-badge" alt="Platform" />
  <img src="https://img.shields.io/badge/Version-1.1.0-brightgreen?style=for-the-badge" alt="Version" />
</p>

---

## 🌟 Tentang TugasKu

**TugasKu** adalah aplikasi manajemen jadwal perkuliahan dan tugas harian yang dirancang khusus untuk mahasiswa agar tetap produktif, teratur, dan tidak ketinggalan deadline. Dibangun secara *offline-first* menggunakan Flutter dan Hive database, TugasKu menyajikan antarmuka modern bernuansa *Blueberry Oat* yang nyaman di mata, responsif, dan kaya fitur tanpa memerlukan akun ataupun koneksi internet.

---

## ✨ Fitur Utama

### 1. 🏠 Dashboard Pintar
- **Hero Countdown Card:** Menampilkan jadwal kuliah terdekat atau yang sedang berlangsung secara *real-time* lengkap dengan status hitung mundur (misal: *"dalam 30 Menit"* atau *"Sedang berlangsung"*).
- **Profil Cepat:** Akses cepat ke profil pengguna dengan foto kustom, sapaan personal, dan bio/status.
- **Daftar Tugas Mendesak:** Tinjauan langsung tugas yang belum selesai hari ini dengan kemampuan centang langsung dari beranda.

### 2. 📅 Jadwal Kuliah Mingguan
- **Filter Hari Interaktif:** Navigasi cepat antara hari Senin hingga Minggu menggunakan chip tanggal yang dinamis.
- **Indikator Kelas Aktif:** Penanda visual `ON` otomatis pada mata kuliah yang sedang berlangsung.
- **Detail Lengkap:** Informasi mata kuliah mencakup nama matkul, kode/ruang kelas, jam mulai & selesai, jenis sesi (Teori/Praktikum), hingga dosen pengampu.
- **Manajemen Jadwal:** Tambah, ubah, dan hapus jadwal dengan konfirmasi dialog yang aman.

### 3. ✅ Pengelola & Pelacak Tugas (Task Manager)
- **Kategori & Filter:** Filter tugas berdasarkan *Semua*, *Belum Selesai*, dan *Selesai*.
- **Progress Bar Mingguan:** Indikator visual progres penyelesaian tugas minggu berjalan secara dinamis.
- **Auto-Cleanup Tugas Kedaluwarsa:** Pembersihan otomatis tugas mingguan yang sudah lewat agar daftar tetap rapi.
- **Sisa Waktu Real-Time:** Penanda deadline yang informatif dan mudah dipahami.

### 4. 🔔 Notifikasi Lokal (Offline Push Notifications)
- **Pengingat Kelas:** Pemberitahuan otomatis sebelum perkuliahan dimulai agar tidak terlambat hadir.
- **Pengingat Tugas:** Alarm notifikasi pengingat batas waktu penyelesaian tugas kuliah.
- **Dukungan Timezone:** Menggunakan standar waktu lokal (`Asia/Jakarta`) yang akurat tanpa butuh server eksternal.

### 5. 🎨 Personalisasi & Tema
- **Pilihan Tema Warna:**
  - 🫐 **Blueberry Oat (Light):** Nuansa hangat, lembut, dan elegan.
  - 🌙 **Blueberry Oat Dark (Dark):** Nuansa gelap kontras tinggi yang nyaman di malam hari.
- **Kustomisasi Profil:** Ganti foto avatar dari galeri/kamera (disimpan dalam format Base64 di penyimpanan lokal) serta ubah nama dan moto/status kapan saja.

### 6. 💾 Backup & Restore Data
- **Ekspor Data:** Cadangkan seluruh jadwal, tugas, profil, dan preferensi aplikasi ke file cadangan JSON.
- **Impor Data:** Pulihkan data cadangan kapan saja dengan mudah melalui file picker.

---

## 🏗️ Struktur Folder

```text
lib/
├── assets/
│   └── colors.dart                  # Palet warna tema (Light & Dark)
├── database/
│   └── database_helper.dart         # Wrapper CRUD NoSQL lokal (Hive)
├── models/
│   ├── schedule_model.dart          # Data model jadwal kuliah
│   ├── task_model.dart              # Data model tugas kuliah
│   └── user_profile_model.dart      # Data model profil pengguna
├── pages/
│   ├── dashboard.dart               # Tampilan beranda & ringkasan
│   ├── homepage.dart                # Navigasi tab utama (BottomNavigationBar)
│   ├── schedule.dart                # Halaman jadwal kuliah harian & mingguan
│   ├── setting.dart                 # Pengaturan profil, tema, notifikasi, & backup
│   └── task.dart                    # Halaman daftar & progres tugas
├── services/
│   └── notification_service.dart    # Konfigurasi & handler Flutter Local Notifications
├── utils/
│   ├── about_sheet.dart             # Modal bottom sheet 'Tentang TugasKu'
│   ├── add_schedule_dialog.dart     # Dialog tambah/edit jadwal
│   ├── add_task_dialog.dart         # Dialog tambah tugas
│   ├── delete_confirm_dialog.dart   # Dialog konfirmasi hapus data
│   ├── edit_profile_dialog.dart     # Dialog pengaturan profil & foto pengguna
│   ├── filter.dart                  # Widget filter chip kategori & tanggal
│   ├── hero.dart                    # Widget banner jadwal terdekat di Dashboard
│   ├── notification_config_sheet.dart # Modal konfigurasi notifikasi
│   ├── schedule_item.dart           # Komponen kartu jadwal
│   ├── task_item.dart               # Komponen kartu tugas dengan checkbox
│   └── theme_picker_sheet.dart      # Modal pemilih tema (Light/Dark)
└── main.dart                        # Titik masuk aplikasi (Inisialisasi Hive & Notifikasi)
```

---

## 🛠️ Teknologi & Dependensi

| Paket | Fungsi |
|---|---|
| **[flutter](https://flutter.dev/)** | Framework utama UI lintas platform |
| **[hive](https://pub.dev/packages/hive)** & **[hive_flutter](https://pub.dev/packages/hive_flutter)** | Database NoSQL lokal super cepat & ringan |
| **[google_fonts](https://pub.dev/packages/google_fonts)** | Tipografi modern (Poppins font family) |
| **[flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)** | Notifikasi push lokal tanpa server |
| **[timezone](https://pub.dev/packages/timezone)** | Penanganan zona waktu akurat untuk alarm notifikasi |
| **[image_picker](https://pub.dev/packages/image_picker)** | Memilih foto profil dari galeri / kamera |
| **[file_picker](https://pub.dev/packages/file_picker)** | Mengambil & menyimpan file cadangan (backup JSON) |
| **[url_launcher](https://pub.dev/packages/url_launcher)** | Membuka tautan eksternal (donasi & kredit) |

---

## 🚀 Memulai (Getting Started)

### Prasyarat
- Flutter SDK (`^3.13.5` atau yang lebih baru)
- Dart SDK
- Android Studio / VS Code dengan ekstensi Flutter & Dart
- Emulator Android / Perangkat fisik dengan USB Debugging aktif

### Langkah Instalasi

1. **Clone repositori ini:**
   ```bash
   git clone https://github.com/inikumadayo/TugasKu.git
   cd adistyclone
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

## 📦 Build Aplikasi (Production)

Untuk membuat file installer Android (APK / App Bundle):

```bash
# Membuat APK Release
flutter build apk --release

# Membuat Android App Bundle (AAB) untuk Play Store
flutter build appbundle --release
```

Hasil build APK dapat ditemukan di direktori `build/app/outputs/flutter-apk/app-release.apk`.

---

## 🤝 Kontribusi & Dukungan

Jika kamu menemukan *bug* atau ingin menyumbang fitur baru:
1. Fork repositori ini
2. Buat branch fitur baru (`git checkout -b fitur/fitur-keren`)
3. Commit perubahanmu (`git commit -m 'Menambahkan fitur keren'`)
4. Push ke branch (`git push origin fitur/fitur-keren`)
5. Buat **Pull Request** baru

Sukai proyek ini? Dukung pengembang melalui [Trakteer](https://trakteer.id/kumadayo) ☕.

---

## 📄 Lisensi

Proyek ini dibuat untuk keperluan pembelajaran dan pengembangan aplikasi produktivitas mahasiswa. Dikembangkan oleh **Kumadayo**.
