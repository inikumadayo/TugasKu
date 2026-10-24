import 'package:adistyclone/core/theme/colors.dart';
import 'package:adistyclone/core/utils/date_time_helper.dart';
import 'package:adistyclone/core/utils/mascot_helper.dart';
import 'package:adistyclone/database/database_helper.dart';
import 'package:adistyclone/models/task_model.dart';
import 'package:adistyclone/presentation/widgets/dialogs/delete_confirm_dialog.dart';
import 'package:flutter/material.dart';

/// Menampilkan bottom sheet detail dan edit tugas.
///
/// Mengembalikan `true` jika tugas berhasil diperbarui atau dihapus.
Future<bool> showTaskDetailDialog(
  BuildContext context, {
  required TaskModel task,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _TaskDetailSheet(task: task),
  );

  return result ?? false;
}

class _TaskDetailSheet extends StatefulWidget {
  final TaskModel task;

  const _TaskDetailSheet({required this.task});

  @override
  State<_TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends State<_TaskDetailSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _notesController;
  late bool _isCompleted;
  DateTime? _selectedDeadline;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(text: widget.task.description);
    _notesController = TextEditingController(text: widget.task.notes ?? '');
    _isCompleted = widget.task.isCompleted;
    _selectedDeadline = widget.task.deadline;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final initialDate = _selectedDeadline ?? now.add(const Duration(days: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(now) ? now : initialDate,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final initialTime = _selectedDeadline != null
        ? TimeOfDay(
            hour: _selectedDeadline!.hour,
            minute: _selectedDeadline!.minute,
          )
        : const TimeOfDay(hour: 23, minute: 59);

    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (!mounted) return;

    setState(() {
      if (time == null) {
        _selectedDeadline = date;
      } else {
        _selectedDeadline = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      }
    });
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDeleteConfirmDialog(
      context,
      title: 'Hapus Tugas?',
      itemName: widget.task.title,
    );

    if (confirmed && mounted) {
      await DatabaseHelper.deleteTask(widget.task.id);
      if (mounted) Navigator.pop(context, true);
    }
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final notes = _notesController.text.trim();
    final wasCompletedBefore = widget.task.isCompleted;

    final updatedTask = widget.task.copyWith(
      title: title,
      description: _descController.text.trim().isEmpty
          ? 'Umum'
          : _descController.text.trim(),
      notes: notes.isNotEmpty ? notes : null,
      isCompleted: _isCompleted,
      deadline: _selectedDeadline,
    );

    await DatabaseHelper.updateTask(updatedTask);

    if (mounted) {
      // Jika baru saja ditandai selesai dari belum selesai
      if (!wasCompletedBefore && _isCompleted) {
        final incompleteCount = DatabaseHelper.getIncompleteTasks().length;
        MascotHelper.showTaskCelebration(
          context,
          isAllCompleted: incompleteCount == 0,
        );
      }
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: ColorsTheme.latarKomponen,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(24, 16, 24, 20 + bottomInset),
        child: SingleChildScrollView(
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
                    color: ColorsTheme.teksSekunder.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Header bar: Title, Status Chip, Delete Button
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'Detail Tugas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ColorsTheme.teks,
                      ),
                    ),
                  ),
                  // Delete button
                  IconButton(
                    onPressed: _handleDelete,
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.red.shade400,
                      size: 22,
                    ),
                    tooltip: 'Hapus Tugas',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Status Toggle Card
              GestureDetector(
                onTap: () {
                  setState(() => _isCompleted = !_isCompleted);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _isCompleted
                        ? ColorsTheme.selesai.withValues(alpha: 0.15)
                        : ColorsTheme.latar,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isCompleted
                          ? ColorsTheme.selesai
                          : ColorsTheme.teksSekunder.withValues(alpha: 0.15),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isCompleted
                              ? ColorsTheme.selesai
                              : Colors.transparent,
                          border: Border.all(
                            color: _isCompleted
                                ? ColorsTheme.selesai
                                : ColorsTheme.aksen,
                            width: 2,
                          ),
                        ),
                        child: _isCompleted
                            ? Center(
                                child: Icon(
                                  Icons.check_rounded,
                                  size: 15,
                                  color: ColorsTheme.teksSelesai,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _isCompleted
                              ? 'Tugas sudah selesai 🎉'
                              : 'Tugas belum selesai',
                          style: TextStyle(
                            color: _isCompleted
                                ? ColorsTheme.teks
                                : ColorsTheme.teksSekunder,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        _isCompleted ? 'Selesai' : 'Aktif',
                        style: TextStyle(
                          color: _isCompleted
                              ? ColorsTheme.selesai
                              : ColorsTheme.aksen,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Judul Tugas
              _buildLabel('Judul Tugas'),
              const SizedBox(height: 8),
              _buildInputField(
                controller: _titleController,
                hint: 'Judul tugas...',
              ),
              const SizedBox(height: 18),

              // Mata Kuliah
              _buildLabel('Mata Kuliah'),
              const SizedBox(height: 8),
              _buildInputField(
                controller: _descController,
                hint: 'Contoh: Pemrograman Web Dinamis',
              ),
              const SizedBox(height: 18),

              // Catatan / Deskripsi Lengkap
              _buildLabel('Catatan / Instruksi Detail (opsional)'),
              const SizedBox(height: 8),
              _buildInputField(
                controller: _notesController,
                hint:
                    'Tambahkan instruksi lengkap tugas, format file, link pengumpulan, atau catatan penting lainnya...',
                maxLines: 4,
              ),
              const SizedBox(height: 18),

              // Deadline Picker
              _buildLabel('Deadline Waktu'),
              const SizedBox(height: 8),
              _buildDeadlinePicker(),
              const SizedBox(height: 26),

              // Action buttons: Batal & Simpan
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: ColorsTheme.teksSekunder.withValues(
                              alpha: 0.25,
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: TextStyle(
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
                          backgroundColor: ColorsTheme.kartuUtama,
                          foregroundColor: ColorsTheme.teksDiKartu,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Simpan Perubahan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: ColorsTheme.teksDiKartu,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
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
      style: TextStyle(color: ColorsTheme.teks, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: ColorsTheme.teksSekunder.withValues(alpha: 0.5),
          fontSize: 14,
        ),
        filled: true,
        fillColor: ColorsTheme.latar,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: ColorsTheme.teksSekunder.withValues(alpha: 0.15),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: ColorsTheme.teksSekunder.withValues(alpha: 0.15),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: ColorsTheme.aksen, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDeadlinePicker() {
    final hasDeadline = _selectedDeadline != null;
    final dateStr = hasDeadline
        ? '${DateTimeHelper.getNamaHari(_selectedDeadline!.weekday)}, ${DateTimeHelper.getFormattedDate(_selectedDeadline!)} • ${_selectedDeadline!.hour.toString().padLeft(2, '0')}:${_selectedDeadline!.minute.toString().padLeft(2, '0')}'
        : 'Tidak ada deadline ditentukan';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: ColorsTheme.latar,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ColorsTheme.teksSekunder.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.event_outlined,
            size: 20,
            color: hasDeadline ? ColorsTheme.aksen : ColorsTheme.teksSekunder,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              dateStr,
              style: TextStyle(
                color: hasDeadline
                    ? ColorsTheme.teks
                    : ColorsTheme.teksSekunder.withValues(alpha: 0.6),
                fontSize: 13,
                fontWeight: hasDeadline ? FontWeight.w500 : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (hasDeadline)
            IconButton(
              icon: Icon(
                Icons.close_rounded,
                size: 18,
                color: ColorsTheme.teksSekunder,
              ),
              onPressed: () => setState(() => _selectedDeadline = null),
              tooltip: 'Hapus deadline',
              visualDensity: VisualDensity.compact,
            ),
          TextButton(
            onPressed: _pickDeadline,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              visualDensity: VisualDensity.compact,
            ),
            child: Text(
              hasDeadline ? 'Ubah' : 'Atur',
              style: TextStyle(
                color: ColorsTheme.aksen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
