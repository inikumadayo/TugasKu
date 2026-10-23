import 'package:adistyclone/core/constants/mascot_assets.dart';
import 'package:adistyclone/core/theme/colors.dart';
import 'package:adistyclone/services/update_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

/// Menampilkan dialog pembaruan rilis aplikasi
Future<void> showUpdateDialog(
  BuildContext context, {
  required UpdateInfo updateInfo,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => _UpdateDialogContent(updateInfo: updateInfo),
  );
}

class _UpdateDialogContent extends StatefulWidget {
  final UpdateInfo updateInfo;

  const _UpdateDialogContent({required this.updateInfo});

  @override
  State<_UpdateDialogContent> createState() => _UpdateDialogContentState();
}

enum _DownloadStatus { idle, downloading, completed, error }

class _UpdateDialogContentState extends State<_UpdateDialogContent> {
  _DownloadStatus _status = _DownloadStatus.idle;
  double _progress = 0.0;
  int _receivedBytes = 0;
  int _totalBytes = 0;
  String? _downloadedFilePath;
  String _errorMessage = '';
  CancelToken? _cancelToken;

  @override
  void dispose() {
    _cancelToken?.cancel();
    super.dispose();
  }

  void _startDownload() async {
    final apkUrl = widget.updateInfo.apkDownloadUrl;
    if (apkUrl == null || apkUrl.isEmpty) {
      // Fallback langsung buka link release jika APK tidak terlampir
      _openInBrowser();
      return;
    }

    final fileName = widget.updateInfo.apkName ??
        'TugasKu-v${widget.updateInfo.latestVersion}.apk';

    setState(() {
      _status = _DownloadStatus.downloading;
      _progress = 0.0;
      _receivedBytes = 0;
      _totalBytes = widget.updateInfo.apkSize ?? 0;
      _errorMessage = '';
      _cancelToken = CancelToken();
    });

    try {
      final path = await UpdateService.downloadApk(
        downloadUrl: apkUrl,
        fileName: fileName,
        cancelToken: _cancelToken!,
        onProgress: (received, total) {
          if (!mounted) return;
          setState(() {
            _receivedBytes = received;
            if (total > 0) {
              _totalBytes = total;
              _progress = received / total;
            }
          });
        },
      );

      if (!mounted) return;

      if (path != null) {
        setState(() {
          _status = _DownloadStatus.completed;
          _downloadedFilePath = path;
        });

        // Langsung picu instalasi setelah download selesai
        _installApk();
      } else {
        setState(() {
          _status = _DownloadStatus.idle;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = _DownloadStatus.error;
        _errorMessage = 'Gagal mengunduh: ${e.toString()}';
      });
    }
  }

  void _cancelDownload() {
    _cancelToken?.cancel('Dibatalkan oleh pengguna');
    setState(() {
      _status = _DownloadStatus.idle;
      _progress = 0.0;
    });
  }

  void _installApk() async {
    if (_downloadedFilePath != null) {
      final success = await UpdateService.installApk(
        _downloadedFilePath!,
        fallbackUrl: widget.updateInfo.apkDownloadUrl,
      );

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Silakan buka file APK di notifikasi/folder unduhan untuk menginstall.',
            ),
          ),
        );
      }
    }
  }

  void _openInBrowser() async {
    final uri = Uri.parse(
      widget.updateInfo.apkDownloadUrl ?? widget.updateInfo.releaseUrl,
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 MB';
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.updateInfo;

    // Tentukan maskot berdasarkan status download
    String mascotAsset;
    switch (_status) {
      case _DownloadStatus.idle:
        mascotAsset = MascotAssets.berangkat;
        break;
      case _DownloadStatus.downloading:
        mascotAsset = MascotAssets.mengetik;
        break;
      case _DownloadStatus.completed:
        mascotAsset = MascotAssets.selesai;
        break;
      case _DownloadStatus.error:
        mascotAsset = MascotAssets.mengantuk;
        break;
    }

    return Dialog(
      backgroundColor: ColorsTheme.latarKomponen,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Maskot Lumut
            SvgPicture.asset(
              mascotAsset,
              height: 80,
            ),
            const SizedBox(height: 12),

            // Judul Pembaruan
            Text(
              _status == _DownloadStatus.completed
                  ? 'Unduhan Selesai! 🎉'
                  : 'Pembaruan Tersedia',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ColorsTheme.teks,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),

            // Badge Versi
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: ColorsTheme.chipBatu,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'v${info.latestVersion}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: ColorsTheme.teksChipBatu,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Terpasang: v${info.currentVersion}',
                  style: TextStyle(
                    fontSize: 12,
                    color: ColorsTheme.teksSekunder,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Kotak Catatan Rilis / Changelog
            if (_status == _DownloadStatus.idle || _status == _DownloadStatus.error) ...[
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 120),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColorsTheme.latar,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: ColorsTheme.teksSekunder.withValues(alpha: 0.15),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    info.changelog.isNotEmpty
                        ? info.changelog
                        : 'Pembaruan dan perbaikan performa aplikasi.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: ColorsTheme.teks,
                      height: 1.45,
                    ),
                  ),
                ),
              ),
              if (info.formattedSize.isNotEmpty) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Ukuran: ${info.formattedSize}',
                    style: TextStyle(
                      fontSize: 11,
                      color: ColorsTheme.teksSekunder,
                    ),
                  ),
                ),
              ],
            ],

            // Progress Bar saat Downloading
            if (_status == _DownloadStatus.downloading) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _progress > 0 ? _progress : null,
                  minHeight: 10,
                  backgroundColor: ColorsTheme.kartuUtama.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(ColorsTheme.aksen),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(_progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: ColorsTheme.aksen,
                    ),
                  ),
                  Text(
                    '${_formatBytes(_receivedBytes)} / ${_formatBytes(_totalBytes)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: ColorsTheme.teksSekunder,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Pesan Error jika gagal
            if (_status == _DownloadStatus.error) ...[
              const SizedBox(height: 10),
              Text(
                _errorMessage.isNotEmpty
                    ? _errorMessage
                    : 'Gagal mengunduh otomatis. Kamu bisa mengunduhnya langsung melalui browser.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red.shade400,
                ),
              ),
            ],

            // Keterangan Siap Pasang
            if (_status == _DownloadStatus.completed) ...[
              const SizedBox(height: 8),
              Text(
                'File APK berhasil diunduh. Tekan tombol di bawah untuk memasang pembaruan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: ColorsTheme.teksSekunder,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
            ],

            const SizedBox(height: 18),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    switch (_status) {
      case _DownloadStatus.idle:
        return Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: ColorsTheme.teksSekunder,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Nanti Saja'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _startDownload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsTheme.aksen,
                  foregroundColor: ColorsTheme.teksDiAksen,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Update Sekarang',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );

      case _DownloadStatus.downloading:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _cancelDownload,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: ColorsTheme.teksSekunder.withValues(alpha: 0.3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              'Batalkan Unduhan',
              style: TextStyle(
                color: ColorsTheme.teks,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );

      case _DownloadStatus.completed:
        return Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: ColorsTheme.teksSekunder,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Tutup'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _installApk,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsTheme.aksen,
                  foregroundColor: ColorsTheme.teksDiAksen,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Pasang Sekarang',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );

      case _DownloadStatus.error:
        return Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: ColorsTheme.teksSekunder,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Tutup'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _openInBrowser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsTheme.aksen,
                  foregroundColor: ColorsTheme.teksDiAksen,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Buka di Browser',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
    }
  }
}
