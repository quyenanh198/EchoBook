import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:echobook/core/providers/core_providers.dart';
import 'package:echobook/core/theme/app_theme.dart';
import 'package:echobook/data/db/app_database.dart';
import 'package:echobook/data/db/tables.dart';
import 'package:echobook/features/voices/widgets/voice_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows name and BETA badge for a cloned voice, expands to reveal sliders', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.into(db.voiceProfiles).insertOnConflictUpdate(VoiceProfilesCompanion.insert(
          id: 'v1',
          name: 'Another Voice',
          kind: VoiceKind.system,
          isDefault: const Value(true),
          createdAt: DateTime(2026, 1, 1),
        ));

    final profile = VoiceProfileRow(
      id: 'v2',
      name: 'My Cloned Voice',
      kind: VoiceKind.cloned,
      systemVoiceId: 'Microsoft David',
      systemVoiceLocale: 'en-US',
      sampleAudioPath: '/tmp/sample.wav',
      pitchShift: 1.1,
      speed: 1.0,
      pitch: 1.1,
      isDefault: false,
      createdAt: DateTime(2026, 1, 1),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: VoiceCard(profile: profile, onDelete: () {}),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Cloned Voice'), findsOneWidget);
    expect(find.text('BETA'), findsOneWidget);
    expect(find.text('Speed'), findsNothing); // collapsed by default

    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle();

    expect(find.text('Speed'), findsOneWidget);
    expect(find.text('Pitch'), findsOneWidget);
    expect(find.text('Set as default'), findsOneWidget);
  });

  testWidgets('tapping "Set as default" persists the change', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final profile = VoiceProfileRow(
      id: 'v3',
      name: 'System Voice',
      kind: VoiceKind.system,
      systemVoiceId: 'David',
      systemVoiceLocale: 'en-US',
      sampleAudioPath: null,
      pitchShift: 0,
      speed: 1.0,
      pitch: 1.0,
      isDefault: false,
      createdAt: DateTime(2026, 1, 1),
    );
    await db.into(db.voiceProfiles).insertOnConflictUpdate(profile.toCompanion(true));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(body: VoiceCard(profile: profile, onDelete: () {})),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Set as default'));
    await tester.pumpAndSettle();

    final stored = await db.select(db.voiceProfiles).getSingle();
    expect(stored.isDefault, isTrue);
  });
}
