import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../shell/shell_providers.dart';
import '../providers/player_providers.dart';

void showPlayerControlsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => const _PlayerControlsSheet(),
  );
}

const _sleepOptions = <(String, Duration?)>[
  ('Off', null),
  ('5 min', Duration(minutes: 5)),
  ('15 min', Duration(minutes: 15)),
  ('30 min', Duration(minutes: 30)),
  ('60 min', Duration(minutes: 60)),
];

class _PlayerControlsSheet extends ConsumerWidget {
  const _PlayerControlsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerControllerProvider);
    final controller = ref.read(playerControllerProvider.notifier);
    final surfaces = Theme.of(context).extension<AppSurfaceColors>()!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(state.bookTitle, style: Theme.of(context).textTheme.titleLarge),
            Text(state.chapterTitle,
                style: TextStyle(color: surfaces.textSecondary)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surfaces.surfaceElevated,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Text(
                state.currentSentenceText,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  iconSize: 32,
                  icon: const Icon(Icons.skip_previous),
                  onPressed: () => controller.skipSentence(-1),
                ),
                IconButton.filled(
                  iconSize: 36,
                  icon: Icon(state.isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: controller.togglePlayPause,
                ),
                IconButton(
                  iconSize: 32,
                  icon: const Icon(Icons.skip_next),
                  onPressed: () => controller.skipSentence(1),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(width: 70, child: Text('Speed', style: Theme.of(context).textTheme.bodyMedium)),
                Expanded(
                  child: Slider(
                    value: state.speed,
                    min: 0.5,
                    max: 3.0,
                    divisions: 25,
                    label: '${state.speed.toStringAsFixed(2)}x',
                    onChanged: controller.setSpeed,
                  ),
                ),
                SizedBox(width: 44, child: Text('${state.speed.toStringAsFixed(2)}x')),
              ],
            ),
            Row(
              children: [
                SizedBox(width: 70, child: Text('Pitch', style: Theme.of(context).textTheme.bodyMedium)),
                Expanded(
                  child: Slider(
                    value: state.pitch,
                    min: 0.5,
                    max: 2.0,
                    divisions: 15,
                    label: state.pitch.toStringAsFixed(2),
                    onChanged: controller.setPitch,
                  ),
                ),
                SizedBox(width: 44, child: Text(state.pitch.toStringAsFixed(2))),
              ],
            ),
            const SizedBox(height: 12),
            Text('Sleep timer', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final option in _sleepOptions)
                  ChoiceChip(
                    label: Text(option.$1),
                    selected: state.sleepTimerRemaining == null
                        ? option.$2 == null
                        : option.$1 != 'Off' &&
                            state.sleepTimerRemaining!.inMinutes == (option.$2?.inMinutes ?? -1),
                    onSelected: (_) => controller.setSleepTimer(option.$2),
                  ),
              ],
            ),
            if (state.sleepTimerRemaining != null) ...[
              const SizedBox(height: 8),
              Text(
                'Stopping in ${state.sleepTimerRemaining!.inMinutes}:${(state.sleepTimerRemaining!.inSeconds % 60).toString().padLeft(2, '0')}',
                style: TextStyle(color: surfaces.textSecondary),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.record_voice_over_outlined),
                    label: const Text('Change voice'),
                    onPressed: () {
                      Navigator.pop(context);
                      ref.read(currentTabProvider.notifier).state = 2;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
