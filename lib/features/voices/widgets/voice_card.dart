import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/tables.dart';

class VoiceCard extends ConsumerStatefulWidget {
  final VoiceProfileRow profile;
  final VoidCallback onDelete;

  const VoiceCard({super.key, required this.profile, required this.onDelete});

  @override
  ConsumerState<VoiceCard> createState() => _VoiceCardState();
}

class _VoiceCardState extends ConsumerState<VoiceCard> {
  bool _expanded = false;

  void _updateProfile({double? speed, double? pitch}) {
    ref.read(voiceRepositoryProvider).upsert(VoiceProfilesCompanion(
          id: Value(widget.profile.id),
          speed: speed != null ? Value(speed) : const Value.absent(),
          pitch: pitch != null ? Value(pitch) : const Value.absent(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final surfaces = Theme.of(context).extension<AppSurfaceColors>()!;
    final isCloned = profile.kind == VoiceKind.cloned;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surfaces.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: surfaces.border),
      ),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: isCloned
                  ? AppColors.accent.withValues(alpha: 0.2)
                  : surfaces.surfaceElevated,
              child: Icon(
                isCloned ? Icons.graphic_eq : Icons.record_voice_over,
                color: isCloned ? AppColors.accent : surfaces.textSecondary,
                size: 20,
              ),
            ),
            title: Row(
              children: [
                Flexible(child: Text(profile.name, overflow: TextOverflow.ellipsis)),
                if (isCloned) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('BETA', style: TextStyle(fontSize: 10, color: AppColors.warning)),
                  ),
                ],
                if (profile.isDefault) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.star, size: 16, color: AppColors.accent),
                ],
              ],
            ),
            subtitle: Text(profile.systemVoiceLocale ?? '—'),
            trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () => setState(() => _expanded = !_expanded),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                children: [
                  _SliderRow(
                    label: 'Speed',
                    value: profile.speed,
                    min: 0.5,
                    max: 3.0,
                    onChanged: (v) => _updateProfile(speed: v),
                  ),
                  _SliderRow(
                    label: 'Pitch',
                    value: profile.pitch,
                    min: 0.5,
                    max: 2.0,
                    onChanged: (v) => _updateProfile(pitch: v),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: Icon(profile.isDefault ? Icons.star : Icons.star_border),
                          label: Text(profile.isDefault ? 'Default voice' : 'Set as default'),
                          onPressed: profile.isDefault
                              ? null
                              : () => ref.read(voiceRepositoryProvider).setDefault(profile.id),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                        onPressed: widget.onDelete,
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 56, child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
        SizedBox(width: 40, child: Text(value.toStringAsFixed(2))),
      ],
    );
  }
}
