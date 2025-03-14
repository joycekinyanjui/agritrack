import 'package:bwoken/auth/login_or_register.dart';
import 'package:bwoken/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            //user is logged in
            if (snapshot.hasData) {
              return const HomeScreen();
            }
            //user not logged in
            else {
              return const LoginOrRegister();
            }
          }),
    );
  }
}
