import 'package:flutter/material.dart';
import 'package:myapp/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;

  const ChatBubble({
    super.key,
    required this.isCurrentUser,
    required this.message
  });

  @override
  Widget build(BuildContext context) {
    // Get theme colors
    bool isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        // Use theme colors instead of hardcoded colors
        color: isCurrentUser 
          ? colorScheme.primary  // Primary color for user messages
          : colorScheme.secondary,  // Secondary color for received messages
        borderRadius: BorderRadius.circular(16),  // Slightly more rounded for modern look
        // Add subtle shadow for depth
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
      child: Text(
        message,
        style: TextStyle(
          // Smart text colors based on bubble color
          color: isCurrentUser
            ? _getTextColorForBackground(colorScheme.primary)
            : (isDarkMode ? Colors.white : Colors.black87),
          fontSize: 16,
          height: 1.4,  // Better line spacing for readability
        ),
      ),
    );
  }

  // Helper method to determine text color based on background
  Color _getTextColorForBackground(Color backgroundColor) {
    // Calculate luminance to determine if we need light or dark text
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}

// Enhanced version with more AI chat features
class EnhancedChatBubble extends StatefulWidget {
  final String message;
  final bool isCurrentUser;
  final DateTime? timestamp;
  final bool isTranslated;
  final String? originalLanguage;
  final String? translatedLanguage;
  final bool isTyping;
  final VoidCallback? onTranslate;
  final VoidCallback? onCopy;

  const EnhancedChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    this.timestamp,
    this.isTranslated = false,
    this.originalLanguage,
    this.translatedLanguage,
    this.isTyping = false,
    this.onTranslate,
    this.onCopy,
  });

  @override
  State<EnhancedChatBubble> createState() => _EnhancedChatBubbleState();
}

class _EnhancedChatBubbleState extends State<EnhancedChatBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _slideAnimation = Tween<Offset>(
      begin: widget.isCurrentUser 
          ? const Offset(0.3, 0.0) 
          : const Offset(-0.3, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: Row(
            mainAxisAlignment: widget.isCurrentUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Flexible(
                child: GestureDetector(
                  onLongPress: () => _showMessageOptions(context),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      // Use gradient for user messages to make them stand out
                      gradient: widget.isCurrentUser
                          ? LinearGradient(
                              colors: [
                                colorScheme.primary,
                                colorScheme.primary.withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: widget.isCurrentUser
                          ? null
                          : colorScheme.secondary,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(widget.isCurrentUser ? 20 : 4),
                        bottomRight: Radius.circular(widget.isCurrentUser ? 4 : 20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Translation indicator
                        if (widget.isTranslated) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.translate,
                                size: 14,
                                color: widget.isCurrentUser
                                    ? Colors.white.withOpacity(0.8)
                                    : colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.originalLanguage} → ${widget.translatedLanguage}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: widget.isCurrentUser
                                      ? Colors.white.withOpacity(0.8)
                                      : colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                        ],
                        // Message text
                        widget.isTyping
                            ? _buildTypingIndicator()
                            : Text(
                                widget.message,
                                style: TextStyle(
                                  color: widget.isCurrentUser
                                      ? Colors.white
                                      : (isDarkMode ? Colors.white : Colors.black87),
                                  fontSize: 16,
                                  height: 1.4,
                                ),
                              ),
                        // Timestamp
                        if (widget.timestamp != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            _formatTime(widget.timestamp!),
                            style: TextStyle(
                              fontSize: 11,
                              color: widget.isCurrentUser
                                  ? Colors.white.withOpacity(0.7)
                                  : (isDarkMode 
                                      ? Colors.white.withOpacity(0.6)
                                      : Colors.black.withOpacity(0.5)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < 3; i++) ...[
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, -4 * (0.5 - (value - 0.5).abs()) * 2),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: widget.isCurrentUser
                        ? Colors.white.withOpacity(0.8)
                        : Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
          if (i < 2) const SizedBox(width: 4),
        ],
      ],
    );
  }

  void _showMessageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.onTranslate != null)
              ListTile(
                leading: const Icon(Icons.translate),
                title: const Text('Translate'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onTranslate?.call();
                },
              ),
            if (widget.onCopy != null)
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onCopy?.call();
                },
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${timestamp.day}/${timestamp.month}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }
}


































// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:myapp/themes/theme_provider.dart';
// import 'package:provider/provider.dart';

// class ChatBubble extends StatefulWidget {
//   final String message;
//   final bool isCurrentUser;

//   const ChatBubble({
//     super.key,
//     required this.isCurrentUser,
//     required this.message
//   });

//   @override
//   State<ChatBubble> createState() => _ChatBubbleState();
// }

// class _ChatBubbleState extends State<ChatBubble> 
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _scaleAnimation;
//   late Animation<Offset> _slideAnimation;
//   bool _isPressed = false;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 400),
//       vsync: this,
//     );

//     _scaleAnimation = Tween<double>(
//       begin: 0.7,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.elasticOut,
//     ));

//     _slideAnimation = Tween<Offset>(
//       begin: widget.isCurrentUser 
//           ? const Offset(0.5, 0.0) 
//           : const Offset(-0.5, 0.0),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeOutQuart,
//     ));

//     // Start animation
//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   void _copyToClipboard() {
//     Clipboard.setData(ClipboardData(text: widget.message));
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.check_circle, color: Colors.white, size: 20),
//             SizedBox(width: 8),
//             Text('Message copied', style: TextStyle(fontSize: 14)),
//           ],
//         ),
//         backgroundColor: Colors.green[600],
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         margin: EdgeInsets.all(16),
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     bool isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
//     final colorScheme = Theme.of(context).colorScheme;

//     return SlideTransition(
//       position: _slideAnimation,
//       child: ScaleTransition(
//         scale: _scaleAnimation,
//         child: Align(
//           alignment: widget.isCurrentUser 
//               ? Alignment.centerRight 
//               : Alignment.centerLeft,
//           child: GestureDetector(
//             onTapDown: (_) => setState(() => _isPressed = true),
//             onTapUp: (_) => setState(() => _isPressed = false),
//             onTapCancel: () => setState(() => _isPressed = false),
//             onLongPress: () {
//               HapticFeedback.mediumImpact();
//               _showMessageOptions(context);
//             },
//             child: AnimatedScale(
//               scale: _isPressed ? 0.95 : 1.0,
//               duration: Duration(milliseconds: 100),
//               child: Container(
//                 constraints: BoxConstraints(
//                   maxWidth: MediaQuery.of(context).size.width * 0.78,
//                   minWidth: 60,
//                 ),
//                 margin: EdgeInsets.symmetric(
//                   vertical: 3,
//                   horizontal: 16,
//                 ),
//                 padding: EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 12,
//                 ),
//                 decoration: BoxDecoration(
//                   gradient: widget.isCurrentUser
//                       ? LinearGradient(
//                           colors: [
//                             colorScheme.primary,
//                             colorScheme.primary.withOpacity(0.85),
//                           ],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         )
//                       : null,
//                   color: widget.isCurrentUser
//                       ? null
//                       : isDarkMode 
//                           ? Color(0xFF2A2A2A)
//                           : Color(0xFFF0F0F0),
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(20),
//                     topRight: Radius.circular(20),
//                     bottomLeft: Radius.circular(widget.isCurrentUser ? 20 : 6),
//                     bottomRight: Radius.circular(widget.isCurrentUser ? 6 : 20),
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: widget.isCurrentUser
//                           ? colorScheme.primary.withOpacity(0.3)
//                           : Colors.black.withOpacity(isDarkMode ? 0.4 : 0.08),
//                       blurRadius: widget.isCurrentUser ? 12 : 8,
//                       offset: Offset(0, widget.isCurrentUser ? 3 : 2),
//                       spreadRadius: widget.isCurrentUser ? 0 : 1,
//                     ),
//                   ],
//                   border: widget.isCurrentUser
//                       ? null
//                       : Border.all(
//                           color: isDarkMode 
//                               ? Colors.grey[700]!.withOpacity(0.3)
//                               : Colors.grey[300]!.withOpacity(0.5),
//                           width: 0.5,
//                         ),
//                 ),
//                 child: SelectableText(
//                   widget.message,
//                   style: TextStyle(
//                     color: widget.isCurrentUser
//                         ? Colors.white
//                         : isDarkMode 
//                             ? Colors.white
//                             : Color(0xFF1A1A1A),
//                     fontSize: 16,
//                     height: 1.4,
//                     fontWeight: FontWeight.w400,
//                     letterSpacing: 0.1,
//                   ),
//                   // Custom selection colors
//                   selectionControls: MaterialTextSelectionControls(),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showMessageOptions(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         margin: EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: isDarkMode ? Color(0xFF2A2A2A) : Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 20,
//               offset: Offset(0, -5),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Handle bar
//             Container(
//               margin: EdgeInsets.only(top: 12, bottom: 8),
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.grey[400],
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
            
