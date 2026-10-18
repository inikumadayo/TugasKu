/// Model class untuk data Jadwal/Schedule
class ScheduleModel {
  String id;
  String title;
  String ruang;
  String waktuMulai; // format "HH:mm"
  String waktuSelesai; // format "HH:mm"
  String jenis;
  int hari; // 1=Senin, 2=Selasa, ..., 7=Minggu

  ScheduleModel({
    required this.id,
    required this.title,
    required this.ruang,
    required this.waktuMulai,
    required this.waktuSelesai,
    required this.jenis,
    required this.hari,
  });

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
    };
  }

  /// Buat ScheduleModel dari Map (data Hive)
  factory ScheduleModel.fromMap(Map<dynamic, dynamic> map) {
    return ScheduleModel(
      id: map['id'] as String,
      title: map['title'] as String,
      ruang: map['ruang'] as String,
      waktuMulai: map['waktuMulai'] as String,
      waktuSelesai: map['waktuSelesai'] as String,
      jenis: map['jenis'] as String,
      hari: map['hari'] as int,
    );
  }

  /// Nama hari berdasarkan angka
  String get namaHari {
    const days = [
      '',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return days[hari];
  }

  /// Singkatan hari
  String get singkatanHari {
    const days = ['', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return days[hari];
  }
}
