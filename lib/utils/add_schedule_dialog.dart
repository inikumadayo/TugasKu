import 'package:adistyclone/assets/colors.dart';
import 'package:adistyclone/database/database_helper.dart';
import 'package:adistyclone/models/schedule_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dialog untuk menambah jadwal baru.
///
/// Memanggil [showAddScheduleDialog] akan menampilkan AlertDialog
/// dengan form input. Mengembalikan `true` jika jadwal berhasil disimpan.
Future<bool> showAddScheduleDialog(
  BuildContext context, {
  required int defaultHari,
}) async {
  final titleController = TextEditingController();
  final ruangController = TextEditingController();
  final waktuMulaiController = TextEditingController();
  final waktuSelesaiController = TextEditingController();
  String selectedJenis = 'Mata Kuliah';
  int selectedHari = defaultHari;

  final result = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        backgroundColor: ColorsTheme.latarKomponen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Tambah Jadwal',
          style: TextStyle(
            fontFamily: GoogleFonts.poppins().fontFamily,
            fontWeight: FontWeight.bold,
            color: ColorsTheme.teks,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(titleController, 'Judul', Icons.book_rounded),
              const SizedBox(height: 12),
              _buildTextField(
                ruangController,
                'Ruang',
                Icons.meeting_room_rounded,
              ),
              const SizedBox(height: 12),
              _buildTimePickerField(
                context: context,
                controller: waktuMulaiController,
                label: 'Waktu Mulai',
                icon: Icons.access_time_rounded,
                defaultTime: const TimeOfDay(hour: 7, minute: 30),
                setDialogState: setDialogState,
              ),
              const SizedBox(height: 12),
              _buildTimePickerField(
                context: context,
                controller: waktuSelesaiController,
                label: 'Waktu Selesai',
                icon: Icons.access_time_filled_rounded,
                defaultTime: const TimeOfDay(hour: 9, minute: 10),
                setDialogState: setDialogState,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedJenis,
                decoration: InputDecoration(
                  labelText: 'Jenis',
                  prefixIcon: const Icon(Icons.category_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items:
                    ['Mata Kuliah', 'Praktikum', 'Seminar', 'Rapat', 'Lainnya']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (value) {
                  setDialogState(() => selectedJenis = value!);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: selectedHari,
                decoration: InputDecoration(
                  labelText: 'Hari',
                  prefixIcon: const Icon(Icons.calendar_today_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: List.generate(5, (i) {
                  const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];
                  return DropdownMenuItem(value: i + 1, child: Text(days[i]));
                }),
                onChanged: (value) {
                  setDialogState(() => selectedHari = value!);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: TextStyle(color: ColorsTheme.teksSekunder),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty ||
                  ruangController.text.isEmpty ||
                  waktuMulaiController.text.isEmpty ||
                  waktuSelesaiController.text.isEmpty) {
                return;
              }

              final schedule = ScheduleModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: titleController.text,
                ruang: ruangController.text,
                waktuMulai: waktuMulaiController.text,
                waktuSelesai: waktuSelesaiController.text,
                jenis: selectedJenis,
                hari: selectedHari,
              );

              await DatabaseHelper.addSchedule(schedule);
              if (context.mounted) Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsTheme.kartuUtama,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Simpan',
              style: TextStyle(color: ColorsTheme.latarKomponen),
            ),
          ),
        ],
      ),
    ),
  );

  return result ?? false;
}

Widget _buildTextField(
  TextEditingController controller,
  String label,
  IconData icon,
) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

Widget _buildTimePickerField({
  required BuildContext context,
  required TextEditingController controller,
  required String label,
  required IconData icon,
  required TimeOfDay defaultTime,
  required void Function(VoidCallback) setDialogState,
}) {
  return TextField(
    controller: controller,
    readOnly: true,
    onTap: () async {
      final initial = _parseTime(controller.text, defaultTime);
      final picked = await showTimePicker(
        context: context,
        initialTime: initial,
      );
      if (picked != null) {
        final formatted =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        setDialogState(() {
          controller.text = formatted;
        });
      }
    },
    decoration: InputDecoration(
      labelText: label,
      hintText: 'Pilih jam',
      prefixIcon: Icon(icon),
      suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

TimeOfDay _parseTime(String text, TimeOfDay fallback) {
  if (text.isEmpty) return fallback;
  final parts = text.split(':');
  if (parts.length == 2) {
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h != null && m != null) {
      return TimeOfDay(hour: h, minute: m);
    }
  }
  return fallback;
}
