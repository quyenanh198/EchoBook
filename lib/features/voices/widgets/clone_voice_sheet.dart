import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/voice_paths.dart';
import '../../../services/tts/system_voice.dart';
import '../providers/voices_providers.dart';

void showCloneVoiceSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    builder: (ctx) => const _CloneVoiceSheet(),
  );
}

class _CloneVoiceSheet extends ConsumerStatefulWidget {
  const _CloneVoiceSheet();

  @override
  ConsumerState<_CloneVoiceSheet> createState() => _CloneVoiceSheetState();
}

class _CloneVoiceSheetState extends ConsumerState<_CloneVoiceSheet> {
  final _nameController = TextEditingController();
  final _recorder = AudioRecorder();
  static const _uuid = Uuid();

  SystemVoice? _baseVoice;
  String? _samplePath;
  bool _isRecording = false;
  bool _isSaving = false;
  Duration _elapsed = Duration.zero;
  Timer? _ticker;
  String? _error;

  @override
  void dispose() {
    _ticker?.cancel();
    _recorder.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      _ticker?.cancel();
      setState(() {
        _isRecording = false;
        _samplePath = path;
      });
      return;
    }

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      setState(() => _error = 'Microphone permission was denied.');
      return;
    }

    final path = await VoicePaths.newSamplePath(_uuid.v4());
    await _recorder.start(const RecordConfig(encoder: AudioEncoder.wav), path: path);
    setState(() {
      _isRecording = true;
      _samplePath = null;
      _elapsed = Duration.zero;
      _error = null;
    });
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  Future<void> _uploadSample() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['wav', 'mp3', 'm4a', 'aac'],
    );
    final path = result?.files.single.path;
    if (path == null) return;
    setState(() {
      _samplePath = path;
      _error = null;
    });
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _error = 'Give this voice a name.');
      return;
    }
    if (_samplePath == null || !File(_samplePath!).existsSync()) {
      setState(() => _error = 'Record or upload a sample first.');
      return;
    }
    if (_baseVoice == null) {
      setState(() => _error = 'Choose a base system voice to narrate with.');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      await ref.read(voiceCloneServiceProvider).createClonedProfile(
            name: _nameController.text.trim(),
            sampleAudioPath: _samplePath!,
            baseVoice: _baseVoice!,
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _error = 'Could not save voice: $e';
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final voicesAsync = ref.watch(systemVoicesProvider);
    final surfaces = Theme.of(context).extension<AppSurfaceColors>()!;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Clone New Voice', style: Theme.of(context).textTheme.titleLarge),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(top: 4, bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'BETA — approximates your voice by adjusting pitch on a system voice, fully offline.',
                  style: TextStyle(fontSize: 11, color: AppColors.warning),
                ),
              ),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'Voice name (e.g. "My voice")'),
              ),
              const SizedBox(height: 16),
              Text('Base system voice', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              voicesAsync.when(
                data: (voices) {
                  _baseVoice ??= voices.isNotEmpty ? voices.first : null;
                  return DropdownButtonFormField<SystemVoice>(
                    value: _baseVoice,
                    isExpanded: true,
                    items: [
                      for (final v in voices)
                        DropdownMenuItem(value: v, child: Text(v.toString(), overflow: TextOverflow.ellipsis)),
                    ],
                    onChanged: (v) => setState(() => _baseVoice = v),
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('No system voices found: $e'),
              ),
              const SizedBox(height: 20),
              Text('Voice sample (1-2 minutes of clear speech works best)',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _toggleRecording,
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isRecording ? AppColors.error : AppColors.accent,
                        ),
                        child: Icon(_isRecording ? Icons.stop : Icons.mic, size: 32, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isRecording
                          ? '${_elapsed.inMinutes.toString().padLeft(2, '0')}:${(_elapsed.inSeconds % 60).toString().padLeft(2, '0')} — tap to stop'
                          : (_samplePath != null ? 'Sample captured' : 'Tap to record'),
                      style: TextStyle(color: surfaces.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.upload_file_outlined),
                      label: const Text('Or upload an audio file'),
                      onPressed: _isRecording ? null : _uploadSample,
                    ),
                  ],
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: AppColors.error)),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving || _isRecording ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Save Voice'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
