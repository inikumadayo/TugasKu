import 'package:adistyclone/core/theme/colors.dart';
import 'package:adistyclone/database/database_helper.dart';
import 'package:adistyclone/services/notification_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Jenis konfigurasi notifikasi: Kuliah atau Tugas
enum NotificationConfigType { kuliah, tugas }

class TimingOption {
  final int minutes;
  final String title;
  final String subtitle;

  const TimingOption({
    required this.minutes,
    required this.title,
    required this.subtitle,
  });
}

/// Menampilkan bottom sheet pengaturan notifikasi dinamis untuk Kuliah maupun Tugas
Future<void> showNotificationConfigSheet(
  BuildContext context, {
  required NotificationConfigType type,
  VoidCallback? onConfigChanged,
}) async {
  final isKuliah = type == NotificationConfigType.kuliah;

  // Nilai awal dari database
  int selectedTiming = isKuliah
      ? DatabaseHelper.getClassNotificationTiming()
      : DatabaseHelper.getTaskReminderTiming();

  String? selectedSoundPath = isKuliah
      ? DatabaseHelper.getClassNotificationSoundPath()
      : DatabaseHelper.getTaskReminderSoundPath();

  String selectedSoundName = isKuliah
      ? DatabaseHelper.getClassNotificationSoundName()
      : DatabaseHelper.getTaskReminderSoundName();

  // Opsi timing berdasarkan jenis notifikasi
  final List<TimingOption> timingOptions = isKuliah
      ? const [
          TimingOption(
            minutes: 0,
            title: 'Tepat saat kuliah dimulai',
            subtitle: 'Notifikasi berbunyi tepat waktu jam mulai',
          ),
          TimingOption(
            minutes: 10,
            title: '10 menit sebelumnya',
            subtitle: 'Persiapan singkat sebelum kelas berlangsung',
          ),
          TimingOption(
            minutes: 15,
            title: '15 menit sebelumnya (Rekomendasi)',
            subtitle: 'Waktu ideal untuk bersiap menuju ruang kelas',
          ),
          TimingOption(
            minutes: 30,
            title: '30 menit sebelumnya',
            subtitle: 'Memberi waktu perjalanan santai ke kampus',
          ),
          TimingOption(
            minutes: 60,
            title: '1 jam sebelumnya',
            subtitle: 'Pemberitahuan awal sebelum memulai aktivitas',
          ),
        ]
      : const [
          TimingOption(
            minutes: 30,
            title: '30 menit sebelum deadline',
            subtitle: 'Peringatan mendesak menit-menit terakhir',
          ),
          TimingOption(
            minutes: 60,
            title: '1 jam sebelum deadline',
            subtitle: 'Waktu final checking dan persiapan upload',
          ),
          TimingOption(
            minutes: 180,
            title: '3 jam sebelum deadline',
            subtitle: 'Pengingat untuk menyelesaikan tugas',
          ),
          TimingOption(
            minutes: 720,
            title: '12 jam sebelum deadline',
            subtitle: 'Pengingat setengah hari sebelum batas waktu',
          ),
          TimingOption(
            minutes: 1440,
            title: 'H-1 (1 hari sebelumnya - Rekomendasi)',
            subtitle: 'Pengingat malam hari sebelum hari pengumpulan',
          ),
        ];

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (bottomSheetContext) => StatefulBuilder(
      builder: (ctx, setModalState) {
        final screenHeight = MediaQuery.of(bottomSheetContext).size.height;

        return Container(
          constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
          decoration: BoxDecoration(
            color: ColorsTheme.latarKomponen,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              (isKuliah
                                      ? ColorsTheme.chipLempung
                                      : ColorsTheme.aksen)
                                  .withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          isKuliah
                              ? Icons.school_rounded
                              : Icons.notifications_active_rounded,
                          color: isKuliah
                              ? ColorsTheme.kartuUtama
                              : ColorsTheme.aksen,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isKuliah
                                  ? 'Pengaturan Notifikasi Kuliah'
                                  : 'Pengaturan Pengingat Tugas',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: ColorsTheme.teks,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isKuliah
                                  ? 'Kapan & nada pengingat jadwal kuliah'
                                  : 'Kapan & nada pengingat batas deadline',
                              style: TextStyle(
                                fontSize: 12,
                                color: ColorsTheme.teksSekunder,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(height: 1),

                // Scrollable Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ============================================
                        // SECTION 1: KAPAN NOTIFIKASI DIKIRIM (TIMING)
                        // ============================================
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 18,
                              color: ColorsTheme.kartuUtama,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Kapan Notifikasi Dikirim',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: ColorsTheme.teks,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // List opsi timing
                        ...timingOptions.map((opt) {
                          final isSelected = selectedTiming == opt.minutes;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  setModalState(() {
                                    selectedTiming = opt.minutes;
                                  });
                                },
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? ColorsTheme.kartuUtama.withValues(
                                            alpha: 0.08,
                                          )
                                        : ColorsTheme.latar,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected
                                          ? ColorsTheme.kartuUtama
                                          : Colors.grey.shade300,
                                      width: isSelected ? 1.8 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              opt.title,
                                              style: TextStyle(
                                                fontFamily:
                                                    GoogleFonts.poppins()
                                                        .fontFamily,
                                                fontSize: 13,
                                                fontWeight: isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.w500,
                                                color: ColorsTheme.teks,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              opt.subtitle,
                                              style: TextStyle(
                                                fontFamily:
                                                    GoogleFonts.poppins()
                                                        .fontFamily,
                                                fontSize: 11,
                                                color: ColorsTheme.teksSekunder,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? ColorsTheme.kartuUtama
                                                : Colors.grey.shade400,
                                            width: 2,
                                          ),
                                          color: isSelected
                                              ? ColorsTheme.kartuUtama
                                              : Colors.transparent,
                                        ),
                                        child: isSelected
                                            ? const Icon(
                                                Icons.check,
                                                size: 13,
                                                color: Colors.white,
                                              )
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 20),

                        // ============================================
                        // SECTION 2: LAGU / NADA NOTIFIKASI
                        // ============================================
                        Row(
                          children: [
                            Icon(
                              Icons.music_note_rounded,
                              size: 18,
                              color: ColorsTheme.kartuUtama,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Lagu & Nada Dering Notifikasi',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: ColorsTheme.teks,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Card status nada dering saat ini
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: ColorsTheme.latar,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: ColorsTheme.kartuUtama.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      selectedSoundPath == null
                                          ? Icons.notifications_rounded
                                          : Icons.audiotrack_rounded,
                                      color: ColorsTheme.kartuUtama,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Nada Terpilih:',
                                          style: TextStyle(
                                            fontFamily: GoogleFonts.poppins()
                                                .fontFamily,
                                            fontSize: 11,
                                            color: ColorsTheme.teksSekunder,
                                          ),
                                        ),
                                        Text(
                                          selectedSoundName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: GoogleFonts.poppins()
                                                .fontFamily,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: ColorsTheme.teks,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (selectedSoundPath != null)
                                    IconButton(
                                      tooltip: 'Kembalikan ke Default',
                                      icon: const Icon(
                                        Icons.refresh_rounded,
                                        size: 20,
                                      ),
                                      color: ColorsTheme.teksSekunder,
                                      onPressed: () {
                                        setModalState(() {
                                          selectedSoundPath = null;
                                          selectedSoundName = 'Default Sistem';
                                        });
                                      },
                                    ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Tombol Upload / Pilih File Audio
                              SizedBox(
                                width: double.infinity,
                                height: 40,
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    try {
                                      final file = await FilePicker.pickFile(
                                        type: FileType.custom,
                                        allowedExtensions: [
                                          'mp3',
                                          'wav',
                                          'm4a',
                                          'ogg',
                                          'aac',
                                        ],
                                      );

                                      if (file != null && file.path != null) {
                                        setModalState(() {
                                          selectedSoundPath = file.path;
                                          selectedSoundName = file.name;
                                        });
                                      }
                                    } catch (e) {
                                      debugPrint('Error pick audio: $e');
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.file_upload_outlined,
                                    size: 18,
                                  ),
                                  label: Text(
                                    selectedSoundPath == null
                                        ? 'Upload Lagu / Audio Pribadi'
                                        : 'Ganti Lagu / Audio Pribadi',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: ColorsTheme.kartuUtama,
                                    side: BorderSide(
                                      color: ColorsTheme.kartuUtama,
                                      width: 1.2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ============================================
                // FOOTER: TOMBOL SIMPAN
                // ============================================
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () async {
                              final nav = Navigator.of(bottomSheetContext);

                              // Simpan ke database
                              if (isKuliah) {
                                await DatabaseHelper.setClassNotificationTiming(
                                  selectedTiming,
                                );
                                await DatabaseHelper.setClassNotificationSound(
                                  selectedSoundPath,
                                  selectedSoundName,
                                );
                                await NotificationService.rescheduleAllClassNotifications();
                              } else {
                                await DatabaseHelper.setTaskReminderTiming(
                                  selectedTiming,
                                );
                                await DatabaseHelper.setTaskReminderSound(
                                  selectedSoundPath,
                                  selectedSoundName,
                                );
                                await NotificationService.rescheduleAllTaskNotifications();
                              }

                              nav.pop();
                              onConfigChanged?.call();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorsTheme.kartuUtama,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              'Simpan Pengaturan',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