//             Padding(
//               padding: EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   _buildOptionTile(
//                     context,
//                     Icons.copy_rounded,
//                     'Copy Message',
//                     'Copy this message to clipboard',
//                     () {
//                       Navigator.pop(context);
//                       _copyToClipboard();
//                     },
//                   ),
//                   SizedBox(height: 8),
//                   _buildOptionTile(
//                     context,
//                     Icons.reply_rounded,
//                     'Reply',
//                     'Reply to this message',
//                     () {
//                       Navigator.pop(context);
//                       // Add reply functionality
//                     },
//                   ),
//                   if (widget.isCurrentUser) ...[
//                     SizedBox(height: 8),
//                     _buildOptionTile(
//                       context,
//                       Icons.delete_outline_rounded,
//                       'Delete',
//                       'Delete this message',
//                       () {
//                         Navigator.pop(context);
//                         // Add delete functionality
//                       },
//                       isDestructive: true,
//                     ),
//                   ],
//                 ],
//               ),
//             ),
            
//             // Safe area padding
//             SizedBox(height: MediaQuery.of(context).padding.bottom),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildOptionTile(
//     BuildContext context,
//     IconData icon,
//     String title,
//     String subtitle,
//     VoidCallback onTap, {
//     bool isDestructive = false,
//   }) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     final color = isDestructive 
//         ? Colors.red[600]! 
//         : (isDarkMode ? Colors.white : Colors.black87);
    
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: onTap,
//         child: Container(
//           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             color: isDarkMode 
//                 ? Colors.grey[800]!.withOpacity(0.3)
//                 : Colors.grey[100]!.withOpacity(0.5),
//           ),
//           child: Row(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   icon,
//                   color: color,
//                   size: 20,
//                 ),
//               ),
//               SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: TextStyle(
//                         color: color,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     SizedBox(height: 2),
//                     Text(
//                       subtitle,
//                       style: TextStyle(
//                         color: color.withOpacity(0.7),
//                         fontSize: 13,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Helper method to determine text color based on background
//   Color _getTextColorForBackground(Color backgroundColor) {
//     final luminance = backgroundColor.computeLuminance();
//     return luminance > 0.5 ? Colors.black87 : Colors.white;
//   }
// }

// // Enhanced version with more AI chat features
// class EnhancedChatBubble extends StatefulWidget {
//   final String message;
//   final bool isCurrentUser;
//   final DateTime? timestamp;
//   final bool isTranslated;
//   final String? originalLanguage;
//   final String? translatedLanguage;
//   final bool isTyping;
//   final VoidCallback? onTranslate;
//   final VoidCallback? onCopy;
//   final VoidCallback? onReply;

//   const EnhancedChatBubble({
//     super.key,
//     required this.message,
//     required this.isCurrentUser,
//     this.timestamp,
//     this.isTranslated = false,
//     this.originalLanguage,
//     this.translatedLanguage,
//     this.isTyping = false,
//     this.onTranslate,
//     this.onCopy,
//     this.onReply,
//   });

//   @override
//   State<EnhancedChatBubble> createState() => _EnhancedChatBubbleState();
// }

// class _EnhancedChatBubbleState extends State<EnhancedChatBubble>
//     with TickerProviderStateMixin {
//   late AnimationController _animationController;
//   late AnimationController _typingController;
//   late Animation<double> _scaleAnimation;
//   late Animation<Offset> _slideAnimation;
//   bool _isPressed = false;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );

//     _typingController = AnimationController(
//       duration: const Duration(milliseconds: 1200),
//       vsync: this,
//     );

//     _scaleAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.elasticOut,
//     ));

//     _slideAnimation = Tween<Offset>(
//       begin: widget.isCurrentUser 
//           ? const Offset(0.3, 0.0) 
//           : const Offset(-0.3, 0.0),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeOutCubic,
//     ));

//     _animationController.forward();
    
