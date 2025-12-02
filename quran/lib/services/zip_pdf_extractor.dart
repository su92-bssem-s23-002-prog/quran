import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class ZipPdfExtractor {
  /// Extracts PDFs from the given ZIP path into the app's documents/quran_pdfs directory.
  /// Returns a list of extracted local file paths. Skips extraction if already present.
  static Future<List<String>> extractIfNeeded({
    required String zipFilePath,
    String outputSubdir = 'quran_pdfs',
  }) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final outDir = Directory('${docsDir.path}/$outputSubdir');
    if (!await outDir.exists()) {
      await outDir.create(recursive: true);
    }

    // Quick check: if directory already has at least one PDF, assume extracted
    final existing = outDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.toLowerCase().endsWith('.pdf'))
        .map((f) => f.path)
        .toList();
    if (existing.isNotEmpty) {
      return existing;
    }

    final zipFile = File(zipFilePath);
    if (!await zipFile.exists()) {
      throw Exception('ZIP file not found at $zipFilePath');
    }

    // Use the archive package to extract
    final inputStream = InputFileStream(zipFile.path);
    final archive = ZipDecoder().decodeBuffer(inputStream);

    final extractedPaths = <String>[];
    for (final file in archive) {
      final filename = file.name;
      final outPath = '${outDir.path}/$filename';
      if (file.isFile) {
        final data = file.content as List<int>;
        final outFile = File(outPath);
        await outFile.create(recursive: true);
        await outFile.writeAsBytes(data, flush: true);
        if (outPath.toLowerCase().endsWith('.pdf')) {
          extractedPaths.add(outPath);
        }
      } else {
        await Directory(outPath).create(recursive: true);
      }
    }
    inputStream.close();

    // Return only PDFs; if none, return whatever matched (empty likely means unexpected ZIP structure)
    return extractedPaths;
  }

  /// Extracts PDFs from a ZIP bundled in assets.
  /// First copies the asset ZIP to temp storage, then extracts.
  static Future<List<String>> extractFromAsset({
    required String assetZipPath,
    String outputSubdir = 'quran_pdfs',
  }) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final outDir = Directory('${docsDir.path}/$outputSubdir');
    if (!await outDir.exists()) {
      await outDir.create(recursive: true);
    }

    // Quick check: if directory already has at least one PDF, assume extracted
    final existing = outDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.toLowerCase().endsWith('.pdf'))
        .map((f) => f.path)
        .toList();
    if (existing.isNotEmpty) {
      return existing;
    }

    // Load ZIP from assets
    final ByteData data = await rootBundle.load(assetZipPath);
    final tempDir = await getTemporaryDirectory();
    final tempZipPath = '${tempDir.path}/temp.zip';
    final tempZipFile = File(tempZipPath);
    await tempZipFile.writeAsBytes(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      flush: true,
    );

    // Extract using the existing logic
    final inputStream = InputFileStream(tempZipFile.path);
    final archive = ZipDecoder().decodeBuffer(inputStream);

    final extractedPaths = <String>[];
    for (final file in archive) {
      final filename = file.name;
      final outPath = '${outDir.path}/$filename';
      if (file.isFile) {
        final fileData = file.content as List<int>;
        final outFile = File(outPath);
        await outFile.create(recursive: true);
        await outFile.writeAsBytes(fileData, flush: true);
        if (outPath.toLowerCase().endsWith('.pdf')) {
          extractedPaths.add(outPath);
        }
      } else {
        await Directory(outPath).create(recursive: true);
      }
    }
    inputStream.close();

    // Clean up temp ZIP
    await tempZipFile.delete();

    return extractedPaths;
  }
}
