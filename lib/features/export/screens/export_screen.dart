import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/book_paths.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/tables.dart';
import '../../../services/export/export_estimator.dart';
import '../../../services/export/format_converter.dart';
import '../../../services/parsing/parsed_book.dart';
import '../../library/providers/library_providers.dart';
import '../../reader/providers/reader_data.dart';
import '../../shell/shell_providers.dart';
import '../../voices/providers/voices_providers.dart';
import '../models/export_scope_type.dart';
import '../providers/export_providers.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  static const _uuid = Uuid();

  ExportScopeType _scopeType = ExportScopeType.entireBook;
  final Set<int> _selectedChapters = {};
  int _rangeStart = 0;
  int _rangeEnd = 0;
  String? _voiceProfileId;
  double _speed = 1.0;
  ExportFormat _format = ExportFormat.mp3_192;
  bool _starting = false;

  @override
  Widget build(BuildContext context) {
    final books = ref.watch(booksStreamProvider).valueOrNull ?? const [];
    final selectedBookId = ref.watch(exportSelectedBookIdProvider) ?? ref.watch(activeBookIdProvider);
    final bookId = books.any((b) => b.id == selectedBookId) ? selectedBookId : (books.isNotEmpty ? books.first.id : null);

    return Scaffold(
      appBar: AppBar(title: const Text('Export')),
      body: books.isEmpty
          ? const _EmptyExport()
          : bookId == null
              ? const SizedBox.shrink()
              : _buildForm(context, bookId, books),
    );
  }

  Widget _buildForm(BuildContext context, String bookId, List<BookRow> books) {
    final chaptersAsync = ref.watch(chaptersProvider(bookId));
    final voicesAsync = ref.watch(voiceProfilesProvider);
    final jobsAsync = ref.watch(exportJobsProvider);
    final book = books.firstWhere((b) => b.id == bookId);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        DropdownButtonFormField<String>(
          value: bookId,
          decoration: const InputDecoration(labelText: 'Book'),
          items: [
            for (final b in books) DropdownMenuItem(value: b.id, child: Text(b.title, overflow: TextOverflow.ellipsis)),
          ],
          onChanged: (v) => ref.read(exportSelectedBookIdProvider.notifier).state = v,
        ),
        const SizedBox(height: 20),
        chaptersAsync.when(
          data: (chapters) => _buildScopeAndOptions(context, bookId, book, chapters, voicesAsync),
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text('Could not load chapters: $e'),
        ),
        const SizedBox(height: 28),
        Text('Export Jobs', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        jobsAsync.when(
          data: (jobs) {
            final relevant = jobs.where((j) => j.bookId == bookId).toList();
            if (relevant.isEmpty) {
              return Text('No exports yet for this book.',
                  style: TextStyle(color: Theme.of(context).extension<AppSurfaceColors>()!.textSecondary));
            }
            return Column(children: [for (final job in relevant) _ExportJobTile(job: job, bookTitle: book.title)]);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
        ),
      ],
    );
  }

  Widget _buildScopeAndOptions(
    BuildContext context,
    String bookId,
    BookRow book,
    List<ParsedChapter> chapters,
    AsyncValue<List<VoiceProfileRow>> voicesAsync,
  ) {
    if (chapters.isEmpty) {
      return const Text('This book has no chapters to export.');
    }
    if (_rangeEnd == 0) _rangeEnd = chapters.length - 1;

    final chapterIndices = _resolveScope(chapters.length);
    final totalWords = chapterIndices.fold(0, (sum, i) => sum + chapters[i].wordCount);
    final estimate = ExportEstimator.estimate(totalWords: totalWords, speed: _speed, format: _format);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Scope', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final type in ExportScopeType.values)
              ChoiceChip(
                label: Text(type.label),
                selected: _scopeType == type,
                onSelected: (_) => setState(() => _scopeType = type),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_scopeType == ExportScopeType.selectedChapters) _buildChapterChecklist(chapters),
        if (_scopeType == ExportScopeType.customRange) _buildRangePickers(chapters),
        const SizedBox(height: 20),
        Text('Voice', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        voicesAsync.when(
          data: (voices) {
            if (voices.isEmpty) {
              return const Text('No voices available. Add one in the Voices tab.');
            }
            _voiceProfileId ??= voices.firstWhere((v) => v.isDefault, orElse: () => voices.first).id;
            return DropdownButtonFormField<String>(
              value: _voiceProfileId,
              items: [for (final v in voices) DropdownMenuItem(value: v.id, child: Text(v.name))],
              onChanged: (v) => setState(() => _voiceProfileId = v),
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text('Error: $e'),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            SizedBox(width: 60, child: Text('Speed', style: Theme.of(context).textTheme.bodyMedium)),
            Expanded(
              child: Slider(
                value: _speed,
                min: 0.5,
                max: 3.0,
                divisions: 25,
                label: '${_speed.toStringAsFixed(2)}x',
                onChanged: (v) => setState(() => _speed = v),
              ),
            ),
            SizedBox(width: 44, child: Text('${_speed.toStringAsFixed(2)}x')),
          ],
        ),
        const SizedBox(height: 12),
        Text('Format', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final f in ExportFormat.values)
              ChoiceChip(
                label: Text(f.label),
                selected: _format == f,
                onSelected: (_) => setState(() => _format = f),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).extension<AppSurfaceColors>()!.surfaceElevated,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Row(
            children: [
              Expanded(
                child: _EstimateStat(label: 'Chapters', value: '${chapterIndices.length}'),
              ),
              Expanded(
                child: _EstimateStat(label: 'Audio length', value: _formatDuration(estimate.audioDuration)),
              ),
              Expanded(
                child: _EstimateStat(label: 'Est. size', value: _formatBytes(estimate.estimatedBytes)),
              ),
              Expanded(
                child: _EstimateStat(label: 'Est. time', value: _formatDuration(estimate.estimatedGenerationTime)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            icon: _starting
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.ios_share),
            label: Text(_starting ? 'Starting…' : 'Start Export'),
            onPressed: chapterIndices.isEmpty || _voiceProfileId == null || _starting
                ? null
                : () => _startExport(bookId, book, chapters, chapterIndices),
          ),
        ),
      ],
    );
  }

  Widget _buildChapterChecklist(List<ParsedChapter> chapters) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).extension<AppSurfaceColors>()!.border),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: chapters.length,
        itemBuilder: (context, i) {
          return CheckboxListTile(
            dense: true,
            title: Text(chapters[i].title, maxLines: 1, overflow: TextOverflow.ellipsis),
            value: _selectedChapters.contains(i),
            onChanged: (checked) => setState(() {
              if (checked == true) {
                _selectedChapters.add(i);
              } else {
                _selectedChapters.remove(i);
              }
            }),
          );
        },
      ),
    );
  }

  Widget _buildRangePickers(List<ParsedChapter> chapters) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            value: _rangeStart.clamp(0, chapters.length - 1),
            decoration: const InputDecoration(labelText: 'From chapter'),
            items: [
              for (var i = 0; i < chapters.length; i++)
                DropdownMenuItem(value: i, child: Text('${i + 1}. ${chapters[i].title}', overflow: TextOverflow.ellipsis)),
            ],
            onChanged: (v) => setState(() {
              _rangeStart = v ?? 0;
              if (_rangeEnd < _rangeStart) _rangeEnd = _rangeStart;
            }),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<int>(
            value: _rangeEnd.clamp(0, chapters.length - 1),
            decoration: const InputDecoration(labelText: 'To chapter'),
            items: [
              for (var i = 0; i < chapters.length; i++)
                DropdownMenuItem(value: i, child: Text('${i + 1}. ${chapters[i].title}', overflow: TextOverflow.ellipsis)),
            ],
            onChanged: (v) => setState(() {
              _rangeEnd = v ?? 0;
              if (_rangeStart > _rangeEnd) _rangeStart = _rangeEnd;
            }),
          ),
        ),
      ],
    );
  }

  List<int> _resolveScope(int chapterCount) {
    switch (_scopeType) {
      case ExportScopeType.currentChapter:
        return [0];
      case ExportScopeType.selectedChapters:
        return _selectedChapters.toList()..sort();
      case ExportScopeType.entireBook:
        return List.generate(chapterCount, (i) => i);
      case ExportScopeType.customRange:
        return [for (var i = _rangeStart; i <= _rangeEnd; i++) i];
    }
  }

  Future<void> _startExport(
    String bookId,
    BookRow book,
    List<ParsedChapter> chapters,
    List<int> chapterIndices,
  ) async {
    setState(() => _starting = true);
    try {
      final voice = (await ref.read(voiceRepositoryProvider).getAll())
          .firstWhere((v) => v.id == _voiceProfileId);
      final paths = await BookPaths.forBook(bookId);
      final exportsDir = await paths.ensureExportsDir();

      final jobId = _uuid.v4();
      final job = ExportJobsCompanion.insert(
        id: jobId,
        bookId: bookId,
        voiceProfileId: voice.id,
        scopeType: _scopeType.storageKey,
        scopeJson: chapterIndices.toString(),
        speed: drift.Value(_speed),
        format: _format.name,
        createdAt: DateTime.now(),
      );
      await ref.read(exportRepositoryProvider).upsert(job);

      final savedJob = (await ref.read(exportRepositoryProvider).watchAll().first)
          .firstWhere((j) => j.id == jobId);

      unawaited(ref.read(exportServiceProvider).run(
            job: savedJob,
            chapters: chapters,
            chapterIndices: chapterIndices,
            voice: voice,
            bookTitle: book.title,
            outputDir: exportsDir.path,
          ));

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Export started.')));
      }
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }
}

