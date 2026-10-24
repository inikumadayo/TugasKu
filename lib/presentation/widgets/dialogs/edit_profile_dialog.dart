import 'dart:convert';

import 'package:adistyclone/core/theme/colors.dart';
import 'package:adistyclone/database/database_helper.dart';
import 'package:adistyclone/models/user_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Menampilkan dialog untuk mengedit profil atau inisialisasi awal.
///
/// Mengembalikan `true` jika profil berhasil disimpan.
Future<bool> showEditProfileDialog(
  BuildContext context, {
  bool isFirstTime = false,
}) async {
  final currentProfile = DatabaseHelper.getUserProfile();
  final nameController = TextEditingController(text: currentProfile.name);
  final descController = TextEditingController(
    text: currentProfile.description,
  );

  String? profileImageBase64 = currentProfile.profileImageBase64;
  String? bannerImageBase64 = currentProfile.bannerImageBase64;

  final picker = ImagePicker();

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: !isFirstTime,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) {
        Future<void> pickProfileImage() async {
          try {
            final XFile? file = await picker.pickImage(
              source: ImageSource.gallery,
              maxWidth: 800,
              maxHeight: 800,
              imageQuality: 75,
            );
            if (file != null) {
              final bytes = await file.readAsBytes();
              setDialogState(() {
                profileImageBase64 = base64Encode(bytes);
              });
            }
          } catch (e) {
            debugPrint('Error picking profile image: $e');
          }
        }

        Future<void> pickBannerImage() async {
          try {
            final XFile? file = await picker.pickImage(
              source: ImageSource.gallery,
              maxWidth: 1200,
              maxHeight: 600,
              imageQuality: 80,
            );
            if (file != null) {
              final bytes = await file.readAsBytes();
              setDialogState(() {
                bannerImageBase64 = base64Encode(bytes);
              });
            }
          } catch (e) {
            debugPrint('Error picking banner image: $e');
          }
        }

        return AlertDialog(
          backgroundColor: ColorsTheme.latarKomponen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: EdgeInsets.zero,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Banner & Avatar Area
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Banner Image
                    GestureDetector(
                      onTap: pickBannerImage,
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: ColorsTheme.kartuUtama.withValues(alpha: 0.25),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                          image: bannerImageBase64 != null
                              ? DecorationImage(
                                  image: MemoryImage(
                                    base64Decode(bannerImageBase64!),
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.15),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.black45,
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Avatar Photo
                    Positioned(
                      bottom: -40,
                      child: GestureDetector(
                        onTap: pickProfileImage,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ColorsTheme.latarKomponen,
                                border: Border.all(
                                  color: ColorsTheme.latarKomponen,
                                  width: 3.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: profileImageBase64 != null
                                    ? Image.memory(
                                        base64Decode(profileImageBase64!),
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        color: ColorsTheme.kartuUtama
                                            .withValues(alpha: 0.15),
                                        child: Icon(
                                          Icons.person_outline_rounded,
                                          color: ColorsTheme.kartuUtama,
                                          size: 40,
                                        ),
                                      ),
                              ),
                            ),
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: ColorsTheme.aksen,
                              child: Icon(
                                Icons.edit,
                                color: ColorsTheme.teks,
                                size: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 50),

                // Form Inputs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Text(
                        isFirstTime
                            ? 'Selamat Datang!\nLengkapi Profilmu'
                            : 'Edit Profil',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ColorsTheme.teks,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Nama Lengkap',
                          prefixIcon: const Icon(Icons.person_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descController,
                        decoration: InputDecoration(
                          labelText: 'NIM / Deskripsi',
                          prefixIcon: const Icon(Icons.badge_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ketuk foto atau banner di atas untuk mengganti gambar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: ColorsTheme.teksSekunder,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 16,
          ),
          actions: [
            if (!isFirstTime)
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Batal',
                  style: TextStyle(color: ColorsTheme.teksSekunder),
                ),
              ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final desc = descController.text.trim();

                final newProfile = UserProfileModel(
                  name: name.isNotEmpty
                      ? name
                      : (currentProfile.name.isNotEmpty
                          ? currentProfile.name
                          : 'Kuma dayo'),
                  description: desc.isNotEmpty
                      ? desc
                      : (currentProfile.description.isNotEmpty
                          ? currentProfile.description
                          : 'Mahasiswa'),
                  profileImageBase64: profileImageBase64,
                  bannerImageBase64: bannerImageBase64,
                  isInitialized: true,
                );

                await DatabaseHelper.saveUserProfile(newProfile);
                if (context.mounted) Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsTheme.kartuUtama,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Simpan',
                style: TextStyle(color: ColorsTheme.teksDiKartu),
              ),
            ),
          ],
        );
      },
    ),
  );

  return result ?? false;
}
