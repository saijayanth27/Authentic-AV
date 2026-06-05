import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'logic/app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppState.instance.loadFromDatabase();
  runApp(const AuthenticAvApp());
}

class AuthenticAvApp extends StatelessWidget {
  const AuthenticAvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AuthenticAV',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}
