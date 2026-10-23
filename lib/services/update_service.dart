import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Model informasi pembaruan dari GitHub Release
class UpdateInfo {
  final String latestVersion;
  final String currentVersion;
  final String tagName;
  final String title;
  final String changelog;
  final String releaseUrl;
  final String? apkDownloadUrl;
  final String? apkName;
  final int? apkSize;
  final bool hasUpdate;

  const UpdateInfo({
    required this.latestVersion,
    required this.currentVersion,
    required this.tagName,
    required this.title,
    required this.changelog,
    required this.releaseUrl,
    this.apkDownloadUrl,
    this.apkName,
    this.apkSize,
    required this.hasUpdate,
  });

  /// Format ukuran file yang mudah dibaca (misal "52.4 MB")
  String get formattedSize {
    if (apkSize == null || apkSize! <= 0) return '';
    final mb = apkSize! / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }
}

/// Service untuk memeriksa dan mengunduh pembaruan rilis GitHub
class UpdateService {
  static const String repoOwner = 'inikumadayo';
  static const String repoName = 'TugasKu';
  static const String apiUrl =
      'https://api.github.com/repos/$repoOwner/$repoName/releases/latest';

  static final Dio _dio = Dio();

  /// Memeriksa apakah ada rilis terbaru di GitHub
  static Future<UpdateInfo?> checkForUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final response = await _dio.get(
        apiUrl,
        options: Options(
          headers: {
            'Accept': 'application/vnd.github.v3+json',
            'User-Agent': 'TugasKu-App-Updater',
          },
          responseType: ResponseType.json,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode != 200) {
        return null;
      }

      final data = response.data is String
          ? jsonDecode(response.data as String)
          : response.data as Map<String, dynamic>;

      final tagName = (data['tag_name'] as String?) ?? '';
      final cleanLatestVersion = _cleanVersion(tagName);
      final title = (data['name'] as String?) ?? tagName;
      final changelog = (data['body'] as String?) ?? 'Tidak ada catatan rilis.';
      final releaseUrl =
          (data['html_url'] as String?) ??
          'https://github.com/$repoOwner/$repoName/releases';

      // Cari asset APK di daftar release assets
      String? apkUrl;
      String? apkName;
      int? apkSize;

      final assets = data['assets'] as List<dynamic>?;
      if (assets != null && assets.isNotEmpty) {
        for (final asset in assets) {
          final name = (asset['name'] as String?) ?? '';
          if (name.toLowerCase().endsWith('.apk')) {
            apkUrl = asset['browser_download_url'] as String?;
            apkName = name;
            apkSize = asset['size'] as int?;
            break;
          }
        }
      }

      final hasUpdate = _isVersionGreater(cleanLatestVersion, currentVersion);

      return UpdateInfo(
        latestVersion: cleanLatestVersion,
        currentVersion: currentVersion,
        tagName: tagName,
        title: title,
        changelog: changelog,
        releaseUrl: releaseUrl,
        apkDownloadUrl: apkUrl,
        apkName: apkName,
        apkSize: apkSize,
        hasUpdate: hasUpdate,
      );
    } catch (_) {
      return null;
    }
  }

  /// Download APK ke penyimpanan lokal dengan progress tracker
  static Future<String?> downloadApk({
    required String downloadUrl,
    required String fileName,
    required Function(int received, int total) onProgress,
    required CancelToken cancelToken,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final savePath = '${tempDir.path}/$fileName';

      // Hapus file lama jika pernah terdownload sebelumnya
      final file = File(savePath);
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (_) {}
      }

      await _dio.download(
        downloadUrl,
        savePath,
        onReceiveProgress: onProgress,
        cancelToken: cancelToken,
        options: Options(headers: {'User-Agent': 'TugasKu-App-Updater'}),
      );

      return savePath;
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        return null;
      }
      rethrow;
    }
  }

  /// Memicu instalasi file APK yang telah diunduh
  static Future<bool> installApk(String filePath, {String? fallbackUrl}) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;

      final result = await OpenFilex.open(
        filePath,
        type: 'application/vnd.android.package-archive',
      );

      if (result.type != ResultType.done && fallbackUrl != null) {
        // Fallback buka url download jika tidak bisa dibuka otomatis
        final uri = Uri.parse(fallbackUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }

      return result.type == ResultType.done;
    } catch (_) {
      if (fallbackUrl != null) {
        final uri = Uri.parse(fallbackUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
      return false;
    }
  }

  /// Menghapus awalan 'v' atau whitespace dari string versi
  static String _cleanVersion(String version) {
    var v = version.trim();
    if (v.toLowerCase().startsWith('v')) {
      v = v.substring(1);
    }
    return v;
  }

  /// Membandingkan semantic version (misal "1.2.0" > "1.1.0")
  static bool _isVersionGreater(String remote, String local) {
    if (remote.isEmpty) return false;
    if (local.isEmpty) return true;

    try {
      final remoteParts = remote
          .split('.')
          .map((e) => int.tryParse(e) ?? 0)
          .toList();
      final localParts = local
          .split('.')
          .map((e) => int.tryParse(e) ?? 0)
          .toList();

      final maxLength = remoteParts.length > localParts.length
          ? remoteParts.length
          : localParts.length;

      for (int i = 0; i < maxLength; i++) {
        final r = i < remoteParts.length ? remoteParts[i] : 0;
        final l = i < localParts.length ? localParts[i] : 0;

        if (r > l) return true;
        if (r < l) return false;
      }
      return false;
    } catch (_) {
      return remote != local;
    }
  }
}
