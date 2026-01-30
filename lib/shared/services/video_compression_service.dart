import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:video_compress/video_compress.dart' as vc;

enum AppVideoQuality {
  low,    // Low Quality (approx 480p/360p)
  medium, // Medium Quality (approx 720p/sd)
  high,   // Highest Quality available (approx 1080p/Source)
}

class VideoCompressionService {
  final _progressController = StreamController<double>.broadcast();
  Stream<double> get progressStream => _progressController.stream;
  
  // Subscription to the video_compress progress
  dynamic _subscription;

  VideoCompressionService() {
    _subscription = vc.VideoCompress.compressProgress$.subscribe((progress) {
      _progressController.add(progress / 100.0);
    });
  }

  void dispose() {
    _subscription?.unsubscribe();
    _progressController.close();
  }

  /// Compress a video file with specified quality
  Future<File?> compressVideo(File videoFile, AppVideoQuality quality) async {
    try {
      // Map domain quality to package quality
      vc.VideoQuality targetQuality;
      switch (quality) {
        case AppVideoQuality.low:
          targetQuality = vc.VideoQuality.LowQuality;
          break;
        case AppVideoQuality.medium:
          targetQuality = vc.VideoQuality.MediumQuality;
          break;
        case AppVideoQuality.high:
          targetQuality = vc.VideoQuality.DefaultQuality; 
          break;
      }

      await vc.VideoCompress.setLogLevel(0); // Suppress generic logs if possible

      final vc.MediaInfo? info = await vc.VideoCompress.compressVideo(
        videoFile.path,
        quality: targetQuality,
        deleteOrigin: false,
        includeAudio: true,
      );

      if (info != null && info.file != null) {
        return info.file!;
      }
      return null;
    } catch (e) {
      debugPrint('Error compressing video: $e');
      return null;
    }
  }

  Future<void> cancelCompression() async {
    await vc.VideoCompress.cancelCompression();
  }

  /// Get Duration in milliseconds
  Future<int> getVideoDuration(File file) async {
    try {
       final info = await vc.VideoCompress.getMediaInfo(file.path);
       return info.duration?.toInt() ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
