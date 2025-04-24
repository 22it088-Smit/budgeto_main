import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budgeto/app.dart';
import 'package:budgeto/services/theme_service.dart';
import 'package:budgeto/services/auth_service.dart';
import 'package:budgeto/services/budget_service.dart';
import 'package:budgeto/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service
  await NotificationService().init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => BudgetService()),
      ],
      child: const BudgetoApp(),
    ),
  );
}