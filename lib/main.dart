import 'package:bwoken/auth/auth_gate.dart';
import 'package:bwoken/firebase_options.dart';
import 'package:bwoken/pages/profile_page.dart';
import 'package:bwoken/screens/soil_health_screen';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/profile_page_screen': (_) => ProfileScreen(),
        '/soil_health_screen': (_) => SoilHealthScreen(),
      },
      home: const AuthGate(),
    );
  }
}
