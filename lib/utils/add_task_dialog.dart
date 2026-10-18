import 'package:adistyclone/assets/colors.dart';
import 'package:adistyclone/database/database_helper.dart';
import 'package:adistyclone/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dialog untuk menambah tugas baru.
///
/// Memanggil [showAddTaskDialog] akan menampilkan AlertDialog
/// dengan form input. Mengembalikan `true` jika tugas berhasil disimpan.
Future<bool> showAddTaskDialog(BuildContext context) async {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  DateTime? selectedDeadline;

  final result = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        backgroundColor: ColorsTheme.latarKomponen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Tambah Tugas',
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
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Judul Tugas',
                  prefixIcon: Icon(Icons.assignment_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: 'Deskripsi / Mata Kuliah',
                  prefixIcon: Icon(Icons.description_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final picked = await _showDateTimePicker(context);
                  if (picked != null) {
                    setDialogState(() => selectedDeadline = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month_rounded, color: Colors.grey),
                      SizedBox(width: 12),
                      Text(
                        selectedDeadline != null
                            ? _formatDeadline(selectedDeadline!)
                            : 'Pilih Deadline (opsional)',
                        style: TextStyle(
                          color: selectedDeadline != null
                              ? ColorsTheme.teks
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
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
              if (titleController.text.isEmpty) return;

              final task = TaskModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: titleController.text,
                description: descController.text.isEmpty
                    ? 'Tanpa deskripsi'
                    : descController.text,
                deadline: selectedDeadline,
              );

              await DatabaseHelper.addTask(task);
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

/// Date-time picker: pilih tanggal dulu, lalu waktu
Future<DateTime?> _showDateTimePicker(BuildContext context) async {
  final date = await showDatePicker(
    context: context,
    initialDate: DateTime.now().add(const Duration(days: 1)),
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(const Duration(days: 365)),
  );
  if (date == null) return null;

  if (!context.mounted) return date;

  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(hour: 23, minute: 59),
  );
  if (time == null) return date;

  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

/// Format deadline ke string yang readable
String _formatDeadline(DateTime dt) {
  const months = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  return '${dt.day} ${months[dt.month]} ${dt.year}, '
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';
}
