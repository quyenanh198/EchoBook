import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/player_providers.dart';
import 'player_controls_sheet.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerControllerProvider);
    if (!state.isActive) return const SizedBox.shrink();

    final surfaces = Theme.of(context).extension<AppSurfaceColors>()!;

    return SafeArea(
      top: false,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => showPlayerControlsSheet(context),
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: surfaces.surfaceElevated,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: surfaces.border),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 4)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: state.overallFraction,
                    minHeight: 3,
                    backgroundColor: surfaces.border,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.graphic_eq, color: AppColors.accent, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            state.bookTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            state.chapterTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.replay_10),
                      tooltip: 'Previous sentence',
                      onPressed: () => ref.read(playerControllerProvider.notifier).skipSentence(-1),
                    ),
                    IconButton.filled(
                      icon: Icon(state.isPlaying ? Icons.pause : Icons.play_arrow),
                      onPressed: () => ref.read(playerControllerProvider.notifier).togglePlayPause(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.forward_10),
                      tooltip: 'Next sentence',
                      onPressed: () => ref.read(playerControllerProvider.notifier).skipSentence(1),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Stop',
                      onPressed: () => ref.read(playerControllerProvider.notifier).stop(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
