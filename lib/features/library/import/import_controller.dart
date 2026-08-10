import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/parsing/parsed_book.dart';
import '../providers/library_providers.dart';

/// Drives the ebook import flow from either the file picker or a
/// drag-and-drop drop event, shared so both entry points behave identically.
class ImportController {
  static const _allowedExtensions = ['epub', 'pdf', 'txt'];

  static Future<void> pickAndImport(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: [..._allowedExtensions, 'mobi', 'azw3'],
    );
    if (result == null) return;
    final paths = result.files.map((f) => f.path).whereType<String>().toList();
    if (context.mounted) {
      await importPaths(context, ref, paths);
    }
  }

  static Future<void> importPaths(
    BuildContext context,
    WidgetRef ref,
    List<String> paths,
  ) async {
    final importService = ref.read(importServiceProvider);
    var successCount = 0;
    final errors = <String>[];

    for (final path in paths) {
      try {
        await importService.importFromFile(path);
        successCount++;
      } on UnsupportedEbookFormatException catch (e) {
        errors.add('${_fileName(path)}: ${e.toString()}');
      } catch (e) {
        errors.add('${_fileName(path)}: Import failed ($e)');
      }
    }

    if (!context.mounted) return;

    if (successCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imported $successCount book${successCount == 1 ? '' : 's'}.')),
      );
    }

    if (errors.isNotEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Some files could not be imported'),
          content: SingleChildScrollView(
            child: Text(errors.join('\n\n')),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
          ],
        ),
      );
    }
  }

  static String _fileName(String path) => path.split(RegExp(r'[\\/]')).last;
}
