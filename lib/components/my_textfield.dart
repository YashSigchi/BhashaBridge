import 'package:flutter/material.dart';

// Enhanced MyTextField with better styling and animations
class MyTextField extends StatefulWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? minLines;
  final Function(String)? onSubmitted;

  const MyTextField({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    this.focusNode,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.keyboardType,
    this.maxLines = 1,
    this.minLines = 1,
    this.onSubmitted,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _focusAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _focusAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    widget.focusNode?.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = widget.focusNode?.hasFocus ?? false;
    });
    
    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_onFocusChange);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: AnimatedBuilder(
        animation: _focusAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.08 * _focusAnimation.value),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              obscureText: widget.obscureText,
              controller: widget.controller,
              focusNode: widget.focusNode,
              keyboardType: widget.keyboardType,
              maxLines: widget.maxLines,
              minLines: widget.minLines,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: widget.onSubmitted,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: colorScheme.tertiary,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 2.0,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: colorScheme.error,
                    width: 1.5,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: colorScheme.error,
                    width: 2.0,
                  ),
                ),
                fillColor: colorScheme.secondary,
                filled: true,
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: colorScheme.primary.withOpacity(0.6),
                  fontSize: 16,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: widget.maxLines! > 1 ? 16 : 14,
                ),
                prefixIcon: widget.prefixIcon != null
                    ? Icon(
                        widget.prefixIcon,
                        color: _isFocused 
                            ? colorScheme.primary 
                            : colorScheme.onSurface.withOpacity(0.6),
                        size: 20,
                      )
                    : null,
                suffixIcon: widget.suffixIcon != null
                    ? IconButton(
                        icon: Icon(
                          widget.suffixIcon,
                          color: _isFocused 
                              ? colorScheme.primary 
                              : colorScheme.onSurface.withOpacity(0.6),
                          size: 20,
                        ),
                        onPressed: widget.onSuffixIconTap,
                        splashRadius: 20,
                      )
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}