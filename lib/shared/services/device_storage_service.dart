import 'package:flutter/services.dart';

class DeviceStorageInfo {
  final int totalBytes;
  final int freeBytes;

  const DeviceStorageInfo({
    required this.totalBytes,
    required this.freeBytes,
  });

  int get usedBytes => (totalBytes - freeBytes).clamp(0, totalBytes);
}

/// Reads device filesystem storage (total/free) via a tiny platform channel.
///
/// Notes:
/// - This reports *device* storage (apps/system/media), not just photos.
/// - Requires native implementations in iOS/Android hosts.
class DeviceStorageService {
  static const MethodChannel _channel = MethodChannel('swipe_to_clean/device_storage');

  Future<DeviceStorageInfo> getStorageInfo() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('getStorageInfo');
      if (result == null) return const DeviceStorageInfo(totalBytes: 0, freeBytes: 0);

      final total = (result['totalBytes'] as num?)?.toInt() ?? 0;
      final free = (result['freeBytes'] as num?)?.toInt() ?? 0;
      return DeviceStorageInfo(
        totalBytes: total < 0 ? 0 : total,
        freeBytes: free < 0 ? 0 : free,
      );
    } catch (_) {
      return const DeviceStorageInfo(totalBytes: 0, freeBytes: 0);
    }
  }
}

