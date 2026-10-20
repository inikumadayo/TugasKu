import 'package:adistyclone/assets/colors.dart';
import 'package:adistyclone/database/database_helper.dart';
import 'package:adistyclone/models/schedule_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bottom sheet untuk menambah jadwal baru.
///
/// Memanggil [showAddScheduleDialog] akan menampilkan bottom sheet
/// dengan form input. Mengembalikan `true` jika jadwal berhasil disimpan.
Future<bool> showAddScheduleDialog(
  BuildContext context, {
  required int defaultHari,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _AddScheduleSheet(defaultHari: defaultHari),
  );

  return result ?? false;
}

class _AddScheduleSheet extends StatefulWidget {
  final int defaultHari;
  const _AddScheduleSheet({required this.defaultHari});

  @override
  State<_AddScheduleSheet> createState() => _AddScheduleSheetState();
}

class _AddScheduleSheetState extends State<_AddScheduleSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _ruangController;
  late final TextEditingController _waktuMulaiController;
  late final TextEditingController _waktuSelesaiController;
  String _selectedJenis = 'Mata Kuliah';
  late int _selectedHari;

  static const List<String> _dayLabels = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
  ];

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
    _titleController = TextEditingController();
    _ruangController = TextEditingController();
    _waktuMulaiController = TextEditingController();
    _waktuSelesaiController = TextEditingController();
    _selectedHari = widget.defaultHari;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _ruangController.dispose();
    _waktuMulaiController.dispose();
    _waktuSelesaiController.dispose();
    super.dispose();
  }

  Future<void> _pickTime({
    required TextEditingController controller,
    required TimeOfDay defaultTime,
  }) async {
    final initial = _parseTime(controller.text, defaultTime);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      setState(() {
        controller.text =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _handleSave() async {
    if (_titleController.text.isEmpty ||
        _ruangController.text.isEmpty ||
        _waktuMulaiController.text.isEmpty ||
        _waktuSelesaiController.text.isEmpty) {
      return;
    }

    final schedule = ScheduleModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      ruang: _ruangController.text,
      waktuMulai: _waktuMulaiController.text,
      waktuSelesai: _waktuSelesaiController.text,
      jenis: _selectedJenis,
      hari: _selectedHari,
    );

    await DatabaseHelper.addSchedule(schedule);
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
                  'Tambah jadwal',
                  style: TextStyle(
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: ColorsTheme.teks,
                  ),
                ),
                const SizedBox(height: 20),

                // Nama mata kuliah
                _buildLabel('Judul'),
                const SizedBox(height: 8),
                _buildInputField(
                  controller: _titleController,
                  hint: 'Pemrograman Mobile',
                ),
                const SizedBox(height: 20),

                // Jenis
                _buildLabel('Jenis'),
                const SizedBox(height: 8),
                _buildJenisSelector(),
                const SizedBox(height: 20),

                // Hari selector
                _buildLabel('Hari'),
                const SizedBox(height: 8),
                _buildDaySelector(),
                const SizedBox(height: 20),

                // Mulai & Selesai side by side
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Mulai'),
                          const SizedBox(height: 8),
                          _buildTimeField(
                            controller: _waktuMulaiController,
                            hint: '07.30',
                            defaultTime: const TimeOfDay(hour: 7, minute: 30),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Selesai'),
                          const SizedBox(height: 8),
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
                const SizedBox(height: 20),

                // Ruang
                _buildLabel('Ruang'),
                const SizedBox(height: 8),
                _buildInputField(
                  controller: _ruangController,
                  hint: 'Ruang Lab 2',
                ),
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
                            'Simpan jadwal',
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
  }) {
    return TextField(
      controller: controller,
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

  Widget _buildDaySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(_dayLabels.length, (index) {
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
                  : Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              _dayLabels[index],
              style: TextStyle(
                fontFamily: GoogleFonts.poppins().fontFamily,
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
                  : Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              jenis,
              style: TextStyle(
                fontFamily: GoogleFonts.poppins().fontFamily,
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
