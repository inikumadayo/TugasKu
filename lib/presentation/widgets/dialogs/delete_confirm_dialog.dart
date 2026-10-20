import 'package:adistyclone/core/theme/colors.dart';
import 'package:flutter/material.dart';

/// Dialog utilitas untuk konfirmasi penghapusan (Jadwal, Tugas, dsb).
///
/// Mengembalikan `true` jika pengguna menekan tombol "Hapus",
/// dan `false` jika menekan "Batal" atau menutup dialog.
Future<bool> showDeleteConfirmDialog(
  BuildContext context, {
  required String title,
  required String itemName,
  String? message,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: ColorsTheme.latarKomponen,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: ColorsTheme.teks,
        ),
      ),
      content: Text(
        message ?? 'Apakah kamu yakin ingin menghapus "$itemName"?',
        style: TextStyle(
          color: ColorsTheme.teks,
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
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade400,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Hapus',
            style: TextStyle(color: ColorsTheme.latarKomponen),
          ),
        ),
      ],
    ),
  );

  return result ?? false;
}
