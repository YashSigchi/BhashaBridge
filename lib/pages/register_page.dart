// register_page.dart
import 'package:flutter/material.dart';
import 'package:BhashaBridge/services/auth/auth_service.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({
    super.key,
    required this.onTap,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmPwController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late AnimationController _animationController;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _slideAnimations = List.generate(
      7,
      (index) => Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          index * 0.1,
          1.0,
          curve: Curves.easeOutBack,
        ),
      )),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _pwController.dispose();
    _confirmPwController.dispose();
    super.dispose();
  }

  void register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pwController.text != _confirmPwController.text) {
      _showErrorSnackBar("Passwords don't match!");
      return;
    }

    setState(() => _isLoading = true);

    final authService = AuthService();

    try {
      await authService.signUpWithEmailPassword(
        _emailController.text.trim(),
        _pwController.text,
      );
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 8),
                Text("Account created successfully!"),
              ],
            ),
            backgroundColor: Colors.green.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark 
          ? const Color(0xFF0A0A0A)
          : Colors.grey.shade50,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo and Title
                  SlideTransition(
                    position: _slideAnimations[0],
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.primaryColor,
                            theme.primaryColor.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_add_rounded,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Welcome Message
                  SlideTransition(
                    position: _slideAnimations[1],
                    child: Column(
                      children: [
                        Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onBackground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Join us and start your journey today",
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.colorScheme.onBackground.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Email Field
                  SlideTransition(
                    position: _slideAnimations[2],
                    child: _buildTextField(
                      controller: _emailController,
                      hintText: "Email Address",
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value!)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Password Field
                  SlideTransition(
                    position: _slideAnimations[3],
                    child: _buildTextField(
                      controller: _pwController,
                      hintText: "Password",
                      icon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter a password';
                        }
                        if (value!.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(value)) {
                          return 'Password must contain letters and numbers';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Confirm Password Field
                  SlideTransition(
                    position: _slideAnimations[4],
                    child: _buildTextField(
                      controller: _confirmPwController,
                      hintText: "Confirm Password",
                      icon: Icons.lock_outline,
                      obscureText: _obscureConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please confirm your password';
                        }
                        if (value != _pwController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Password Requirements
                  SlideTransition(
                    position: _slideAnimations[5],
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.primaryColor.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Password Requirements:",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: theme.primaryColor,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildRequirement("At least 6 characters"),
                          _buildRequirement("Contains letters and numbers"),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Register Button
                  SlideTransition(
                    position: _slideAnimations[5],
                    child: _buildRegisterButton(),
                  ),

                  const SizedBox(height: 32),

                  // Login Link
                  SlideTransition(
                    position: _slideAnimations[6],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: TextStyle(
                            color: theme.colorScheme.onBackground.withOpacity(0.7),
                          ),
                        ),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: Text(
                            "Sign In",
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(
          fontSize: 16,
          color: theme.colorScheme.onBackground,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: theme.colorScheme.onBackground.withOpacity(0.5),
          ),
          prefixIcon: Icon(
            icon,
            color: theme.primaryColor.withOpacity(0.7),
          ),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: theme.cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.1),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: theme.primaryColor,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: theme.colorScheme.error,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : register,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: theme.primaryColor.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildRequirement(String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: theme.primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}