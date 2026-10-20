import 'dart:convert';
import 'dart:typed_data';

/// Helper kelas untuk pemrosesan dan konversi gambar (Base64 <-> Bytes)
class ImageHelper {
  /// Decode string Base64 menjadi [Uint8List] dengan aman (mengembalikan null jika null atau invalid)
  static Uint8List? bytesFromBase64(String? base64Str) {
    if (base64Str == null || base64Str.isEmpty) return null;
    try {
      return base64Decode(base64Str);
    } catch (_) {
      return null;
    }
  }

  /// Encode byte array menjadi string Base64
  static String base64FromBytes(Uint8List bytes) {
    return base64Encode(bytes);
  }
}
