import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/reading_settings.dart';

void showReaderSettingsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => const _ReaderSettingsSheet(),
  );
}

class _ReaderSettingsSheet extends ConsumerWidget {
  const _ReaderSettingsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(readingSettingsProvider);
    final controller = ref.read(readingSettingsProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            Text('Theme', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 10),
            Row(
              children: [
                _ThemeSwatch(
                  label: 'Dark',
                  color: const Color(0xFF161D20),
                  textColor: Colors.white,
                  selected: settings.theme == ReadingTheme.dark,
                  onTap: () => controller.setTheme(ReadingTheme.dark),
                ),
                const SizedBox(width: 12),
                _ThemeSwatch(
                  label: 'Sepia',
                  color: AppColors.sepiaBackground,
                  textColor: AppColors.sepiaText,
                  selected: settings.theme == ReadingTheme.sepia,
                  onTap: () => controller.setTheme(ReadingTheme.sepia),
                ),
                const SizedBox(width: 12),
                _ThemeSwatch(
                  label: 'Light',
                  color: Colors.white,
                  textColor: Colors.black,
                  selected: settings.theme == ReadingTheme.light,
                  onTap: () => controller.setTheme(ReadingTheme.light),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Layout', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 10),
            SegmentedButton<ReaderLayoutMode>(
              segments: const [
                ButtonSegment(
                    value: ReaderLayoutMode.scroll,
                    icon: Icon(Icons.swap_vert),
                    label: Text('Scroll')),
                ButtonSegment(
                    value: ReaderLayoutMode.paginated,
                    icon: Icon(Icons.auto_stories_outlined),
                    label: Text('Pages')),
              ],
              selected: {settings.layoutMode},
              onSelectionChanged: (v) => controller.setLayoutMode(v.first),
            ),
            const SizedBox(height: 20),
            _SliderRow(
              label: 'Font size',
              value: settings.fontSize,
              min: 12,
              max: 32,
              display: settings.fontSize.round().toString(),
              onChanged: controller.setFontSize,
            ),
            _SliderRow(
              label: 'Line height',
              value: settings.lineHeight,
              min: 1.2,
              max: 2.2,
              display: settings.lineHeight.toStringAsFixed(1),
              onChanged: controller.setLineHeight,
            ),
            _SliderRow(
              label: 'Margins',
              value: settings.margin,
              min: 8,
              max: 48,
              display: settings.margin.round().toString(),
              onChanged: controller.setMargin,
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeSwatch({
    required this.label,
    required this.color,
    required this.textColor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(
              color: selected ? AppColors.accent : Colors.black26,
              width: selected ? 2 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final String display;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.display,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 90, child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
        Expanded(
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
        SizedBox(width: 32, child: Text(display, textAlign: TextAlign.end)),
      ],
    );
  }
}
