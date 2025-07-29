// auth_gate.dart (Enhanced version)
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:BhashaBridge/services/auth/login_or_register.dart';
import 'package:BhashaBridge/pages/home_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Show loading indicator while checking auth state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // User is logged in
          if (snapshot.hasData) {
            return HomePage();
          }

          // User is NOT logged in
          return const LoginOrRegister();
        },
      ),
    );
  }
}



