import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_theme.dart';

enum ReaderLayoutMode { scroll, paginated }

class ReadingSettings {
  final double fontSize;
  final double lineHeight;
  final double margin;
  final ReadingTheme theme;
  final ReaderLayoutMode layoutMode;

  const ReadingSettings({
    this.fontSize = 18,
    this.lineHeight = 1.6,
    this.margin = 20,
    this.theme = ReadingTheme.dark,
    this.layoutMode = ReaderLayoutMode.scroll,
  });

  ReadingSettings copyWith({
    double? fontSize,
    double? lineHeight,
    double? margin,
    ReadingTheme? theme,
    ReaderLayoutMode? layoutMode,
  }) {
    return ReadingSettings(
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      margin: margin ?? this.margin,
      theme: theme ?? this.theme,
      layoutMode: layoutMode ?? this.layoutMode,
    );
  }
}

class ReadingSettingsController extends StateNotifier<ReadingSettings> {
  static const _kFontSize = 'reader_font_size';
  static const _kLineHeight = 'reader_line_height';
  static const _kMargin = 'reader_margin';
  static const _kTheme = 'reader_theme';
  static const _kLayoutMode = 'reader_layout_mode';

  ReadingSettingsController() : super(const ReadingSettings()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = ReadingSettings(
      fontSize: prefs.getDouble(_kFontSize) ?? 18,
      lineHeight: prefs.getDouble(_kLineHeight) ?? 1.6,
      margin: prefs.getDouble(_kMargin) ?? 20,
      theme: ReadingTheme.values[prefs.getInt(_kTheme) ?? ReadingTheme.dark.index],
      layoutMode: ReaderLayoutMode
          .values[prefs.getInt(_kLayoutMode) ?? ReaderLayoutMode.scroll.index],
    );
  }

  Future<void> setFontSize(double value) async {
    state = state.copyWith(fontSize: value);
    (await SharedPreferences.getInstance()).setDouble(_kFontSize, value);
  }

  Future<void> setLineHeight(double value) async {
    state = state.copyWith(lineHeight: value);
    (await SharedPreferences.getInstance()).setDouble(_kLineHeight, value);
  }

  Future<void> setMargin(double value) async {
    state = state.copyWith(margin: value);
    (await SharedPreferences.getInstance()).setDouble(_kMargin, value);
  }

  Future<void> setTheme(ReadingTheme value) async {
    state = state.copyWith(theme: value);
    (await SharedPreferences.getInstance()).setInt(_kTheme, value.index);
  }

  Future<void> setLayoutMode(ReaderLayoutMode value) async {
    state = state.copyWith(layoutMode: value);
    (await SharedPreferences.getInstance()).setInt(_kLayoutMode, value.index);
  }
}

final readingSettingsProvider =
    StateNotifierProvider<ReadingSettingsController, ReadingSettings>((ref) {
  return ReadingSettingsController();
});
