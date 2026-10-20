import 'package:adistyclone/assets/colors.dart';
import 'package:adistyclone/database/database_helper.dart';
import 'package:adistyclone/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bottom sheet untuk menambah tugas baru.
///
/// Memanggil [showAddTaskDialog] akan menampilkan bottom sheet
/// dengan form input. Mengembalikan `true` jika tugas berhasil disimpan.
Future<bool> showAddTaskDialog(BuildContext context) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _AddTaskSheet(),
  );

  return result ?? false;
}

class _AddTaskSheet extends StatefulWidget {
  const _AddTaskSheet();

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  DateTime? _selectedDeadline;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 23, minute: 59),
    );
    if (time == null) {
      setState(() => _selectedDeadline = date);
    } else {
      setState(() {
        _selectedDeadline = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  Future<void> _handleSave() async {
    if (_titleController.text.isEmpty) return;

    final task = TaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      description: _descController.text.isEmpty
          ? 'Tanpa deskripsi'
          : _descController.text,
      deadline: _selectedDeadline,
    );

    await DatabaseHelper.addTask(task);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: ColorsTheme.latarKomponen,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
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
                const SizedBox(height: 20),

                // Title
                Text(
                  'Tambah tugas',
                  style: TextStyle(
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: ColorsTheme.teks,
                  ),
                ),
                const SizedBox(height: 20),

                // Judul tugas
                _buildLabel('Judul tugas'),
                const SizedBox(height: 8),
                _buildInputField(
                  controller: _titleController,
                  hint: 'Tugas Algoritma',
                ),
                const SizedBox(height: 20),

                // Deskripsi / Mata Kuliah
                _buildLabel('Deskripsi / Mata Kuliah'),
                const SizedBox(height: 8),
                _buildInputField(
                  controller: _descController,
                  hint: 'Pemrograman Mobile',
                  maxLines: 3,
                ),
                const SizedBox(height: 20),

                // Deadline
                _buildLabel('Deadline (opsional)'),
                const SizedBox(height: 8),
                _buildDeadlinePicker(),
                const SizedBox(height: 28),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            'Batal',
                            style: TextStyle(
                              fontFamily: GoogleFonts.poppins().fontFamily,
                              fontWeight: FontWeight.w600,
                              color: ColorsTheme.teks,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _handleSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorsTheme.aksen,
                            foregroundColor: ColorsTheme.teks,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            'Simpan tugas',
                            style: TextStyle(
                              fontFamily: GoogleFonts.poppins().fontFamily,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: GoogleFonts.poppins().fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: ColorsTheme.teksSekunder,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(
        fontFamily: GoogleFonts.poppins().fontFamily,
        fontSize: 15,
        color: ColorsTheme.teks,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        filled: true,
        fillColor: ColorsTheme.latar,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: ColorsTheme.kartuUtama,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildDeadlinePicker() {
    return GestureDetector(
      onTap: _pickDeadline,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: ColorsTheme.latar,
          borderRadius: BorderRadius.circular(14),
          border: _selectedDeadline != null
              ? Border.all(color: ColorsTheme.kartuUtama, width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month_rounded,
              size: 20,
              color: _selectedDeadline != null
                  ? ColorsTheme.kartuUtama
                  : Colors.grey.shade500,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedDeadline != null
                    ? _formatDeadline(_selectedDeadline!)
                    : 'Pilih tanggal & waktu',
                style: TextStyle(
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  fontSize: 15,
                  color: _selectedDeadline != null
                      ? ColorsTheme.teks
                      : Colors.grey.shade400,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.grey.shade500,
            ),
          ],
        ),
      ),
    );
  }
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
