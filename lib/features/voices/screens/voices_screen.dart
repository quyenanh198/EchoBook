import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/tables.dart';
import '../providers/voices_providers.dart';
import '../widgets/clone_voice_sheet.dart';
import '../widgets/voice_card.dart';

class VoicesScreen extends ConsumerWidget {
  const VoicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(defaultVoiceBootstrapProvider);
    final profilesAsync = ref.watch(voiceProfilesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Voices')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _CloneVoiceCard(onTap: () => showCloneVoiceSheet(context)),
          const SizedBox(height: 20),
          Text('Your Voices', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          profilesAsync.when(
            data: (profiles) {
              if (profiles.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return Column(
                children: [
                  for (final profile in profiles)
                    VoiceCard(
                      key: ValueKey(profile.id),
                      profile: profile,
                      onDelete: () async {
                        if (profiles.length <= 1) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('At least one voice is required.')),
                          );
                          return;
                        }
                        await ref.read(voiceRepositoryProvider).delete(profile.id);
                        if (profile.isDefault) {
                          final remaining = await ref.read(voiceRepositoryProvider).getAll();
                          if (remaining.isNotEmpty) {
                            await ref.read(voiceRepositoryProvider).setDefault(remaining.first.id);
                          }
                        }
                      },
                    ),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text('Error loading voices: $e'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add system voice'),
            onPressed: () => _showAddSystemVoiceSheet(context, ref),
          ),
        ],
      ),
    );
  }

  void _showAddSystemVoiceSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _AddSystemVoiceSheet(),
    );
  }
}

class _CloneVoiceCard extends StatelessWidget {
  final VoidCallback onTap;
  const _CloneVoiceCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.accent.withValues(alpha: 0.22), AppColors.accentDim.withValues(alpha: 0.08)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
              child: const Icon(Icons.mic, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Clone New Voice', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Record or upload 1-2 minutes of speech to create a custom voice (Beta).',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class _AddSystemVoiceSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voicesAsync = ref.watch(systemVoicesProvider);
    final profilesAsync = ref.watch(voiceProfilesProvider);

    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollController) {
          return voicesAsync.when(
            data: (voices) {
              final existingIds =
                  (profilesAsync.valueOrNull ?? []).map((p) => p.systemVoiceId).toSet();
              final available = voices.where((v) => !existingIds.contains(v.name)).toList();
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('System Voices', style: Theme.of(ctx).textTheme.titleLarge),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: available.isEmpty
                        ? const Center(child: Text('All available system voices are already added.'))
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: available.length,
                            itemBuilder: (ctx, i) {
                              final voice = available[i];
                              return ListTile(
                                leading: const Icon(Icons.record_voice_over_outlined),
                                title: Text(voice.name),
                                subtitle: Text(voice.locale),
                                onTap: () async {
                                  await ref.read(voiceRepositoryProvider).upsert(
                                        VoiceProfilesCompanion.insert(
                                          id: const Uuid().v4(),
                                          name: voice.name,
                                          kind: VoiceKind.system,
                                          systemVoiceId: Value(voice.name),
                                          systemVoiceLocale: Value(voice.locale),
                                          createdAt: DateTime.now(),
                                        ),
                                      );
                                  if (ctx.mounted) Navigator.pop(ctx);
                                },
                              );
                            },
                          ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          );
        },
      ),
    );
  }
}
