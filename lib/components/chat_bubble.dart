// import 'package:flutter/material.dart';
// import 'package:BhashaBridge/themes/theme_provider.dart';
// import 'package:provider/provider.dart';

// class ChatBubble extends StatelessWidget {
//   final String message;
//   final bool isCurrentUser;

//   const ChatBubble({
//     super.key,
//     required this.isCurrentUser,
//     required this.message
//   });

//   @override
//   Widget build(BuildContext context) {
//     // Get theme colors
//     bool isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
//     final colorScheme = Theme.of(context).colorScheme;

//     return Container(
//       decoration: BoxDecoration(
//         // Use theme colors instead of hardcoded colors
//         color: isCurrentUser 
//           ? colorScheme.primary  // Primary color for user messages
//           : colorScheme.secondary,  // Secondary color for received messages
//         borderRadius: BorderRadius.circular(16),  // Slightly more rounded for modern look
//         // Add subtle shadow for depth
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
//       child: Text(
//         message,
//         style: TextStyle(
//           // Smart text colors based on bubble color
//           color: isCurrentUser
//             ? _getTextColorForBackground(colorScheme.primary)
//             : (isDarkMode ? Colors.white : Colors.black87),
//           fontSize: 16,
//           height: 1.4,  // Better line spacing for readability
//         ),
//       ),
//     );
//   }

//   // Helper method to determine text color based on background
//   Color _getTextColorForBackground(Color backgroundColor) {
//     // Calculate luminance to determine if we need light or dark text
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
//   });

//   @override
//   State<EnhancedChatBubble> createState() => _EnhancedChatBubbleState();
// }

// class _EnhancedChatBubbleState extends State<EnhancedChatBubble>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _scaleAnimation;
//   late Animation<Offset> _slideAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );

//     _scaleAnimation = Tween<double>(
//       begin: 0.8,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeOutBack,
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
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
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
//                   onLongPress: () => _showMessageOptions(context),
//                   child: Container(
//                     constraints: BoxConstraints(
//                       maxWidth: MediaQuery.of(context).size.width * 0.75,
//                     ),
//                     decoration: BoxDecoration(
//                       // Use gradient for user messages to make them stand out
//                       gradient: widget.isCurrentUser
//                           ? LinearGradient(
//                               colors: [
//                                 colorScheme.primary,
//                                 colorScheme.primary.withOpacity(0.8),
//                               ],
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                             )
//                           : null,
//                       color: widget.isCurrentUser
//                           ? null
//                           : colorScheme.secondary,
//                       borderRadius: BorderRadius.only(
//                         topLeft: const Radius.circular(20),
//                         topRight: const Radius.circular(20),
//                         bottomLeft: Radius.circular(widget.isCurrentUser ? 20 : 4),
//                         bottomRight: Radius.circular(widget.isCurrentUser ? 4 : 20),
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
//                           blurRadius: 8,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Translation indicator
//                         if (widget.isTranslated) ...[
//                           Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 Icons.translate,
//                                 size: 14,
//                                 color: widget.isCurrentUser
//                                     ? Colors.white.withOpacity(0.8)
//                                     : colorScheme.primary,
//                               ),
//                               const SizedBox(width: 4),
//                               Text(
//                                 '${widget.originalLanguage} → ${widget.translatedLanguage}',
//                                 style: TextStyle(
//                                   fontSize: 11,
//                                   color: widget.isCurrentUser
//                                       ? Colors.white.withOpacity(0.8)
//                                       : colorScheme.primary,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 6),
//                         ],
//                         // Message text
//                         widget.isTyping
//                             ? _buildTypingIndicator()
//                             : Text(
//                                 widget.message,
//                                 style: TextStyle(
//                                   color: widget.isCurrentUser
//                                       ? Colors.white
//                                       : (isDarkMode ? Colors.white : Colors.black87),
//                                   fontSize: 16,
//                                   height: 1.4,
//                                 ),
//                               ),
//                         // Timestamp
//                         if (widget.timestamp != null) ...[
//                           const SizedBox(height: 6),
//                           Text(
//                             _formatTime(widget.timestamp!),
//                             style: TextStyle(
//                               fontSize: 11,
//                               color: widget.isCurrentUser
//                                   ? Colors.white.withOpacity(0.7)
//                                   : (isDarkMode 
//                                       ? Colors.white.withOpacity(0.6)
//                                       : Colors.black.withOpacity(0.5)),
//                             ),
//                           ),
//                         ],
//                       ],
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