class _EstimateStat extends StatelessWidget {
  final String label;
  final String value;
  const _EstimateStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _ExportJobTile extends ConsumerWidget {
  final ExportJobRow job;
  final String bookTitle;
  const _ExportJobTile({required this.job, required this.bookTitle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surfaces = Theme.of(context).extension<AppSurfaceColors>()!;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaces.surface,
        border: Border.all(color: surfaces.border),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_statusIcon(job.status), size: 18, color: _statusColor(job.status)),
              const SizedBox(width: 8),
              Expanded(
                child: Text('${job.format.toUpperCase()} · ${job.scopeType}',
                    style: Theme.of(context).textTheme.titleSmall),
              ),
              if (job.status == ExportStatus.completed) ...[
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  tooltip: 'Share',
                  onPressed: () => Share.shareXFiles([XFile(job.outputPath!)], text: bookTitle),
                ),
                IconButton(
                  icon: const Icon(Icons.folder_open_outlined),
                  tooltip: 'Show in folder',
                  onPressed: () => _openContainingFolder(job.outputPath!),
                ),
              ],
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Remove',
                onPressed: () => ref.read(exportRepositoryProvider).delete(job.id),
              ),
            ],
          ),
          if (job.status == ExportStatus.running) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(value: job.progress, minHeight: 4),
            ),
          ],
          if (job.status == ExportStatus.completed && job.estimatedBytes != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(_formatBytes(job.estimatedBytes!), style: TextStyle(color: surfaces.textSecondary, fontSize: 12)),
            ),
          if (job.status == ExportStatus.failed && job.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(job.errorMessage!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  IconData _statusIcon(String status) => switch (status) {
        ExportStatus.completed => Icons.check_circle,
        ExportStatus.failed => Icons.error,
        ExportStatus.running => Icons.autorenew,
        _ => Icons.schedule,
      };

  Color _statusColor(String status) => switch (status) {
        ExportStatus.completed => AppColors.success,
        ExportStatus.failed => AppColors.error,
        ExportStatus.running => AppColors.accent,
        _ => Colors.grey,
      };

  void _openContainingFolder(String path) {
    if (Platform.isWindows) {
      Process.run('explorer.exe', ['/select,', path]);
    }
  }
}

class _EmptyExport extends StatelessWidget {
  const _EmptyExport();

  @override
  Widget build(BuildContext context) {
    final surfaces = Theme.of(context).extension<AppSurfaceColors>()!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.ios_share_outlined, size: 64, color: surfaces.textSecondary),
            const SizedBox(height: 16),
            Text('No books to export', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Import a book from the Library first.',
                style: TextStyle(color: surfaces.textSecondary)),
          ],
        ),
      ),
    );
  }
}

String _formatDuration(Duration d) {
  if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
  if (d.inMinutes > 0) return '${d.inMinutes}m ${d.inSeconds % 60}s';
  return '${d.inSeconds}s';
}

String _formatBytes(int bytes) {
  if (bytes >= 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  if (bytes >= 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  return '$bytes B';
}
