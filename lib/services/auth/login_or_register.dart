// login_or_register.dart
import 'package:flutter/material.dart';
import 'package:BhashaBridge/pages/login_page.dart';
import 'package:BhashaBridge/pages/register_page.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister>
    with SingleTickerProviderStateMixin {
  bool showLoginPage = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void togglePages() {
    setState(() {
      _animationController.reset();
      showLoginPage = !showLoginPage;
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: showLoginPage
          ? LoginPage(onTap: togglePages)
          : RegisterPage(onTap: togglePages),
    );
  }
}