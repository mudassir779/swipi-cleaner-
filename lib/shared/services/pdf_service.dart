import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:photo_manager/photo_manager.dart';

/// Service for creating PDFs from photos
class PdfService {
  /// Create PDF from multiple photos
  /// Returns the path to the created PDF file
  Future<String?> createPdfFromPhotos({
    required List<AssetEntity> photos,
    String? title,
    PdfPageFormat format = PdfPageFormat.a4,
    bool fitToPage = true,
  }) async {
    try {
      final pdf = pw.Document();

      for (final photo in photos) {
        final file = await photo.file;
        if (file == null) continue;

        final bytes = await file.readAsBytes();
        final image = pw.MemoryImage(bytes);

        pdf.addPage(
          pw.Page(
            pageFormat: format,
            margin: const pw.EdgeInsets.all(20),
            build: (pw.Context context) {
              if (fitToPage) {
                return pw.Center(
                  child: pw.Image(image, fit: pw.BoxFit.contain),
                );
              } else {
                return pw.Center(
                  child: pw.Image(image),
                );
              }
            },
          ),
        );
      }

      // Save to documents directory
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = title ?? 'photos_$timestamp';
      final filePath = '${dir.path}/$fileName.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      return filePath;
    } catch (e) {
      debugPrint('Error creating PDF: $e');
      return null;
    }
  }

  /// Create PDF from photo files
  Future<String?> createPdfFromFiles({
    required List<File> files,
    String? title,
    PdfPageFormat format = PdfPageFormat.a4,
  }) async {
    try {
      final pdf = pw.Document();

      for (final file in files) {
        final bytes = await file.readAsBytes();
        final image = pw.MemoryImage(bytes);

        pdf.addPage(
          pw.Page(
            pageFormat: format,
            margin: const pw.EdgeInsets.all(20),
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(image, fit: pw.BoxFit.contain),
              );
            },
          ),
        );
      }

      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = title ?? 'photos_$timestamp';
      final filePath = '${dir.path}/$fileName.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      return filePath;
    } catch (e) {
      debugPrint('Error creating PDF: $e');
      return null;
    }
  }

  /// Get available page formats
  static List<PdfPageFormatOption> get pageFormats => [
        PdfPageFormatOption('A4', PdfPageFormat.a4),
        PdfPageFormatOption('Letter', PdfPageFormat.letter),
        PdfPageFormatOption('A3', PdfPageFormat.a3),
        PdfPageFormatOption('A5', PdfPageFormat.a5),
      ];
}

/// Page format option for UI
class PdfPageFormatOption {
  final String name;
  final PdfPageFormat format;

  PdfPageFormatOption(this.name, this.format);
}
