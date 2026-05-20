import 'package:flutter/material.dart';
import 'package:last_word/core/services/dictionary_service.dart';
import 'router/app_router.dart';
import '../core/theme/app_theme.dart';

class LastWordApp extends StatelessWidget {
  const LastWordApp({super.key, required this.dictionary});

  final IDictionaryService dictionary;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Last Word',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}
