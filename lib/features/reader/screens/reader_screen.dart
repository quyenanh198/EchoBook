import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/progress_math.dart';
import '../../../data/db/app_database.dart';
import '../../../services/parsing/parsed_book.dart';
import '../../tts_player/providers/player_providers.dart';
import '../providers/reader_data.dart';
import '../providers/reading_settings.dart';
import '../utils/paginator.dart';
import '../widgets/bookmarks_sheet.dart';
import '../widgets/reader_settings_sheet.dart';
import '../widgets/toc_sheet.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  final String bookId;
  const ReaderScreen({super.key, required this.bookId});

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  static const _uuid = Uuid();

  int _chapterIndex = 0;
  int _charOffset = 0;
  bool _positionInitialized = false;

  final ScrollController _scrollController = ScrollController();
  double _scrollFraction = 0;

  List<int> _pageBreaks = const [0, 0];
  int _currentPage = 0;

  Timer? _saveTimer;
  BookLengthIndex? _lengthIndex;
  List<ParsedChapter> _chapters = const [];
  BookRow? _book;

  @override
  void initState() {
    super.initState();
    _saveTimer = Timer.periodic(const Duration(seconds: 4), (_) => _saveProgress());
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _saveProgress();
    _scrollController.dispose();
    super.dispose();
  }

  void _applyInit(ReaderInitData data) {
    _chapters = data.chapters;
    _book = data.book;
    _lengthIndex = BookLengthIndex.fromChapters(data.chapters);
    if (!_positionInitialized) {
      _positionInitialized = true;
      final progress = data.progress;
      _chapterIndex = (progress?.chapterIndex ?? 0).clamp(0, math.max(0, data.chapters.length - 1));
      _charOffset = progress?.characterOffset ?? 0;
      _scrollFraction = progress?.chapterFraction ?? 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scrollController.hasClients) return;
        final target = _scrollController.position.maxScrollExtent * _scrollFraction;
        _scrollController.jumpTo(target.clamp(0, _scrollController.position.maxScrollExtent));
      });
    }
  }

  void _saveProgress() {
    if (!_positionInitialized || _lengthIndex == null || _chapters.isEmpty) return;
    final settings = ref.read(readingSettingsProvider);
    final chapterFraction = settings.layoutMode == ReaderLayoutMode.paginated
        ? (_pageBreaks.length > 2 ? _currentPage / (_pageBreaks.length - 2).clamp(1, 1 << 30) : 0.0)
        : _scrollFraction;
    final overall = _lengthIndex!.overallFraction(_chapterIndex, chapterFraction.toDouble());
    ref.read(progressRepositoryProvider).save(
          bookId: widget.bookId,
          chapterIndex: _chapterIndex,
          chapterFraction: chapterFraction.toDouble(),
          overallFraction: overall,
          characterOffset: _charOffset,
        );
  }

  void _goToChapter(int index) {
    setState(() {
      _chapterIndex = index;
      _charOffset = 0;
      _scrollFraction = 0;
      _currentPage = 0;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
    });
    _saveProgress();
  }

  Future<void> _addBookmark() async {
    final chapter = _chapters[_chapterIndex];
    final start = _charOffset.clamp(0, chapter.plainText.length);
    final end = (start + 120).clamp(0, chapter.plainText.length);
    final bookmark = BookmarkRow(
      id: _uuid.v4(),
      bookId: widget.bookId,
      chapterIndex: _chapterIndex,
      characterOffset: start,
      excerpt: chapter.plainText.substring(start, end).trim(),
      label: null,
      createdAt: DateTime.now(),
    );
    await ref.read(bookmarkRepositoryProvider).add(bookmark);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bookmark added')));
    }
  }

  void _startListening() {
    if (_chapters.isEmpty || _book == null) return;
    ref.read(playerControllerProvider.notifier).playFrom(
          bookId: widget.bookId,
          bookTitle: _book!.title,
          chapters: _chapters,
          chapterIndex: _chapterIndex,
          charOffset: _charOffset,
        );
  }

  @override
  Widget build(BuildContext context) {
    final initAsync = ref.watch(readerInitProvider(widget.bookId));
    final settings = ref.watch(readingSettingsProvider);

    return initAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Could not open book: $e')),
      ),
      data: (data) {
        _applyInit(data);
        if (_chapters.isEmpty) {
          return const Scaffold(body: Center(child: Text('This book has no readable content.')));
        }
        return _buildReader(context, settings);
      },
    );
  }

  Widget _buildReader(BuildContext context, ReadingSettings settings) {
    final chapter = _chapters[_chapterIndex];
    final colors = _readingColors(settings.theme);
    final playerState = ref.watch(playerControllerProvider);
    final isListeningThisChapter =
        playerState.isActive && playerState.bookId == widget.bookId && playerState.chapterIndex == _chapterIndex;

    final overallFraction = _lengthIndex?.overallFraction(
          _chapterIndex,
          settings.layoutMode == ReaderLayoutMode.paginated
              ? (_pageBreaks.length > 2 ? _currentPage / (_pageBreaks.length - 2).clamp(1, 1 << 30) : 0.0)
              : _scrollFraction,
        ) ??
        0;
    final minutesLeft = _lengthIndex?.estimatedMinutesLeft(_chapters, _chapterIndex,
            settings.layoutMode == ReaderLayoutMode.paginated ? 0 : _scrollFraction) ??
        0;

    return Scaffold(
      appBar: AppBar(
        title: Text(_book?.title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.headphones_outlined),
            tooltip: 'Listen',
            onPressed: _startListening,
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined),
            tooltip: 'Add bookmark',
            onPressed: _addBookmark,
          ),
          IconButton(
            icon: const Icon(Icons.bookmarks_outlined),
            tooltip: 'Bookmarks',
            onPressed: () async {
              final bookmark = await showBookmarksSheet(context, ref, widget.bookId);
              if (bookmark != null) {
                setState(() {
                  _chapterIndex = bookmark.chapterIndex;
                  _charOffset = bookmark.characterOffset;
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.toc),
            tooltip: 'Table of Contents',
            onPressed: () async {
              final index = await showTocSheet(context, chapters: _chapters, currentIndex: _chapterIndex);
              if (index != null) _goToChapter(index);
            },
          ),
          IconButton(
            icon: const Icon(Icons.text_fields),
            tooltip: 'Appearance',
            onPressed: () => showReaderSettingsSheet(context),
          ),
        ],
      ),
      body: Container(
        color: colors.background,
        child: Column(
          children: [
            _ProgressHeader(
              chapterTitle: chapter.title,
              chapterNumber: _chapterIndex + 1,
              chapterCount: _chapters.length,
              overallFraction: overallFraction,
              minutesLeft: minutesLeft,
              textColor: colors.text,
            ),
            Expanded(
              child: settings.layoutMode == ReaderLayoutMode.scroll
                  ? _ScrollBody(
                      key: ValueKey('scroll-$_chapterIndex'),
                      text: chapter.plainText,
                      settings: settings,
                      colors: colors,
                      scrollController: _scrollController,
                      initialFraction: _scrollFraction,
                      highlightRange: isListeningThisChapter
                          ? (
                              playerState.sentenceIndex < 0
                                  ? null
                                  : _highlightRangeFor(playerState)
                            )
                          : null,
                      onFractionChanged: (fraction, approxOffset) {
                        _scrollFraction = fraction;
                        _charOffset = approxOffset;
                      },
                    )
                  : _PaginatedBody(
                      key: ValueKey('page-$_chapterIndex-${settings.fontSize}-${settings.lineHeight}-${settings.margin}'),
                      text: chapter.plainText,
                      settings: settings,
                      colors: colors,
                      initialCharOffset: _charOffset,
                      highlightRange: isListeningThisChapter ? _highlightRangeFor(playerState) : null,
                      onBreaksComputed: (breaks, key) {
                        _pageBreaks = breaks;
                      },
                      onPageChanged: (page, offset) {
                        _currentPage = page;
                        _charOffset = offset;
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  (int, int)? _highlightRangeFor(PlayerState playerState) {
    final sentences = ref.read(playerControllerProvider.notifier).currentSentences;
    if (playerState.sentenceIndex < 0 || playerState.sentenceIndex >= sentences.length) return null;
    final s = sentences[playerState.sentenceIndex];
    return (s.start, s.end);
  }

  _ReadingColors _readingColors(ReadingTheme theme) {
    switch (theme) {
      case ReadingTheme.dark:
        return const _ReadingColors(background: Color(0xFF0F1416), text: Color(0xFFF3F6F6));
      case ReadingTheme.sepia:
        return const _ReadingColors(background: AppColors.sepiaBackground, text: AppColors.sepiaText);
      case ReadingTheme.light:
        return const _ReadingColors(background: Colors.white, text: Colors.black87);
    }
  }
}

class _ReadingColors {
  final Color background;
  final Color text;
  const _ReadingColors({required this.background, required this.text});
}

class _ProgressHeader extends StatelessWidget {
  final String chapterTitle;
  final int chapterNumber;
  final int chapterCount;
  final double overallFraction;
  final int minutesLeft;
  final Color textColor;

  const _ProgressHeader({
    required this.chapterTitle,
    required this.chapterNumber,
    required this.chapterCount,
    required this.overallFraction,
    required this.minutesLeft,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Ch. $chapterNumber/$chapterCount · $chapterTitle',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: textColor.withValues(alpha: 0.75), fontSize: 12),
                ),
              ),
              Text('$minutesLeft min left', style: TextStyle(color: textColor.withValues(alpha: 0.75), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: overallFraction,
              minHeight: 3,
              backgroundColor: textColor.withValues(alpha: 0.12),
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

List<TextSpan> _buildSpans(
  String text,
  TextStyle style,
  (int, int)? highlight,
  Color highlightColor,
) {
  if (highlight == null) return [TextSpan(text: text, style: style)];
  final start = highlight.$1.clamp(0, text.length);
  final end = highlight.$2.clamp(0, text.length);
  if (start >= end) return [TextSpan(text: text, style: style)];
  return [
    TextSpan(text: text.substring(0, start), style: style),
    TextSpan(
      text: text.substring(start, end),
      style: style.copyWith(backgroundColor: highlightColor, color: style.color),
    ),
    TextSpan(text: text.substring(end), style: style),
  ];
}

class _ScrollBody extends StatefulWidget {
  final String text;
  final ReadingSettings settings;
  final _ReadingColors colors;
  final ScrollController scrollController;
  final double initialFraction;
  final (int, int)? highlightRange;
  final void Function(double fraction, int approxCharOffset) onFractionChanged;

  const _ScrollBody({
    super.key,
    required this.text,
    required this.settings,
    required this.colors,
    required this.scrollController,
    required this.initialFraction,
    required this.highlightRange,
    required this.onFractionChanged,
  });

  @override
  State<_ScrollBody> createState() => _ScrollBodyState();
}

class _ScrollBodyState extends State<_ScrollBody> {
  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!widget.scrollController.hasClients) return;
    final max = widget.scrollController.position.maxScrollExtent;
    final fraction = max <= 0 ? 0.0 : (widget.scrollController.offset / max).clamp(0.0, 1.0);
    widget.onFractionChanged(fraction, (fraction * widget.text.length).round());
  }

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: widget.colors.text,
      fontSize: widget.settings.fontSize,
      height: widget.settings.lineHeight,
    );
    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: EdgeInsets.all(widget.settings.margin).copyWith(bottom: widget.settings.margin + 40),
      child: SelectableText.rich(
        TextSpan(
          children: _buildSpans(
            widget.text,
            style,
            widget.highlightRange,
            AppColors.accent.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }
}

class _PaginatedBody extends StatefulWidget {
  final String text;
  final ReadingSettings settings;
  final _ReadingColors colors;
  final int initialCharOffset;
  final (int, int)? highlightRange;
  final void Function(List<int> breaks, String key) onBreaksComputed;
  final void Function(int page, int charOffset) onPageChanged;

  const _PaginatedBody({
    super.key,
    required this.text,
    required this.settings,
    required this.colors,
    required this.initialCharOffset,
    required this.highlightRange,
    required this.onBreaksComputed,
    required this.onPageChanged,
  });

  @override
  State<_PaginatedBody> createState() => _PaginatedBodyState();
}

class _PaginatedBodyState extends State<_PaginatedBody> {
  PageController? _pageController;
  List<int> _breaks = const [0];

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: widget.colors.text,
      fontSize: widget.settings.fontSize,
      height: widget.settings.lineHeight,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth - widget.settings.margin * 2;
        final maxHeight = constraints.maxHeight - widget.settings.margin * 2;
        final key = '${maxWidth.round()}x${maxHeight.round()}';

        if (_breaks.length <= 1 || _pageController == null) {
          _breaks = computePageBreaks(
            text: widget.text,
            style: style,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
          );
          var initialPage = 0;
          for (var i = 0; i < _breaks.length - 1; i++) {
            if (widget.initialCharOffset < _breaks[i + 1]) {
              initialPage = i;
              break;
            }
          }
          _pageController = PageController(initialPage: initialPage);
          widget.onBreaksComputed(_breaks, key);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onPageChanged(initialPage, _breaks[initialPage]);
          });
        }

        final pageCount = math.max(1, _breaks.length - 1);

        return PageView.builder(
          controller: _pageController,
          itemCount: pageCount,
          onPageChanged: (page) => widget.onPageChanged(page, _breaks[page]),
          itemBuilder: (context, index) {
            final start = _breaks[index];
            final end = index + 1 < _breaks.length ? _breaks[index + 1] : widget.text.length;
            final pageText = widget.text.substring(start, end);
            (int, int)? localHighlight;
            if (widget.highlightRange != null) {
              final hs = widget.highlightRange!.$1 - start;
              final he = widget.highlightRange!.$2 - start;
              if (he > 0 && hs < pageText.length) {
                localHighlight = (hs.clamp(0, pageText.length), he.clamp(0, pageText.length));
              }
            }
            return Padding(
              padding: EdgeInsets.all(widget.settings.margin),
              child: SelectableText.rich(
                TextSpan(
                  children: _buildSpans(
                    pageText,
                    style,
                    localHighlight,
                    AppColors.accent.withValues(alpha: 0.35),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
