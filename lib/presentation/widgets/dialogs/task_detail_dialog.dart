import 'dart:async';

import 'package:adistyclone/core/theme/colors.dart';
import 'package:adistyclone/core/utils/date_time_helper.dart';
import 'package:adistyclone/core/utils/mascot_helper.dart';
import 'package:adistyclone/database/database_helper.dart';
import 'package:adistyclone/models/task_model.dart';
import 'package:adistyclone/presentation/widgets/dialogs/delete_confirm_dialog.dart';
import 'package:flutter/material.dart';

/// Snapshot state untuk riwayat Undo & Redo catatan
class _NoteSnapshot {
  final String title;
  final String notes;

  _NoteSnapshot({required this.title, required this.notes});
}

/// Menampilkan editor catatan tugas bergaya Google Keep.
///
/// Mengembalikan `true` jika data tugas diperbarui atau dihapus.
Future<bool> showTaskDetailDialog(
  BuildContext context, {
  required TaskModel task,
}) async {
  final result = await Navigator.push<bool>(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          TaskDetailScreen(task: task),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 220),
    ),
  );

  return result ?? false;
}

/// Layar Detail & Editor Tugas bergaya Google Keep Notes
class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskKeepEditorScreenState();
}

class _TaskKeepEditorScreenState extends State<TaskDetailScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  late String _subject;
  late bool _isCompleted;
  DateTime? _selectedDeadline;

  // Auto-save debouncer
  Timer? _autoSaveTimer;
  String _saveStatus = 'Tersimpan otomatis';

  // Undo & Redo text history
  final List<_NoteSnapshot> _textUndoStack = [];
  final List<_NoteSnapshot> _textRedoStack = [];
  bool _isUndoRedoing = false;
  String _lastSavedTitle = '';
  String _lastSavedNotes = '';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _notesController = TextEditingController(text: widget.task.notes ?? '');
    _subject = widget.task.description;
    _isCompleted = widget.task.isCompleted;
    _selectedDeadline = widget.task.deadline;

    _lastSavedTitle = widget.task.title;
    _lastSavedNotes = widget.task.notes ?? '';

    // Record initial snapshot
    _textUndoStack.add(
      _NoteSnapshot(title: _lastSavedTitle, notes: _lastSavedNotes),
    );
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Catat snapshot riwayat sebelum teks mengalami perubahan baru
  void _onTextChanged() {
    if (_isUndoRedoing) return;

    final currentTitle = _titleController.text;
    final currentNotes = _notesController.text;

    if (currentTitle != _lastSavedTitle || currentNotes != _lastSavedNotes) {
      if (_textUndoStack.isEmpty ||
          _textUndoStack.last.title != _lastSavedTitle ||
          _textUndoStack.last.notes != _lastSavedNotes) {
        _textUndoStack.add(
          _NoteSnapshot(title: _lastSavedTitle, notes: _lastSavedNotes),
        );
        _textRedoStack.clear();
      }
      _lastSavedTitle = currentTitle;
      _lastSavedNotes = currentNotes;
    }

    _scheduleAutoSave();
  }

  void _scheduleAutoSave() {
    setState(() {
      _saveStatus = 'Menyimpan...';
    });
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(milliseconds: 500), () {
      _saveToDatabase();
    });
  }

  Future<void> _saveToDatabase() async {
    _autoSaveTimer?.cancel();
    final title = _titleController.text.trim();
    final actualTitle = title.isEmpty ? 'Tanpa Judul' : title;
    final notes = _notesController.text.trim();

    final updatedTask = widget.task.copyWith(
      title: actualTitle,
      description: _subject.trim().isEmpty ? 'Umum' : _subject.trim(),
      notes: notes.isNotEmpty ? notes : null,
      isCompleted: _isCompleted,
      deadline: _selectedDeadline,
    );

    await DatabaseHelper.updateTask(updatedTask);

    if (mounted) {
      setState(() {
        _saveStatus = 'Tersimpan otomatis';
      });
    }
  }

  void _undo() {
    if (_textUndoStack.length <= 1) return;

    _isUndoRedoing = true;
    final currentSnapshot = _NoteSnapshot(
      title: _titleController.text,
      notes: _notesController.text,
    );
    _textRedoStack.add(currentSnapshot);

    final previous = _textUndoStack.removeLast();
    _titleController.text = previous.title;
    _notesController.text = previous.notes;

    _titleController.selection = TextSelection.fromPosition(
      TextPosition(offset: _titleController.text.length),
    );
    _notesController.selection = TextSelection.fromPosition(
      TextPosition(offset: _notesController.text.length),
    );

    _lastSavedTitle = previous.title;
    _lastSavedNotes = previous.notes;
    _isUndoRedoing = false;

    _saveToDatabase();
  }

  void _redo() {
    if (_textRedoStack.isEmpty) return;

    _isUndoRedoing = true;
    final currentSnapshot = _NoteSnapshot(
      title: _titleController.text,
      notes: _notesController.text,
    );
    _textUndoStack.add(currentSnapshot);

    final next = _textRedoStack.removeLast();
    _titleController.text = next.title;
    _notesController.text = next.notes;

    _titleController.selection = TextSelection.fromPosition(
      TextPosition(offset: _titleController.text.length),
    );
    _notesController.selection = TextSelection.fromPosition(
      TextPosition(offset: _notesController.text.length),
    );

    _lastSavedTitle = next.title;
    _lastSavedNotes = next.notes;
    _isUndoRedoing = false;

    _saveToDatabase();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final initialDate = _selectedDeadline ?? now.add(const Duration(days: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(now) ? now : initialDate,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ColorsTheme.aksen,
              onPrimary: ColorsTheme.teksDiAksen,
              surface: ColorsTheme.latarKomponen,
              onSurface: ColorsTheme.teks,
            ),
          ),
          child: child!,
        );
      },
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ColorsTheme.aksen,
              onPrimary: ColorsTheme.teksDiAksen,
              surface: ColorsTheme.latarKomponen,
              onSurface: ColorsTheme.teks,
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted) return;

    setState(() {
      if (time == null) {
        _selectedDeadline = DateTime(date.year, date.month, date.day, 23, 59);
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

    _scheduleAutoSave();
  }

  void _showSubjectPicker() {
    final controller = TextEditingController(text: _subject);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorsTheme.latarKomponen,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 18, 20, 20 + bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ColorsTheme.teksSekunder.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Mata Kuliah / Kategori',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ColorsTheme.teks,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                style: TextStyle(color: ColorsTheme.teks, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Contoh: Pemrograman Mobile',
                  hintStyle: TextStyle(
                    color: ColorsTheme.teksSekunder.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: ColorsTheme.latar,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (val) {
                  Navigator.pop(ctx);
                  setState(
                    () => _subject = val.trim().isEmpty ? 'Umum' : val.trim(),
                  );
                  _scheduleAutoSave();
                },
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _subject = controller.text.trim().isEmpty
                          ? 'Umum'
                          : controller.text.trim();
                    });
                    _scheduleAutoSave();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsTheme.aksen,
                    foregroundColor: ColorsTheme.teksDiAksen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Simpan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDeleteConfirmDialog(
      context,
      title: 'Hapus Tugas?',
      itemName: _titleController.text.trim().isNotEmpty
          ? _titleController.text.trim()
          : widget.task.title,
    );

    if (confirmed && mounted) {
      await DatabaseHelper.deleteTask(widget.task.id);
      if (mounted) Navigator.pop(context, true);
    }
  }

  Future<void> _toggleOverallComplete() async {
    final wasCompleted = _isCompleted;
    setState(() => _isCompleted = !_isCompleted);
    await _saveToDatabase();

    if (!wasCompleted && _isCompleted && mounted) {
      final incompleteCount = DatabaseHelper.getIncompleteTasks().length;
      MascotHelper.showTaskCelebration(
        context,
        isAllCompleted: incompleteCount == 0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ColorsTheme.isDarkMode;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _saveToDatabase();
        if (context.mounted) {
          Navigator.pop(context, true);
        }
      },
      child: Scaffold(
        backgroundColor: ColorsTheme.latar,
        body: SafeArea(
          child: Column(
            children: [
              // 1. Bilah Atas (Top Bar Google Keep Style)
              _buildTopBar(),

              // 2. Konten Catatan / Text Field
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // Input Judul Tugas (Google Keep Large Borderless)
                      TextField(
                        controller: _titleController,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: ColorsTheme.teks,
                          height: 1.25,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Judul tugas',
                          hintStyle: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: ColorsTheme.teksSekunder.withValues(
                              alpha: 0.4,
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        onChanged: (_) => _onTextChanged(),
                      ),
                      const SizedBox(height: 14),

                      // Baris Chips (Mata Kuliah & Deadline)
                      _buildPillsRow(isDark),
                      const SizedBox(height: 18),

                      // Area Catatan / Instruksi Tugas (Google Keep Multiline Borderless)
                      TextField(
                        controller: _notesController,
                        maxLines: null,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: ColorsTheme.teks,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Tulis catatan atau instruksi di sini...',
                          hintStyle: TextStyle(
                            fontSize: 15,
                            color: ColorsTheme.teksSekunder.withValues(
                              alpha: 0.45,
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        onChanged: (_) => _onTextChanged(),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // 3. Bilah Bawah (Auto-save status & Undo/Redo)
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  // --- Top App Bar ---

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Tombol Kembali
          _buildCircleIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            size: 18,
            onTap: () async {
              await _saveToDatabase();
              if (mounted) Navigator.pop(context, true);
            },
          ),
          const Spacer(),

          // Status Selesai / Belum Selesai Toggle
          InkWell(
            onTap: _toggleOverallComplete,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _isCompleted
                    ? ColorsTheme.selesai
                    : ColorsTheme.latarKomponen,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isCompleted
                      ? ColorsTheme.selesai
                      : ColorsTheme.teksSekunder.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 16,
                    color: _isCompleted
                        ? ColorsTheme.teksSelesai
                        : ColorsTheme.aksen,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isCompleted ? 'Selesai' : 'Aktif',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _isCompleted
                          ? ColorsTheme.teksSelesai
                          : ColorsTheme.teks,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Tombol Hapus Tugas
          _buildCircleIconButton(
            icon: Icons.delete_outline_rounded,
            size: 20,
            iconColor: Colors.red.shade400,
            onTap: _handleDelete,
          ),
        ],
      ),
    );
  }

  Widget _buildCircleIconButton({
    required IconData icon,
    required double size,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ColorsTheme.latarKomponen,
        ),
        child: Center(
          child: Icon(icon, size: size, color: iconColor ?? ColorsTheme.teks),
        ),
      ),
    );
  }

  // --- Horizontal Pills Row ---

  Widget _buildPillsRow(bool isDark) {
    // 1. Mata Kuliah Chip colors
    final subjectBg = isDark
        ? const Color(0xFF1E3427)
        : const Color(0xFFDCEAD8);
    final subjectText = isDark
        ? const Color(0xFF86D5A2)
        : const Color(0xFF235532);

    // 2. Deadline Chip colors
    final deadlineBg = isDark
        ? const Color(0xFF38251E)
        : const Color(0xFFFBE4D8);
    final deadlineText = isDark
        ? const Color(0xFFEAA690)
        : const Color(0xFF8A3B22);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          // Mata Kuliah Chip
          _buildPill(
            icon: Icons.calendar_view_day_outlined,
            label: _subject.isNotEmpty ? _subject : 'Pilih Mata Kuliah',
            bgColor: subjectBg,
            textColor: subjectText,
            onTap: _showSubjectPicker,
          ),
          const SizedBox(width: 8),

          // Deadline Chip
          _buildPill(
            icon: Icons.access_time_rounded,
            label: DateTimeHelper.formatDeadlineKeep(_selectedDeadline),
            bgColor: deadlineBg,
            textColor: deadlineText,
            onTap: _pickDeadline,
          ),
        ],
      ),
    );
  }

  Widget _buildPill({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Bottom Toolbar ---

  Widget _buildBottomBar() {
    final canUndo = _textUndoStack.length > 1;
    final canRedo = _textRedoStack.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: ColorsTheme.latar,
        border: Border(
          top: BorderSide(
            color: ColorsTheme.teksSekunder.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Indikator Auto-save di kiri/tengah
          Icon(
            Icons.cloud_done_outlined,
            size: 16,
            color: ColorsTheme.teksSekunder.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 6),
          Text(
            _saveStatus,
            style: TextStyle(
              fontSize: 12,
              color: ColorsTheme.teksSekunder.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),

          // Tombol Undo
          IconButton(
            icon: Icon(
              Icons.undo_rounded,
              size: 20,
              color: canUndo
                  ? ColorsTheme.teks
                  : ColorsTheme.teksSekunder.withValues(alpha: 0.35),
            ),
            onPressed: canUndo ? _undo : null,
            tooltip: 'Undo',
          ),

          // Tombol Redo
          IconButton(
            icon: Icon(
              Icons.redo_rounded,
              size: 20,
              color: canRedo
                  ? ColorsTheme.teks
                  : ColorsTheme.teksSekunder.withValues(alpha: 0.35),
            ),
            onPressed: canRedo ? _redo : null,
            tooltip: 'Redo',
          ),
        ],
      ),
    );
  }
}
