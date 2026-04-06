import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kte/services/app_state.dart';
import 'package:kte/views/auth_pages/signup.dart';
import 'package:kte/views/pages/login.dart';
import 'package:kte/views/widget_tree.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purpleAccent,
          brightness: Brightness.light,
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
}
