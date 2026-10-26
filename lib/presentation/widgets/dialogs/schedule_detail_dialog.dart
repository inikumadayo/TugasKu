import 'package:adistyclone/core/theme/colors.dart';
import 'package:adistyclone/core/utils/date_time_helper.dart';
import 'package:adistyclone/database/database_helper.dart';
import 'package:adistyclone/models/schedule_model.dart';
import 'package:adistyclone/presentation/widgets/dialogs/delete_confirm_dialog.dart';
import 'package:flutter/material.dart';

/// Menampilkan bottom sheet detail atau tambah jadwal perkuliahan.
///
/// Jika [schedule] bernilai `null`, dialog akan membuka form kosong untuk menambah jadwal baru.
/// Mengembalikan `true` jika jadwal berhasil ditambahkan, diperbarui, atau dihapus.
Future<bool> showScheduleDetailDialog(
  BuildContext context, {
  ScheduleModel? schedule,
  int? defaultHari,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _ScheduleDetailSheet(
      schedule: schedule,
      defaultHari: defaultHari,
    ),
  );

  return result ?? false;
}

class _ScheduleDetailSheet extends StatefulWidget {
  final ScheduleModel? schedule;
  final int? defaultHari;

  const _ScheduleDetailSheet({
    this.schedule,
    this.defaultHari,
  });

  @override
  State<_ScheduleDetailSheet> createState() => _ScheduleDetailSheetState();
}

