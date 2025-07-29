import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:BhashaBridge/components/chat_bubble.dart';
import 'package:BhashaBridge/components/my_textfield.dart';
import 'package:BhashaBridge/services/auth/auth_service.dart';
import 'package:BhashaBridge/services/chat/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String receiveEmail;
  final String receiverID;

  ChatPage({
    super.key,
    required this.receiveEmail,
    required this.receiverID,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  // Controllers and services
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final FocusNode _focusNode = FocusNode();

  // Animation controllers
  late AnimationController _fabAnimationController;
  late AnimationController _headerAnimationController;
  late Animation<double> _fabAnimation;
  late Animation<Offset> _headerSlideAnimation;

  // State variables
  bool _isSending = false;
  bool _showScrollToBottom = false;
  bool _isTyping = false;
  bool _hasLoadedInitialMessages = false; // Add this flag
  bool _shouldAutoScroll = false; // Track when to auto-scroll
  String _lastMessage = '';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupScrollController();
    _setupFocusListener();
    _setupMessageController();
    
    // Initial animations
    _headerAnimationController.forward();
    
    // Initial scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Don't auto-scroll on initial load, let user see the conversation naturally
    });
  }

  void _setupAnimations() {
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    ));

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _setupScrollController() {
    _scrollController.addListener(() {
      // Only show FAB if initial messages have loaded
      if (!_hasLoadedInitialMessages) return;
      
      // Show/hide scroll to bottom button
      final showButton = _scrollController.offset < 
          _scrollController.position.maxScrollExtent - 100;
      
      if (showButton != _showScrollToBottom) {
        setState(() {
          _showScrollToBottom = showButton;
        });
        
        if (showButton) {
          _fabAnimationController.forward();
        } else {
          _fabAnimationController.reverse();
        }
      }
    });
  }

  void _setupFocusListener() {
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        // Delay scroll to allow keyboard animation
        Future.delayed(
          const Duration(milliseconds: 600),
          () => _scrollToBottom(),
        );
      }
    });
  }

  void _setupMessageController() {
    _messageController.addListener(() {
      final currentText = _messageController.text;
      final hasText = currentText.isNotEmpty;
      
      // Update typing state
      if (hasText != _isTyping) {
        setState(() {
          _isTyping = hasText;
        });
      }
      
      _lastMessage = currentText;
    });
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _headerAnimationController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;
    
    if (animated) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isSending) return;

    // Haptic feedback for better UX
    HapticFeedback.lightImpact();
    
    setState(() {
      _isSending = true;
      _shouldAutoScroll = true; // Enable auto-scroll for sent message
    });

    final messageText = _messageController.text.trim();
    _messageController.clear();

    // Scroll to bottom immediately for better UX
    _scrollToBottom();

    try {
      await _chatService.sendMessage(widget.receiverID, messageText);
      
      // Ensure scroll to bottom after message is sent
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToBottom();
        setState(() {
          _shouldAutoScroll = false; // Disable auto-scroll after message is sent
        });
      });
      
    } catch (e) {
      print('Error sending message: $e');
      _showErrorSnackBar('Failed to send message. Please try again.');
      _messageController.text = messageText;
      setState(() {
        _shouldAutoScroll = false; // Disable auto-scroll on error
      });
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(colorScheme),
      body: Column(
        children: [
          _buildTranslationBanner(colorScheme),
          Expanded(
            child: Stack(
              children: [
                _buildMessageList(),
                // Position FAB above input field like WhatsApp
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: _buildScrollToBottomFAB(colorScheme),
                ),
              ],
            ),
          ),
          _buildUserInput(colorScheme),
        ],
      ),
      floatingActionButton: null, // Remove default FAB position
    );
  }

  PreferredSizeWidget _buildAppBar(ColorScheme colorScheme) {
    return AppBar(
      elevation: 0,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: colorScheme.onSurface),
        onPressed: () => Navigator.pop(context),
      ),
      title: SlideTransition(
        position: _headerSlideAnimation,
        child: Row(
          children: [
            Hero(
              tag: 'avatar_${widget.receiverID}',
              child: CircleAvatar(
                radius: 18,
                backgroundColor: colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.receiveEmail.split('@')[0],
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Online',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        SlideTransition(
          position: _headerSlideAnimation,
          child: Container(
            margin: EdgeInsets.only(right: 8),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.translate,
                  color: colorScheme.primary,
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  'AUTO',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.more_vert, color: colorScheme.onSurface),
          onPressed: () {
            // Add more options here
          },
        ),
      ],
    );
  }

  Widget _buildTranslationBanner(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.05),
            colorScheme.secondary.withOpacity(0.05),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome,
            color: colorScheme.primary,
            size: 16,
          ),
          SizedBox(width: 8),
          Text(
            'Messages are automatically translated',
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    final senderID = _authService.getCurrentUser()?.uid;
    
    // Check if user is authenticated
    if (senderID == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off,
              color: Colors.orange,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'User not authenticated',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back),
              label: Text('Go Back'),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(widget.receiverID, senderID),
      builder: (context, snapshot) {
        print('StreamBuilder state: ${snapshot.connectionState}');
        print('Has error: ${snapshot.hasError}');
        print('Error: ${snapshot.error}');
        print('Has data: ${snapshot.hasData}');
        if (snapshot.hasData) {
          print('Doc count: ${snapshot.data!.docs.length}');
        }

        if (snapshot.hasError) {
          print('StreamBuilder error: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                SizedBox(height: 16),
                Text(
                  'Error loading messages',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '${snapshot.error}',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => setState(() {}),
                  icon: Icon(Icons.refresh),
                  label: Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Show loading only for the initial load
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Loading messages...',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    print('Debug: receiverID = ${widget.receiverID}');
                    print('Debug: senderID = $senderID');
                    print('Debug: receiveEmail = ${widget.receiveEmail}');
                  },
                  child: Text('Debug Info'),
                ),
              ],
            ),
          );
        }

        // Handle case where there's no data yet
        if (!snapshot.hasData || snapshot.data == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 64,
                ),
                SizedBox(height: 16),
                Text(
                  'No messages yet',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Start the conversation!',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        final docs = snapshot.data!.docs;
        
        // Show empty state if no messages
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 64,
                ),
                SizedBox(height: 16),
                Text(
                  'No messages yet',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Start the conversation!',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }
        
        // Mark that initial messages have loaded and scroll to bottom only once
        if (!_hasLoadedInitialMessages) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _hasLoadedInitialMessages = true;
            });
            // Only auto-scroll on initial load
            if (_scrollController.hasClients) {
              _scrollToBottom(animated: false);
            }
          });
        }
        
        // Only auto-scroll when sending a message or if user is already at bottom
        if (_shouldAutoScroll) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollToBottom();
            }
          });
        } else if (_hasLoadedInitialMessages && _scrollController.hasClients) {
          // Check if user is already at the bottom (within 100px)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              final isAtBottom = _scrollController.offset >= 
                  _scrollController.position.maxScrollExtent - 100;
              
              // Only auto-scroll if user is already at bottom
              if (isAtBottom) {
                _scrollToBottom();
              }
            }
          });
        }

        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(vertical: 8),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            try {
              return _buildMessageItem(docs[index], index == docs.length - 1);
            } catch (e) {
              print('Error building message item: $e');
              return Container(
                margin: EdgeInsets.all(8),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Error loading message: $e',
                  style: TextStyle(color: Colors.red),
                ),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc, bool isLastMessage) {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      
      if (data == null) {
        return Container(
          margin: EdgeInsets.all(8),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Message data is null',
            style: TextStyle(color: Colors.orange),
          ),
        );
      }

      final currentUserID = _authService.getCurrentUser()?.uid;
      if (currentUserID == null) {
        return Container(
          margin: EdgeInsets.all(8),
          child: Text('User not authenticated'),
        );
      }

      final isCurrentUser = data["senderID"] == currentUserID;
      final message = data["message"]?.toString() ?? '';
      
      if (message.isEmpty) {
        return Container(
          margin: EdgeInsets.all(8),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Empty message',
            style: TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      }
      
      // Check if message was translated
      final isTranslated = data.containsKey('originalMessage') && 
                          data['originalMessage'] != null &&
                          data['originalMessage'].toString().isNotEmpty &&
                          data['originalMessage'] != data['message'];

      return AnimatedContainer(
        duration: Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: ChatBubble(
          isCurrentUser: isCurrentUser,
          message: message,
          timestamp: _getTimestamp(data),
          isTranslated: isTranslated,
          originalMessage: data["originalMessage"]?.toString(),
          originalLanguage: data["senderLanguage"]?.toString(),
          translatedLanguage: data["receiverLanguage"]?.toString(),
          isDelivered: true,
          isRead: !isCurrentUser,
          onLongPress: () => _showMessageOptions(data),
          onTap: () {
            if (isTranslated) {
              _showTranslationDetails(data);
            }
          },
        ),
      );
    } catch (e) {
      print('Error in _buildMessageItem: $e');
      return Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Error loading message',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '$e',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }
  }

  DateTime? _getTimestamp(Map<String, dynamic> data) {
    try {
      if (data.containsKey("timestamp") && data["timestamp"] != null) {
        return (data["timestamp"] as Timestamp).toDate();
      }
    } catch (e) {
      print('Error parsing timestamp: $e');
    }
    return null;
  }

  void _showMessageOptions(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(Icons.copy),
              title: Text('Copy message'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: data["message"]));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Message copied')),
                );
              },
            ),
            if (data.containsKey('originalMessage'))
              ListTile(
                leading: Icon(Icons.translate),
                title: Text('Show translation details'),
                onTap: () {
                  Navigator.pop(context);
                  _showTranslationDetails(data);
                },
              ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showTranslationDetails(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.translate, color: Theme.of(context).colorScheme.primary),
            SizedBox(width: 8),
            Text('Translation Details'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTranslationSection(
              'Original',
              data['originalMessage'],
              data['senderLanguage']?.toString().toUpperCase() ?? 'AUTO',
            ),
            SizedBox(height: 16),
            _buildTranslationSection(
              'Translated',
              data['message'],
              data['receiverLanguage']?.toString().toUpperCase() ?? 'AUTO',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationSection(String title, String text, String language) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                language,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Text(text),
        ),
      ],
    );
  }

  Widget _buildUserInput(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.only(bottom: 16, top: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Use the existing MyTextField component
            Expanded(
              child: MyTextField(
                controller: _messageController,
                hintText: "Type a message...",
                obscureText: false,
                focusNode: _focusNode,
              ),
            ),
            
            // Enhanced send button
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: 25),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isTyping && !_isSending
                      ? [colorScheme.primary, colorScheme.secondary]
                      : [Colors.grey, Colors.grey[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: _isTyping && !_isSending
                    ? [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: _isTyping && !_isSending ? _sendMessage : null,
                  child: Container(
                    width: 48,
                    height: 48,
                    child: _isSending
                        ? Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          )
                        : Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollToBottomFAB(ColorScheme colorScheme) {
    return ScaleTransition(
      scale: _fabAnimation,
      child: Container(
        width: 36, // Smaller size like WhatsApp
        height: 36,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: _scrollToBottom,
            child: Icon(
              Icons.keyboard_arrow_down,
              color: colorScheme.onSurface.withOpacity(0.7),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}