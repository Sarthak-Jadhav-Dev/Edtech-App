import 'package:flutter/material.dart';
import 'package:kte/services/app_state.dart';
import 'package:kte/views/pages/login.dart';
import 'package:kte/views/widget_tree.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kte/services/theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.purple,
              brightness: Brightness.light,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
              surface: const Color(0xFF1E1E2E),
              surfaceContainerHighest: const Color(0xFF2D2D44),
            ),
            cardTheme: CardThemeData(
              color: const Color(0xFF2D2D44),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            scaffoldBackgroundColor: const Color(0xFF12121A),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E2E),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
          home: FutureBuilder(
            future: AppState.isFirstTime(), 
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              bool isFirstTime = snapshot.data as bool; //true or false
              final user = FirebaseAuth.instance.currentUser; // we will check for active seesion

              if (isFirstTime) {
                return  Login();
              } else if (user == null) {
                return  Login();
              } else {
                return const WidgetTree();
              }
            },
          ),
        );
      }
    );
  }
}
