import 'dart:convert';

import 'package:adistyclone/assets/colors.dart';
import 'package:adistyclone/database/database_helper.dart';
import 'package:adistyclone/utils/edit_profile_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    final profile = DatabaseHelper.getUserProfile();

    return Scaffold(
      backgroundColor: ColorsTheme.latar,
      body: Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Profile",
                          style: TextStyle(
                            color: ColorsTheme.teks,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: GoogleFonts.poppins().fontFamily,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          "Pengaturan Pribadi",
                          style: TextStyle(
                            color: ColorsTheme.teksSekunder,
                            fontSize: 14,
                            fontFamily: GoogleFonts.poppins().fontFamily,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Profile Card dengan Banner di Belakang Foto Profil
              Container(
                decoration: BoxDecoration(
                  color: ColorsTheme.latarKomponen,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    children: [
                      // Banner & Foto Profil Stack
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.bottomCenter,
                        children: [
                          // Banner Image
                          Container(
                            height: 110,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: ColorsTheme.kartuUtama.withValues(
                                alpha: 0.25,
                              ),
                              image: profile.bannerImageBase64 != null
                                  ? DecorationImage(
                                      image: MemoryImage(
                                        base64Decode(
                                          profile.bannerImageBase64!,
                                        ),
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              gradient: profile.bannerImageBase64 == null
                                  ? const LinearGradient(
                                      colors: [
                                        ColorsTheme.kartuUtama,
                                        ColorsTheme.aksen,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                            ),
                          ),
                          // Avatar Foto Profil yang menimpa banner
                          Positioned(
                            bottom: -45,
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ColorsTheme.latarKomponen,
                                border: Border.all(
                                  color: ColorsTheme.latarKomponen,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: profile.profileImageBase64 != null
                                    ? Image.memory(
                                        base64Decode(
                                          profile.profileImageBase64!,
                                        ),
                                        width: 90,
                                        height: 90,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        color: ColorsTheme.kartuUtama
                                            .withValues(alpha: 0.15),
                                        child: const Icon(
                                          Icons.person_outline_rounded,
                                          color: ColorsTheme.kartuUtama,
                                          size: 45,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 52),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            Text(
                              profile.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: ColorsTheme.teks,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: GoogleFonts.poppins().fontFamily,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profile.description,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: ColorsTheme.teksSekunder,
                                fontSize: 14,
                                fontFamily: GoogleFonts.poppins().fontFamily,
                              ),
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () async {
                                final updated = await showEditProfileDialog(
                                  context,
                                );
                                if (updated && mounted) setState(() {});
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: ColorsTheme.aksen,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "Edit Profile",
                                  style: TextStyle(
                                    color: ColorsTheme.teks,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    fontFamily:
                                        GoogleFonts.poppins().fontFamily,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Coming Soon...",
                        style: TextStyle(
                          color: ColorsTheme.teks,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.poppins().fontFamily,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Lost in quiet places,\ndreaming of worlds with magic.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ColorsTheme.teksSekunder,
                          fontSize: 12,
                          fontFamily: GoogleFonts.poppins().fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
