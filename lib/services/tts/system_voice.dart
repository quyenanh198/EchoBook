/// A voice exposed by the platform's native TTS engine (SAPI5/OneCore on
/// Windows, AVSpeechSynthesizer on iOS, TextToSpeech on Android).
class SystemVoice {
  final String name;
  final String locale;

  const SystemVoice({required this.name, required this.locale});

  Map<String, String> toFlutterTtsVoice() => {'name': name, 'locale': locale};

  @override
  String toString() => '$name ($locale)';

  @override
  bool operator ==(Object other) =>
      other is SystemVoice && other.name == name && other.locale == locale;

  @override
  int get hashCode => Object.hash(name, locale);
}
