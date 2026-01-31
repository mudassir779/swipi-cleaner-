package com.phakhtoons.clean_gallery

import android.os.Environment
import android.os.StatFs
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  private val channelName = "swipe_to_clean/device_storage"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
      .setMethodCallHandler { call, result ->
        when (call.method) {
          "getStorageInfo" -> {
            try {
              val stat = StatFs(Environment.getDataDirectory().path)
              val blockSize = stat.blockSizeLong
              val totalBytes = blockSize * stat.blockCountLong
              val freeBytes = blockSize * stat.availableBlocksLong
              result.success(
                mapOf(
                  "totalBytes" to totalBytes,
                  "freeBytes" to freeBytes
                )
              )
            } catch (e: Exception) {
              result.success(
                mapOf(
                  "totalBytes" to 0L,
                  "freeBytes" to 0L
                )
              )
            }
          }
          else -> result.notImplemented()
        }
      }
  }
}
