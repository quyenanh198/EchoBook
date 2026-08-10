import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/utils/app_messenger.dart';
import 'features/shell/app_shell.dart';

class EchoBookApp extends StatelessWidget {
  const EchoBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EchoBook',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      scaffoldMessengerKey: AppMessenger.key,
      home: const AppShell(),
    );
  }
}