class _ScheduleDetailSheetState extends State<_ScheduleDetailSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _ruangController;
  late final TextEditingController _waktuMulaiController;
  late final TextEditingController _waktuSelesaiController;
  late final TextEditingController _dosenController;
  late final TextEditingController _sksController;
  late String _selectedJenis;
  late int _selectedHari;

  bool get _isNew => widget.schedule == null;

  static const List<String> _jenisOptions = [
    'Mata Kuliah',
    'Praktikum',
    'Asprak',
    'Rapat',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    final schedule = widget.schedule;
    _titleController = TextEditingController(text: schedule?.title ?? '');
    _ruangController = TextEditingController(text: schedule?.ruang ?? '');
    _waktuMulaiController =
        TextEditingController(text: schedule?.waktuMulai ?? '');
    _waktuSelesaiController =
        TextEditingController(text: schedule?.waktuSelesai ?? '');
    _dosenController =
        TextEditingController(text: schedule?.dosenPengampu ?? '');
    _sksController = TextEditingController(
      text: schedule?.sks?.toString() ?? '',
    );
    _selectedJenis =
        (schedule != null && _jenisOptions.contains(schedule.jenis))
            ? schedule.jenis
            : 'Mata Kuliah';
    _selectedHari = schedule?.hari ?? (widget.defaultHari ?? 1);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _ruangController.dispose();
    _waktuMulaiController.dispose();
    _waktuSelesaiController.dispose();
    _dosenController.dispose();
    _sksController.dispose();
    super.dispose();
  }

  Future<void> _pickTime({
    required TextEditingController controller,
    required TimeOfDay defaultTime,
  }) async {
    final initial =
        DateTimeHelper.parseTime(controller.text, fallback: defaultTime);
    final picked =
        await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      setState(() {
        controller.text = DateTimeHelper.formatTimeOfDay(picked);
      });
    }
  }

  Future<void> _handleDelete() async {
    if (widget.schedule == null) return;

    final confirmed = await showDeleteConfirmDialog(
      context,
      title: 'Hapus Jadwal?',
      itemName: widget.schedule!.title,
    );

    if (confirmed && mounted) {
      await DatabaseHelper.deleteSchedule(widget.schedule!.id);
      if (mounted) Navigator.pop(context, true);
    }
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    final ruang = _ruangController.text.trim();
    final waktuMulai = _waktuMulaiController.text.trim();
    final waktuSelesai = _waktuSelesaiController.text.trim();

    if (title.isEmpty ||
        ruang.isEmpty ||
        waktuMulai.isEmpty ||
        waktuSelesai.isEmpty) {
      return;
    }

    final sksText = _sksController.text.trim();
    final sksValue = sksText.isNotEmpty ? int.tryParse(sksText) : null;

    if (_isNew) {
      final newSchedule = ScheduleModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        ruang: ruang,
        waktuMulai: waktuMulai,
        waktuSelesai: waktuSelesai,
        jenis: _selectedJenis,
        hari: _selectedHari,
        dosenPengampu: _dosenController.text.trim(),
        sks: sksValue,
      );
      await DatabaseHelper.addSchedule(newSchedule);
    } else {
      final updatedSchedule = widget.schedule!.copyWith(
        title: title,
        ruang: ruang,
        waktuMulai: waktuMulai,
        waktuSelesai: waktuSelesai,
        jenis: _selectedJenis,
        hari: _selectedHari,
        dosenPengampu: _dosenController.text.trim(),
        sks: sksValue,
      );
      await DatabaseHelper.updateSchedule(updatedSchedule);
    }
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
                      color: ColorsTheme.teksSekunder.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Header: Title & Delete Button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        _isNew ? 'Tambah Jadwal' : 'Detail Jadwal',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: ColorsTheme.teks,
                        ),
                      ),
                    ),
                    if (!_isNew)
                      IconButton(
                        onPressed: _handleDelete,
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.red.shade400,
                          size: 22,
                        ),
                        tooltip: 'Hapus Jadwal',
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                // 1. Judul Mata Kuliah
                _buildLabel('Mata Kuliah'),
                const SizedBox(height: 6),
                _buildInputField(
                  controller: _titleController,
                  hint: 'Pemrograman Mobile',
                ),
                const SizedBox(height: 16),

                // 2. Dosen Pengampu (Opsional)
                _buildLabel('Dosen Pengampu (opsional)'),
                const SizedBox(height: 6),
                _buildInputField(
                  controller: _dosenController,
                  hint: 'Contoh: Dr. Budi Santoso',
                ),
                const SizedBox(height: 16),

                // 3. Jenis
                _buildLabel('Jenis'),
                const SizedBox(height: 6),
                _buildJenisSelector(),
                const SizedBox(height: 16),

                // 4. Hari selector
                _buildLabel('Hari'),
                const SizedBox(height: 6),
                _buildDaySelector(),
                const SizedBox(height: 16),

                // 5. Mulai & Selesai (Berdampingan)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Mulai'),
                          const SizedBox(height: 6),
                          _buildTimeField(
                            controller: _waktuMulaiController,
                            hint: '07.30',
                            defaultTime: const TimeOfDay(hour: 7, minute: 30),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Selesai'),
                          const SizedBox(height: 6),
                          _buildTimeField(
                            controller: _waktuSelesaiController,
                            hint: '09.10',
                            defaultTime: const TimeOfDay(hour: 9, minute: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 6. Ruang & SKS (Berdampingan)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Ruang'),
                          const SizedBox(height: 6),
                          _buildInputField(
                            controller: _ruangController,
                            hint: 'Ruang Lab 2',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    SizedBox(
                      width: 90,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('SKS'),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _sksController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: ColorsTheme.teks,
                            ),
                            decoration: InputDecoration(
                              hintText: '3',
                              hintStyle:
                                  TextStyle(color: Colors.grey.shade400),
                              filled: true,
                              fillColor: ColorsTheme.latar,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
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
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
                              borderRadius: BorderRadius.circular(24),
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
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            _isNew ? 'Simpan Jadwal' : 'Simpan Perubahan',
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
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: ColorsTheme.teksSekunder,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(
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

  Widget _buildDaySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(DateTimeHelper.singkatanHari.length, (index) {
        final dayValue = index + 1; // 1 = Senin, 2 = Selasa, ...
        final isSelected = _selectedHari == dayValue;

        return GestureDetector(
          onTap: () => setState(() => _selectedHari = dayValue),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 48,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? ColorsTheme.kartuUtama : ColorsTheme.latar,
              borderRadius: BorderRadius.circular(20),
              border: isSelected
                  ? null
                  : Border.all(
                      color: ColorsTheme.teksSekunder.withValues(alpha: 0.2),
                    ),
            ),
            child: Text(
              DateTimeHelper.singkatanHari[index],
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : ColorsTheme.teks,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildJenisSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _jenisOptions.map((jenis) {
        final isSelected = _selectedJenis == jenis;

        return GestureDetector(
          onTap: () => setState(() => _selectedJenis = jenis),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? ColorsTheme.kartuUtama : ColorsTheme.latar,
              borderRadius: BorderRadius.circular(20),
              border: isSelected
                  ? null
                  : Border.all(
                      color: ColorsTheme.teksSekunder.withValues(alpha: 0.2),
                    ),
            ),
            child: Text(
              jenis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : ColorsTheme.teks,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimeField({
    required TextEditingController controller,
    required String hint,
    required TimeOfDay defaultTime,
  }) {
    return GestureDetector(
      onTap: () => _pickTime(controller: controller, defaultTime: defaultTime),
      child: AbsorbPointer(
        child: TextField(
          controller: controller,
          style: TextStyle(
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
            suffixIcon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.grey.shade500,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}
