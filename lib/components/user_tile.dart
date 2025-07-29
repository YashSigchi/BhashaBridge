import 'package:flutter/material.dart';
// Enhanced UserTile with better styling and animations
class UserTile extends StatefulWidget {
  final String text;
  final void Function()? onTap;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool isOnline;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int? unreadCount;

  const UserTile({
    super.key,
    required this.text,
    required this.onTap,
    this.subtitle,
    this.leading,
    this.trailing,
    this.isOnline = false,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount,
  });

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _animationController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _animationController.reverse();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _animationController.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.secondary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.08),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
          ),
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 25),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: widget.onTap,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Leading widget or default avatar
                    Stack(
                      children: [
                        widget.leading ?? Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primary.withOpacity(0.8),
                                colorScheme.secondary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withOpacity(0.2),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        // Online indicator
                        if (widget.isOnline)
                          Positioned(
                            right: 2,
                            bottom: 2,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colorScheme.surface,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.text,
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (widget.lastMessageTime != null)
                                Text(
                                  _formatTime(widget.lastMessageTime!),
                                  style: TextStyle(
                                    color: colorScheme.onSurface.withOpacity(0.6),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                          
                          if (widget.lastMessage != null || widget.subtitle != null)
                            SizedBox(height: 4),
                          
                          if (widget.lastMessage != null || widget.subtitle != null)
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.lastMessage ?? widget.subtitle ?? '',
                                    style: TextStyle(
                                      color: colorScheme.onSurface.withOpacity(0.7),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                if (widget.unreadCount != null && widget.unreadCount! > 0)
                                  Container(
                                    margin: EdgeInsets.only(left: 8),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      widget.unreadCount! > 99 
                                          ? '99+' 
                                          : widget.unreadCount.toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    
                    // Trailing widget
                    if (widget.trailing != null) ...[
                      const SizedBox(width: 12),
                      widget.trailing!,
                    ] else ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right,
                        color: colorScheme.onSurface.withOpacity(0.4),
                        size: 20,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}