//   Widget _buildTypingIndicator() {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         for (int i = 0; i < 3; i++) ...[
//           TweenAnimationBuilder<double>(
//             duration: const Duration(milliseconds: 600),
//             tween: Tween(begin: 0.0, end: 1.0),
//             builder: (context, value, child) {
//               return Transform.translate(
//                 offset: Offset(0, -4 * (0.5 - (value - 0.5).abs()) * 2),
//                 child: Container(
//                   width: 8,
//                   height: 8,
//                   decoration: BoxDecoration(
//                     color: widget.isCurrentUser
//                         ? Colors.white.withOpacity(0.8)
//                         : Theme.of(context).colorScheme.primary,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//               );
//             },
//           ),
//           if (i < 2) const SizedBox(width: 4),
//         ],
//       ],
//     );
//   }

//   void _showMessageOptions(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) => Container(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if (widget.onTranslate != null)
//               ListTile(
//                 leading: const Icon(Icons.translate),
//                 title: const Text('Translate'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   widget.onTranslate?.call();
//                 },
//               ),
//             if (widget.onCopy != null)
//               ListTile(
//                 leading: const Icon(Icons.copy),
//                 title: const Text('Copy'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   widget.onCopy?.call();
//                 },
//               ),
//           ],
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






















import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:BhashaBridge/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class ChatBubble extends StatefulWidget {
  final String message;
  final bool isCurrentUser;
  final DateTime? timestamp;
  final bool isTranslated;
  final String? originalMessage;
  final String? originalLanguage;
  final String? translatedLanguage;
  final bool isDelivered;
  final bool isRead;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;

  const ChatBubble({
    super.key,
    required this.isCurrentUser,
    required this.message,
    this.timestamp,
    this.isTranslated = false,
    this.originalMessage,
    this.originalLanguage,
    this.translatedLanguage,
    this.isDelivered = true,
    this.isRead = false,
    this.onLongPress,
    this.onTap,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _animationController.forward();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: widget.isCurrentUser 
          ? const Offset(0.5, 0.0) 
          : const Offset(-0.5, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: _buildMessageContainer(colorScheme, isDarkMode),
        ),
      ),
    );
  }

  Widget _buildMessageContainer(ColorScheme colorScheme, bool isDarkMode) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 2,
        horizontal: 8,
      ),
      child: Row(
        mainAxisAlignment: widget.isCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar for received messages
          if (!widget.isCurrentUser) ...[
            _buildAvatar(colorScheme),
            SizedBox(width: 8),
          ],
          
          // Message bubble
          Flexible(
            child: _buildMessageBubble(colorScheme, isDarkMode),
          ),
          
          // Status indicators for sent messages
          if (widget.isCurrentUser) ...[
            SizedBox(width: 4),
            _buildMessageStatus(colorScheme),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(ColorScheme colorScheme) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.8),
            colorScheme.inversePrimary.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.person,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ColorScheme colorScheme, bool isDarkMode) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: () {
        HapticFeedback.mediumImpact();
        widget.onLongPress?.call();
      },
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: Duration(milliseconds: 100),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
            minWidth: 48,
          ),
          child: Column(
            crossAxisAlignment: widget.isCurrentUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              // Translation indicator
              if (widget.isTranslated) _buildTranslationIndicator(colorScheme),
              
              // Main message bubble
              _buildBubbleContainer(colorScheme, isDarkMode),
              
              // Timestamp (if provided)
              if (widget.timestamp != null) 
                _buildTimestamp(colorScheme, isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTranslationIndicator(ColorScheme colorScheme) {
    return Container(
      margin: EdgeInsets.only(
        bottom: 4,
        left: widget.isCurrentUser ? 0 : 12,
        right: widget.isCurrentUser ? 12 : 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.translate,
            size: 12,
            color: colorScheme.primary,
          ),
          SizedBox(width: 4),
          Text(
            '${widget.originalLanguage ?? 'AUTO'} → ${widget.translatedLanguage ?? 'AUTO'}',
            style: TextStyle(
              fontSize: 10,
              color: colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubbleContainer(ColorScheme colorScheme, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        gradient: widget.isCurrentUser
            ? LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: widget.isCurrentUser ? null : colorScheme.secondary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(widget.isCurrentUser ? 18 : 4),
          bottomRight: Radius.circular(widget.isCurrentUser ? 4 : 18),
        ),
        boxShadow: [
          BoxShadow(
            color: widget.isCurrentUser
                ? colorScheme.primary.withOpacity(0.3)
                : Colors.black.withOpacity(isDarkMode ? 0.4 : 0.1),
            blurRadius: 12,
            offset: Offset(0, 3),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(widget.isCurrentUser ? 18 : 4),
            bottomRight: Radius.circular(widget.isCurrentUser ? 4 : 18),
          ),
          onTap: widget.onTap,
          onLongPress: () {
            HapticFeedback.mediumImpact();
            widget.onLongPress?.call();
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: _buildMessageContent(colorScheme, isDarkMode),
          ),
        ),
      ),
    );
  }

Widget _buildMessageContent(ColorScheme colorScheme, bool isDarkMode) {
    final textColor = widget.isCurrentUser
        ? Colors.white
        : (isDarkMode ? Colors.white : colorScheme.onSecondary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Original message (if translated)
        if (widget.isTranslated && widget.originalMessage != null) ...[
          Container(
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: widget.isCurrentUser
                  ? Colors.white.withOpacity(0.2)
                  : colorScheme.tertiary.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.isCurrentUser
                    ? Colors.white.withOpacity(0.3)
                    : colorScheme.outline.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.edit_note,
                      size: 12,
                      color: widget.isCurrentUser
                          ? Colors.white.withOpacity(0.8)
                          : (isDarkMode 
                              ? Colors.white.withOpacity(0.8)
                              : Colors.black.withOpacity(0.8)),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Original',
                      style: TextStyle(
                        fontSize: 10,
                        color: widget.isCurrentUser
                            ? Colors.white.withOpacity(0.8)
                            : (isDarkMode 
                                ? Colors.white.withOpacity(0.8)
                                : Colors.black.withOpacity(0.8)),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  widget.originalMessage!,
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.isCurrentUser
                        ? Colors.white.withOpacity(0.9)
                        : (isDarkMode 
                            ? Colors.white.withOpacity(0.9)
                            : Colors.black.withOpacity(0.9)),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
        
        // Main message text
        SelectableText(
          widget.message,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            height: 1.4,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  

  Widget _buildTimestamp(ColorScheme colorScheme, bool isDarkMode) {
    return Container(
      margin: EdgeInsets.only(
        top: 4,
        left: widget.isCurrentUser ? 0 : 12,
        right: widget.isCurrentUser ? 12 : 0,
      ),
      child: Text(
        _formatTimestamp(widget.timestamp!),
        style: TextStyle(
          fontSize: 11,
          color: widget.isCurrentUser
              ? colorScheme.onBackground.withOpacity(0.6)
              : colorScheme.onBackground.withOpacity(0.5),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildMessageStatus(ColorScheme colorScheme) {
    return Container(
      margin: EdgeInsets.only(bottom: 4),
      child: Column(
        children: [
          if (widget.isDelivered)
            Icon(
              widget.isRead ? Icons.done_all : Icons.done,
              size: 14,
              color: widget.isRead 
                  ? colorScheme.primary
                  : colorScheme.onBackground.withOpacity(0.5),
            ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${timestamp.day}/${timestamp.month}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}

// Enhanced typing indicator widget
class TypingIndicator extends StatefulWidget {
  final bool isCurrentUser;
  
  const TypingIndicator({
    super.key,
    this.isCurrentUser = false,
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) {
      return AnimationController(
        duration: Duration(milliseconds: 600),
        vsync: this,
      );
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    _startAnimations();
  }

  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: widget.isCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!widget.isCurrentUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colorScheme.secondary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.person,
                color: colorScheme.onSecondary,
                size: 16,
              ),
            ),
            SizedBox(width: 8),
          ],
          
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.isCurrentUser 
                  ? colorScheme.primary.withOpacity(0.1)
                  : colorScheme.secondary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(widget.isCurrentUser ? 18 : 4),
                bottomRight: Radius.circular(widget.isCurrentUser ? 4 : 18),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: _animations.asMap().entries.map((entry) {
                return AnimatedBuilder(
                  animation: entry.value,
                  builder: (context, child) {
                    return Container(
                      margin: EdgeInsets.only(right: entry.key < 2 ? 4 : 0),
                      child: Transform.translate(
                        offset: Offset(0, -4 * entry.value.value),
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: widget.isCurrentUser
                                ? colorScheme.primary
                                : colorScheme.onSecondary.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}