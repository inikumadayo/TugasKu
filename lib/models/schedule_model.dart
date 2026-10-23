import 'package:adistyclone/core/utils/date_time_helper.dart';

/// Model class untuk data Jadwal/Schedule
class ScheduleModel {
  final String id;
  final String title;
  final String ruang;
  final String waktuMulai; // format "HH:mm"
  final String waktuSelesai; // format "HH:mm"
  final String jenis;
  final int hari; // 1=Senin, 2=Selasa, ..., 7=Minggu
  final String? dosenPengampu;
  final int? sks;

  const ScheduleModel({
    required this.id,
    required this.title,
    required this.ruang,
    required this.waktuMulai,
    required this.waktuSelesai,
    required this.jenis,
    required this.hari,
    this.dosenPengampu,
    this.sks,
  });

  ScheduleModel copyWith({
    String? id,
    String? title,
    String? ruang,
    String? waktuMulai,
    String? waktuSelesai,
    String? jenis,
    int? hari,
    String? dosenPengampu,
    int? sks,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      ruang: ruang ?? this.ruang,
      waktuMulai: waktuMulai ?? this.waktuMulai,
      waktuSelesai: waktuSelesai ?? this.waktuSelesai,
      jenis: jenis ?? this.jenis,
      hari: hari ?? this.hari,
      dosenPengampu: dosenPengampu ?? this.dosenPengampu,
      sks: sks ?? this.sks,
    );
  }

  /// Convert ke Map untuk penyimpanan Hive
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'ruang': ruang,
      'waktuMulai': waktuMulai,
      'waktuSelesai': waktuSelesai,
      'jenis': jenis,
      'hari': hari,
      'dosenPengampu': dosenPengampu ?? '',
      'sks': sks,
    };
  }

  /// Buat ScheduleModel dari Map (data Hive)
  factory ScheduleModel.fromMap(Map<dynamic, dynamic> map) {
    return ScheduleModel(
      id: (map['id'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      ruang: (map['ruang'] as String?) ?? '',
      waktuMulai: (map['waktuMulai'] as String?) ?? '',
      waktuSelesai: (map['waktuSelesai'] as String?) ?? '',
      jenis: (map['jenis'] as String?) ?? '',
      hari: (map['hari'] as int?) ?? 1,
      dosenPengampu: map['dosenPengampu'] as String?,
      sks: map['sks'] as int?,
    );
  }

  /// Nama hari berdasarkan angka
  String get namaHari => DateTimeHelper.getNamaHari(hari);

  /// Singkatan hari
  String get singkatanHari {
    if (hari >= 1 && hari <= 6) {
      return DateTimeHelper.singkatanHari[hari - 1];
    }
    return hari == 7 ? 'Min' : '';
  }
}