//     if (widget.isTyping) {
//       _typingController.repeat();
//     }
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _typingController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
//     return SlideTransition(
//       position: _slideAnimation,
//       child: ScaleTransition(
//         scale: _scaleAnimation,
//         child: Container(
//           margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
//           child: Row(
//             mainAxisAlignment: widget.isCurrentUser
//                 ? MainAxisAlignment.end
//                 : MainAxisAlignment.start,
//             children: [
//               Flexible(
//                 child: GestureDetector(
//                   onTapDown: (_) => setState(() => _isPressed = true),
//                   onTapUp: (_) => setState(() => _isPressed = false),
//                   onTapCancel: () => setState(() => _isPressed = false),
//                   onLongPress: () {
//                     HapticFeedback.mediumImpact();
//                     _showEnhancedMessageOptions(context);
//                   },
//                   child: AnimatedScale(
//                     scale: _isPressed ? 0.96 : 1.0,
//                     duration: Duration(milliseconds: 100),
//                     child: Container(
//                       constraints: BoxConstraints(
//                         maxWidth: MediaQuery.of(context).size.width * 0.78,
//                       ),
//                       decoration: BoxDecoration(
//                         gradient: widget.isCurrentUser
//                             ? LinearGradient(
//                                 colors: [
//                                   colorScheme.primary,
//                                   colorScheme.primary.withOpacity(0.8),
//                                 ],
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                               )
//                             : null,
//                         color: widget.isCurrentUser
//                             ? null
//                             : isDarkMode 
//                                 ? Color(0xFF2A2A2A)
//                                 : Color(0xFFF0F0F0),
//                         borderRadius: BorderRadius.only(
//                           topLeft: const Radius.circular(20),
//                           topRight: const Radius.circular(20),
//                           bottomLeft: Radius.circular(widget.isCurrentUser ? 20 : 6),
//                           bottomRight: Radius.circular(widget.isCurrentUser ? 6 : 20),
//                         ),
//                         boxShadow: [
//                           BoxShadow(
//                             color: widget.isCurrentUser
//                                 ? colorScheme.primary.withOpacity(0.3)
//                                 : Colors.black.withOpacity(isDarkMode ? 0.4 : 0.08),
//                             blurRadius: widget.isCurrentUser ? 12 : 8,
//                             offset: Offset(0, widget.isCurrentUser ? 3 : 2),
//                           ),
//                         ],
//                         border: widget.isCurrentUser
//                             ? null
//                             : Border.all(
//                                 color: isDarkMode 
//                                     ? Colors.grey[700]!.withOpacity(0.3)
//                                     : Colors.grey[300]!.withOpacity(0.5),
//                                 width: 0.5,
//                               ),
//                       ),
//                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           // Translation indicator
//                           if (widget.isTranslated) ...[
//                             Container(
//                               padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                               decoration: BoxDecoration(
//                                 color: (widget.isCurrentUser ? Colors.white : colorScheme.primary)
//                                     .withOpacity(0.15),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Icon(
//                                     Icons.translate_rounded,
//                                     size: 14,
//                                     color: widget.isCurrentUser
//                                         ? Colors.white.withOpacity(0.9)
//                                         : colorScheme.primary,
//                                   ),
//                                   const SizedBox(width: 6),
//                                   Text(
//                                     '${widget.originalLanguage?.toUpperCase()} → ${widget.translatedLanguage?.toUpperCase()}',
//                                     style: TextStyle(
//                                       fontSize: 11,
//                                       color: widget.isCurrentUser
//                                           ? Colors.white.withOpacity(0.9)
//                                           : colorScheme.primary,
//                                       fontWeight: FontWeight.w600,
//                                       letterSpacing: 0.5,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                           ],
                          
//                           // Message content
//                           widget.isTyping
//                               ? _buildEnhancedTypingIndicator()
//                               : SelectableText(
//                                   widget.message,
//                                   style: TextStyle(
//                                     color: widget.isCurrentUser
//                                         ? Colors.white
//                                         : (isDarkMode ? Colors.white : Color(0xFF1A1A1A)),
//                                     fontSize: 16,
//                                     height: 1.4,
//                                     fontWeight: FontWeight.w400,
//                                     letterSpacing: 0.1,
//                                   ),
//                                 ),
                          
