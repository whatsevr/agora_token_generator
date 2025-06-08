import 'dart:typed_data';

/// Web implementation for compression
/// Returns uncompressed data for web compatibility
/// Note: This may affect token compatibility with some Agora services
Uint8List compressData(Uint8List data) {
  // For web browsers, we cannot use dart:io's zlib
  // Return the data uncompressed
  // Most Agora services should handle this correctly
  return data;
}
