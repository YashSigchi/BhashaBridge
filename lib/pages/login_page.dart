// import 'package:flutter/material.dart';
// import 'package:BhashaBridge/services/auth/auth_service.dart';
// import 'package:BhashaBridge/components/my_button.dart';
// import 'package:BhashaBridge/components/my_textfield.dart';

// class LoginPage extends StatelessWidget {

//   // email and pw controllers
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _pwController = TextEditingController();

//   // tap to go to register page
//   final void Function()? onTap;

//   LoginPage({
//     super.key,
//     required this.onTap,
//   });

//   //login method
//   void login(BuildContext context) async{
//     //auth service
//     final authService = AuthService();

//     //try login
//     try{
//       await authService.signInWithEmailPassword(_emailController.text, _pwController.text);
//     }

//     //catch errror
//     catch(e){
//       showDialog(context: context, builder: (context) => AlertDialog(
//           title: Text(e.toString()),
//         ),
//       );
//     }


//   }

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.background,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // logo
//             Icon(
//               Icons.message,
//               size: 60,
//               color: Theme.of(context).colorScheme.primary,
//             ),

//             const SizedBox(height: 50),

//             // welcome back message
//             Text(
//               "Welcome back, you've been missed!", 
//               style: TextStyle(
//                 color: Theme.of(context).colorScheme.primary,
//                 fontSize: 16,
//               ),
//             ),

//             const SizedBox(height: 25),

//             // email textfield
//             MyTextField(
//               hintText:"Email",
//               obscureText: false,
//               controller: _emailController,

//             ),

//             const SizedBox(height: 10),

//             // pw textfield
//             MyTextField(
//               hintText:"password",
//               obscureText: true,
//               controller: _pwController,
//             ),

//             const SizedBox(height: 25),

//             //Login Button
//             MyButton(
//               text: "Login",
//               onTap: () => login(context),
//             ),

//             const SizedBox(height: 25),

//             //register button
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   "Not a member?",
//                   style: TextStyle(color: Theme.of(context).colorScheme.primary),
//                 ),
//                 GestureDetector(
//                   onTap: onTap,
//                   child: Text(
//                     "Register now",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Theme.of(context).colorScheme.primary,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }






// login_page.dart
import 'package:flutter/material.dart';
import 'package:BhashaBridge/services/auth/auth_service.dart';
import 'package:BhashaBridge/components/my_button.dart';
import 'package:BhashaBridge/components/my_textfield.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({
    super.key,
    required this.onTap,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
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
      6,
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
    super.dispose();
  }

  void login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authService = AuthService();

    try {
      await authService.signInWithEmailPassword(
        _emailController.text.trim(),
        _pwController.text,
      );
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
                      child: Icon(
                        Icons.chat_bubble_rounded,
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
                          "Welcome Back!",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onBackground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Sign in to continue to your account",
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.colorScheme.onBackground.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

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
                          return 'Please enter your password';
                        }
                        if (value!.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Login Button
                  SlideTransition(
                    position: _slideAnimations[4],
                    child: _buildLoginButton(),
                  ),

                  const SizedBox(height: 24),

                  // // Forgot Password
                  // SlideTransition(
                  //   position: _slideAnimations[5],
                  //   child: TextButton(
                  //     onPressed: () {
                  //       // Implement forgot password
                  //     },
                  //     child: Text(
                  //       "Forgot Password?",
                  //       style: TextStyle(
                  //         color: theme.primaryColor,
                  //         fontWeight: FontWeight.w600,
                  //       ),
                  //     ),
                  //   ),
                  // ),

                  const SizedBox(height: 32),

                  // Register Link
                  SlideTransition(
                    position: _slideAnimations[5],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: theme.colorScheme.onBackground.withOpacity(0.7),
                          ),
                        ),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: Text(
                            "Sign Up",
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

  Widget _buildLoginButton() {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : login,
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
                "Sign In",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}