//                           // Timestamp
//                           if (widget.timestamp != null && !widget.isTyping) ...[
//                             const SizedBox(height: 6),
//                             Text(
//                               _formatTime(widget.timestamp!),
//                               style: TextStyle(
//                                 fontSize: 11,
//                                 color: widget.isCurrentUser
//                                     ? Colors.white.withOpacity(0.7)
//                                     : (isDarkMode 
//                                         ? Colors.white.withOpacity(0.6)
//                                         : Colors.black.withOpacity(0.5)),
//                                 fontWeight: FontWeight.w400,
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEnhancedTypingIndicator() {
//     return SizedBox(
//       height: 24,
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: List.generate(3, (index) {
//           return AnimatedBuilder(
//             animation: _typingController,
//             builder: (context, child) {
//               final animationValue = (_typingController.value - (index * 0.2)) % 1.0;
//               final scale = 1.0 + (0.3 * (0.5 - (animationValue - 0.5).abs()) * 2);
//               final opacity = 0.4 + (0.4 * (0.5 - (animationValue - 0.5).abs()) * 2);
              
//               return Container(
//                 margin: EdgeInsets.only(right: index < 2 ? 6 : 0),
//                 child: Transform.scale(
//                   scale: scale,
//                   child: Container(
//                     width: 8,
//                     height: 8,
//                     decoration: BoxDecoration(
//                       color: (widget.isCurrentUser
//                           ? Colors.white
//                           : Theme.of(context).colorScheme.primary)
//                           .withOpacity(opacity),
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         }),
//       ),
//     );
//   }

//   void _showEnhancedMessageOptions(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (context) => Container(
//         margin: EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: isDarkMode ? Color(0xFF2A2A2A) : Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 20,
//               offset: Offset(0, -5),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Handle bar
//             Container(
//               margin: EdgeInsets.only(top: 12, bottom: 8),
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.grey[400],
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
            
//             Padding(
//               padding: EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   if (widget.onCopy != null)
//                     _buildEnhancedOptionTile(
//                       context,
//                       Icons.copy_rounded,
//                       'Copy',
//                       'Copy message to clipboard',
//                       () {
//                         Navigator.pop(context);
//                         widget.onCopy?.call();
//                       },
//                     ),
                  
//                   if (widget.onReply != null) ...[
//                     SizedBox(height: 8),
//                     _buildEnhancedOptionTile(
//                       context,
//                       Icons.reply_rounded,
//                       'Reply',
//                       'Reply to this message',
//                       () {
//                         Navigator.pop(context);
//                         widget.onReply?.call();
//                       },
//                     ),
//                   ],
                  
//                   if (widget.onTranslate != null) ...[
//                     SizedBox(height: 8),
//                     _buildEnhancedOptionTile(
//                       context,
//                       Icons.translate_rounded,
//                       'Translate',
//                       'Translate this message',
//                       () {
//                         Navigator.pop(context);
//                         widget.onTranslate?.call();
//                       },
//                     ),
//                   ],
//                 ],
//               ),
//             ),
            
//             SizedBox(height: MediaQuery.of(context).padding.bottom),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEnhancedOptionTile(
//     BuildContext context,
//     IconData icon,
//     String title,
//     String subtitle,
//     VoidCallback onTap,
//   ) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: onTap,
//         child: Container(
//           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             color: isDarkMode 
//                 ? Colors.grey[800]!.withOpacity(0.3)
//                 : Colors.grey[100]!.withOpacity(0.5),
//           ),
//           child: Row(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   icon,
//                   color: Theme.of(context).colorScheme.primary,
//                   size: 20,
//                 ),
//               ),
//               SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: TextStyle(
//                         color: isDarkMode ? Colors.white : Colors.black87,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     SizedBox(height: 2),
//                     Text(
//                       subtitle,
//                       style: TextStyle(
//                         color: (isDarkMode ? Colors.white : Colors.black87)
//                             .withOpacity(0.7),
//                         fontSize: 13,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   String _formatTime(DateTime timestamp) {
//     final now = DateTime.now();
//     final difference = now.difference(timestamp);

//     if (difference.inDays > 0) {
//       return '${timestamp.day}/${timestamp.month}';
//     } else if (difference.inHours > 0) {
//       return '${difference.inHours}h ago';
//     } else if (difference.inMinutes > 0) {
//       return '${difference.inMinutes}m ago';
//     } else {
//       return 'now';
//     }
//   }
// }