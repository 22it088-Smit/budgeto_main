import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budgeto/screens/splash_screen.dart';
import 'package:budgeto/services/theme_service.dart';
import 'package:budgeto/theme/app_theme.dart';

class BudgetoApp extends StatelessWidget {
  const BudgetoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          title: 'Budgeto',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeService.themeMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}