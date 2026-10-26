import 'dart:async';

import 'package:adistyclone/core/theme/colors.dart';
import 'package:adistyclone/core/utils/date_time_helper.dart';
import 'package:adistyclone/core/utils/mascot_helper.dart';
import 'package:adistyclone/database/database_helper.dart';
import 'package:adistyclone/models/task_model.dart';
import 'package:adistyclone/presentation/widgets/dialogs/delete_confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Snapshot state untuk riwayat Undo & Redo teks
class _NoteSnapshot {
  final String title;
  final String notes;

  _NoteSnapshot({required this.title, required this.notes});
}

/// Menampilkan editor catatan detail tugas sesuai desain yang diminta.
///
/// Jika [task] bernilai `null`, maka akan membuka editor tugas baru yang kosong.
/// Mengembalikan `true` jika data tugas baru berhasil disimpan atau tugas lama diperbarui/dihapus.
Future<bool> showTaskDetailDialog(
  BuildContext context, {
  TaskModel? task,
}) async {
  final isNewTask = task == null;
  final effectiveTask =
      task ??
      TaskModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: '',
        description: 'Umum',
        deadline: DateTime.now().add(const Duration(days: 1)),
      );

  final result = await Navigator.push<bool>(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          TaskDetailScreen(task: effectiveTask, isNewTask: isNewTask),
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

/// Layar Detail Tugas dengan Kartu Catatan Bergaris & Maskot Lumut Mengintip
class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;
  final bool isNewTask;

  const TaskDetailScreen({
    super.key,
    required this.task,
    this.isNewTask = false,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskKeepEditorScreenState();
}

class _TaskKeepEditorScreenState extends State<TaskDetailScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  late String _subject;
  late bool _isCompleted;
  DateTime? _selectedDeadline;
  late bool _isNewTask;
  bool _hasSavedOnce = false;

  // Auto-save debouncer
  Timer? _autoSaveTimer;
  String _saveStatus = 'Tersimpan otomatis';

  // Undo & Redo history
  final List<_NoteSnapshot> _textUndoStack = [];
  final List<_NoteSnapshot> _textRedoStack = [];
  bool _isUndoRedoing = false;
  String _lastSavedTitle = '';
  String _lastSavedNotes = '';

  @override
  void initState() {
    super.initState();
    _isNewTask = widget.isNewTask;
    _hasSavedOnce = !_isNewTask;

    _titleController = TextEditingController(text: widget.task.title);
    _notesController = TextEditingController(text: widget.task.notes ?? '');
    _subject = widget.task.description;
    _isCompleted = widget.task.isCompleted;
    _selectedDeadline = widget.task.deadline;

    _lastSavedTitle = widget.task.title;
    _lastSavedNotes = widget.task.notes ?? '';

    // Catat snapshot awal
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
    final notes = _notesController.text.trim();

    // Jika task baru dan user belum menulis judul maupun catatan, jangan simpan draf kosong ke database
    if (_isNewTask && title.isEmpty && notes.isEmpty && !_hasSavedOnce) {
      if (mounted) {
        setState(() {
          _saveStatus = 'Draf kosong';
        });
      }
      return;
    }

    final actualTitle = title.isEmpty ? 'Tanpa Judul' : title;

    final updatedTask = widget.task.copyWith(
      title: actualTitle,
      description: _subject.trim().isEmpty ? 'Umum' : _subject.trim(),
      notes: notes.isNotEmpty ? notes : null,
      isCompleted: _isCompleted,
      deadline: _selectedDeadline,
    );

    await DatabaseHelper.updateTask(updatedTask);
    _hasSavedOnce = true;
    _isNewTask = false;

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
    if (!_hasSavedOnce) {
      // Draf baru yang belum tersimpan ke database, langsung keluar
      Navigator.pop(context, false);
      return;
    }

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
          Navigator.pop(context, _hasSavedOnce);
        }
      },
      child: Scaffold(
        backgroundColor: ColorsTheme.latar,
        body: SafeArea(
          child: Column(
            children: [
              // 1. Bilah Atas (Top Bar: Back, Tersimpan otomatis, Undo, Redo)
              _buildTopBar(),

              // 2. Area Scroll Konten Kartu Catatan dengan Maskot Mengintip
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const double topSpace = 104.0;
                    const double bottomGap = 18.0;
                    final double defaultCardHeight =
                        (constraints.maxHeight - topSpace - bottomGap).clamp(
                          320.0,
                          1200.0,
                        );
                    final double notesAreaMinHeight = defaultCardHeight - 228.0;

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Ruang kosong di atas agar seluruh muka maskot terlihat leluasa
                          const SizedBox(height: topSpace),

                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Maskot Mengintip di Atas Kanan Kartu
                              Positioned(
                                top: -96,
                                right: 26,
                                child: _PeekingMascot(
                                  isCompleted: _isCompleted,
                                ),
                              ),

                              // Kartu Catatan Utama
                              Container(
                                width: double.infinity,
                                constraints: BoxConstraints(
                                  minHeight: defaultCardHeight,
                                ),
                                decoration: BoxDecoration(
                                  color: ColorsTheme.latarKomponen,
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                padding: const EdgeInsets.fromLTRB(
                                  22,
                                  20,
                                  22,
                                  24,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Status Pill (Belum selesai / Selesai)
                                    _buildStatusPill(isDark),
                                    const SizedBox(height: 12),

                                    // Judul Tugas (Large Bold)
                                    TextField(
                                      controller: _titleController,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: _isCompleted
                                            ? ColorsTheme.teksSekunder
                                            : ColorsTheme.teks,
                                        decoration: _isCompleted
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                        decorationColor:
                                            ColorsTheme.teksSekunder,
                                        height: 1.25,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Judul tugas',
                                        hintStyle: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: ColorsTheme.teksSekunder
                                              .withValues(alpha: 0.4),
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                        isDense: true,
                                      ),
                                      onChanged: (_) => _onTextChanged(),
                                    ),
                                    const SizedBox(height: 8),

                                    // Mata Kuliah Row
                                    _buildSubjectRow(),
                                    const SizedBox(height: 16),

                                    // Deadline / Tenggat Card
                                    _buildDeadlineCard(isDark),
                                    const SizedBox(height: 20),

                                    // Label Catatan
                                    Text(
                                      'Catatan',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: ColorsTheme.teksSekunder,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // Area Menulis Bergaris (Ruled Notepad Lines)
                                    _buildRuledNotesArea(notesAreaMinHeight),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // Jarak antara kartu detail dan tombol selesai di bawah
                          const SizedBox(height: bottomGap),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // 3. Tombol Aksi Bawah ("Tandai selesai" / "Selesai • ketuk untuk batalkan")
              Container(
                padding: const EdgeInsets.only(top: 8),
                child: _buildBottomActionButton(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Top App Bar ---

  Widget _buildTopBar() {
    final canUndo = _textUndoStack.length > 1;
    final canRedo = _textRedoStack.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Row(
        children: [
          // Tombol Kembali
          _buildCircleIconButton(
            icon: Icons.chevron_left_rounded,
            size: 24,
            onTap: () async {
              await _saveToDatabase();
              if (mounted) Navigator.pop(context, _hasSavedOnce);
            },
          ),
          const SizedBox(width: 10),

          // Badge "Tersimpan otomatis"
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: ColorsTheme.latarKomponen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF4E9B66),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _saveStatus,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: ColorsTheme.teks,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),

          // Tombol Undo
          _buildCircleIconButton(
            icon: Icons.undo_rounded,
            size: 20,
            iconColor: canUndo
                ? ColorsTheme.teks
                : ColorsTheme.teksSekunder.withValues(alpha: 0.35),
            onTap: canUndo ? _undo : () {},
          ),
          const SizedBox(width: 8),

          // Tombol Redo
          _buildCircleIconButton(
            icon: Icons.redo_rounded,
            size: 20,
            iconColor: canRedo
                ? ColorsTheme.teks
                : ColorsTheme.teksSekunder.withValues(alpha: 0.35),
            onTap: canRedo ? _redo : () {},
          ),

          // Tombol Hapus (Opsi tambahan)
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

  // --- Main Card Elements ---

  Widget _buildStatusPill(bool isDark) {
    final bgColor = _isCompleted
        ? (isDark ? const Color(0xFF27382B) : const Color(0xFFDDEBD9))
        : (isDark ? const Color(0xFF1E2B33) : const Color(0xFFDDE6EC));

    final textColor = _isCompleted
        ? (isDark ? const Color(0xFF8ED7A5) : const Color(0xFF2D673E))
        : (isDark ? const Color(0xFF8BB5CE) : const Color(0xFF2B5470));

    return InkWell(
      onTap: _toggleOverallComplete,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          _isCompleted ? 'Selesai' : 'Belum selesai',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectRow() {
    return InkWell(
      onTap: _showSubjectPicker,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_view_day_outlined,
              size: 15,
              color: ColorsTheme.teksSekunder,
            ),
            const SizedBox(width: 6),
            Text(
              _subject.isNotEmpty ? _subject : 'Pilih Mata Kuliah',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ColorsTheme.teksSekunder,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: ColorsTheme.teksSekunder,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeadlineCard(bool isDark) {
    final cardBg = isDark ? const Color(0xFF3B271E) : const Color(0xFFF1D8C9);
    final iconCircleBg = isDark
        ? const Color(0xFF4C3328)
        : const Color(0xFFDFC4B4);
    final textColor = isDark
        ? const Color(0xFFEAA690)
        : const Color(0xFF7E3924);

    return InkWell(
      onTap: _pickDeadline,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            // Icon Jam dalam Lingkaran
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconCircleBg,
              ),
              child: Icon(
                Icons.access_time_rounded,
                size: 18,
                color: textColor,
              ),
            ),
            const SizedBox(width: 12),

            // Teks Tenggat & Waktu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tenggat',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: textColor.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateTimeHelper.formatDeadlineKeep(_selectedDeadline),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),

            // Chevron kanan
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: textColor.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuledNotesArea(double minHeight) {
    const double lineSpacing = 28.0;
    final effectiveMinHeight = minHeight > 140.0 ? minHeight : 140.0;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: effectiveMinHeight),
      child: CustomPaint(
        painter: _RuledNotesPainter(
          lineColor: ColorsTheme.teksSekunder.withValues(alpha: 0.15),
          lineHeight: lineSpacing,
        ),
        child: TextField(
          controller: _notesController,
          maxLines: null,
          style: TextStyle(
            fontSize: 14,
            height: lineSpacing / 14, // Pastikan teks pas duduk di atas garis
            color: ColorsTheme.teks,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
            hintText: 'Tulis instruksi atau catatan tugas di sini...',
            hintStyle: TextStyle(
              fontSize: 14,
              height: lineSpacing / 14,
              color: ColorsTheme.teksSekunder.withValues(alpha: 0.4),
            ),
          ),
          onChanged: (_) => _onTextChanged(),
        ),
      ),
    );
  }

  // --- Bottom Action Button ---

  Widget _buildBottomActionButton(bool isDark) {
    if (!_isCompleted) {
      // Tombol Belum Selesai -> "Tandai selesai" (Warna amber/aksen hangat)
      return Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _toggleOverallComplete,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsTheme.aksen,
              foregroundColor: ColorsTheme.teksDiAksen,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_rounded,
                  size: 20,
                  color: ColorsTheme.teksDiAksen,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tandai selesai',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ColorsTheme.teksDiAksen,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Tombol Sudah Selesai -> "Selesai • ketuk untuk batalkan" (Warna matcha soft)
      final btnBg = isDark ? const Color(0xFF283B2B) : const Color(0xFFD5E8D2);
      final btnText = isDark
          ? const Color(0xFF8ED7A5)
          : const Color(0xFF275C34);

      return Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _toggleOverallComplete,
            style: ElevatedButton.styleFrom(
              backgroundColor: btnBg,
              foregroundColor: btnText,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_rounded, size: 20, color: btnText),
                const SizedBox(width: 8),
                Text(
                  'Selesai • ketuk untuk batalkan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: btnText,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}

/// Custom Painter untuk menggambar garis horizontal berjarak rata (buku catatan)
class _RuledNotesPainter extends CustomPainter {
  final Color lineColor;
  final double lineHeight;

  _RuledNotesPainter({required this.lineColor, required this.lineHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0;

    for (
      double y = lineHeight;
      y < size.height + (lineHeight * 2);
      y += lineHeight
    ) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RuledNotesPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor ||
        oldDelegate.lineHeight != lineHeight;
  }
}

/// Widget Maskot Lumut yang Mengintip di Atas Kanan Kartu
class _PeekingMascot extends StatelessWidget {
  final bool isCompleted;

  const _PeekingMascot({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    // SVG kepala Lumut berheadphone yang mengintip di atas kartu
    final svgContent = isCompleted
        ? '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="85 70 210 175" width="100%" height="100%">
  <!-- Daun di atas -->
  <path d="M150 140Q176 78 238 90Q228 142 150 140Z" fill="#46624D"/>
  <path d="M160 134Q198 112 230 95" fill="none" stroke="#7FA886" stroke-width="2.5" stroke-linecap="round"/>
  <!-- Kepala Lumut -->
  <ellipse cx="190" cy="205" rx="84" ry="66" fill="#9DBF92"/>
  <ellipse cx="190" cy="232" rx="50" ry="30" fill="#B7D3A8"/>
  <!-- Bando Headphone -->
  <path d="M114 192Q190 98 266 192" fill="none" stroke="#E3A65C" stroke-width="9" stroke-linecap="round"/>
  <!-- Earcup Headphone -->
  <rect x="98" y="184" width="24" height="44" rx="10" fill="#E3A65C"/>
  <rect x="258" y="184" width="24" height="44" rx="10" fill="#E3A65C"/>
  <rect x="104" y="192" width="12" height="28" rx="6" fill="#C98B3C"/>
  <rect x="264" y="192" width="12" height="28" rx="6" fill="#C98B3C"/>
  <!-- Pipi Merona -->
  <ellipse cx="136" cy="222" rx="13" ry="7.5" fill="#E8A08A" opacity="0.75"/>
  <ellipse cx="244" cy="222" rx="13" ry="7.5" fill="#E8A08A" opacity="0.75"/>
  <!-- Mata Bahagia Senyum (^ ^) & Mulut Ceria -->
  <path d="M148 208Q158 194 168 208" fill="none" stroke="#2B332E" stroke-width="3.5" stroke-linecap="round"/>
  <path d="M212 208Q222 194 232 208" fill="none" stroke="#2B332E" stroke-width="3.5" stroke-linecap="round"/>
  <path d="M178 218Q190 234 202 218Z" fill="#7A3F34"/>
</svg>
'''
        : '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="85 70 210 175" width="100%" height="100%">
  <!-- Daun di atas -->
  <path d="M150 140Q176 78 238 90Q228 142 150 140Z" fill="#46624D"/>
  <path d="M160 134Q198 112 230 95" fill="none" stroke="#7FA886" stroke-width="2.5" stroke-linecap="round"/>
  <!-- Kepala Lumut -->
  <ellipse cx="190" cy="205" rx="84" ry="66" fill="#9DBF92"/>
  <ellipse cx="190" cy="232" rx="50" ry="30" fill="#B7D3A8"/>
  <!-- Bando Headphone -->
  <path d="M114 192Q190 98 266 192" fill="none" stroke="#E3A65C" stroke-width="9" stroke-linecap="round"/>
  <!-- Earcup Headphone -->
  <rect x="98" y="184" width="24" height="44" rx="10" fill="#E3A65C"/>
  <rect x="258" y="184" width="24" height="44" rx="10" fill="#E3A65C"/>
  <rect x="104" y="192" width="12" height="28" rx="6" fill="#C98B3C"/>
  <rect x="264" y="192" width="12" height="28" rx="6" fill="#C98B3C"/>
  <!-- Pipi Merona -->
  <ellipse cx="136" cy="222" rx="13" ry="7.5" fill="#E8A08A" opacity="0.75"/>
  <ellipse cx="244" cy="222" rx="13" ry="7.5" fill="#E8A08A" opacity="0.75"/>
  <!-- Mata Bulat Menatap Lucu & Senyum Kalem -->
  <circle cx="158" cy="210" r="5" fill="#2B332E"/>
  <circle cx="222" cy="210" r="5" fill="#2B332E"/>
  <path d="M185 220Q190 224 195 220" fill="none" stroke="#2B332E" stroke-width="2.5" stroke-linecap="round"/>
</svg>
''';

    return SizedBox(
      width: 126,
      height: 105,
      child: SvgPicture.string(svgContent, fit: BoxFit.contain),
    );
  }
}
