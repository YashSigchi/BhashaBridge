import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/components/chat_bubble.dart';
import 'package:myapp/components/my_textfield.dart';
import 'package:myapp/services/auth/auth_service.dart';
import 'package:myapp/services/chat/chat_service.dart';

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

class _ChatPageState extends State<ChatPage> {
  //text controller
  final TextEditingController _messageController = TextEditingController();

  //chat & auth services
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  //for textfield focus
  FocusNode myFocusNode = FocusNode();
  
  //loading state for message sending
  bool _isSending = false;

  @override
  void initState() {
    super.initState();

    //add listener to focus mode
    myFocusNode.addListener((){
      if(myFocusNode.hasFocus){
        //cause a delay so that keyboard has time to show up
        //then amount of remaining space will be calculated,
        // then scroll down
        Future.delayed(
          const Duration(milliseconds: 500),
          ()=> scrollDown(),
        );
      }
    });

    // wait a bit for listview to be built, then scroll to bottom
    Future.delayed(
      const Duration(milliseconds: 500),
      ()=>scrollDown(),
    );
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  //scroll controller
  final ScrollController _scrollController = ScrollController();
  void scrollDown(){
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1), 
      curve: Curves.fastOutSlowIn,
    );
  }

  //send message with translation
  void sendMessage() async {
    //if there is something inside the text field
    if(_messageController.text.isNotEmpty && !_isSending){
      setState(() {
        _isSending = true;
      });

      String messageText = _messageController.text;
      //clear text controller immediately for better UX
      _messageController.clear();

      try {
        //send message with automatic translation
        await _chatService.sendMessage(widget.receiverID, messageText);
        
        //scroll down after sending
        scrollDown();
      } catch (e) {
        print('Error sending message: $e');
        //show error message to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        //restore message text if sending failed
        _messageController.text = messageText;
      } finally {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiveEmail),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0, 
        actions: [
          // Show translation indicator
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.translate,
                  color: Colors.blue,
                  size: 18,
                ),
                SizedBox(width: 4),
                Text(
                  'Auto',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Translation info banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            color: Colors.blue[50],
            child: Text(
              'Messages are automatically translated between languages',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue[700],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // display all messages
          Expanded(
            child: _buildMessageList(),
          ),
          // user input
          _buildUserInput(),
        ],
      ),
    );
  }

  // build message list
  Widget _buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;

    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiverID, senderID),
      builder: (context, snapshot) {
        // errors
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              "Error loading messages", 
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // return list view
        return ListView(
          controller: _scrollController,
          children: snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  // build message item
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    //is current user
    bool isCurrentUser = data["senderID"] == _authService.getCurrentUser()!.uid;

    //align msg to right if sender is current user, otherwise left
    var alignment = 
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    
    // Check if message was translated
    bool isTranslated = data.containsKey('originalMessage') && 
                       data['originalMessage'] != data['message'] &&
                       data['originalMessage'].toString().isNotEmpty;
    
    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment:
          isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Show original message first (for current user or if different from translated)
          if (isTranslated)
            Column(
              crossAxisAlignment:
                isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Language indicator for original message
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 2.0),
                  child: Text(
                    'Original',
                    //'📝 Original (${data['senderLanguage']?.toString().toUpperCase() ?? 'AUTO'})',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Original message bubble with different styling
                Container(
                  decoration: BoxDecoration(
                    color: isCurrentUser 
                        ? Colors.grey[300] 
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!, width: 1),
                  ),
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(vertical: 2.5, horizontal: 25),
                  child: Text(
                    data["originalMessage"],
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                SizedBox(height: 4), // Small gap between messages
              ],
            ),
          
          // Show translated message second (or only message if not translated)
          Column(
            crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // Translation indicator
              if (isTranslated)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 2.0),
                  child: Text(
                    '🌐 Translated to ${data['receiverLanguage']?.toString().toUpperCase() ?? 'AUTO'}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blue[600],
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              
              // Translated message bubble (or original if no translation)
              ChatBubble(
                isCurrentUser: isCurrentUser, 
                message: data["message"],
              ),
            ],
          ),
          
          SizedBox(height: 12), // Gap between different message groups
        ],
      ),
    );
  }

  // Show original message dialog
  void _showOriginalMessage(String translatedMessage, String originalMessage, String originalLanguage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Original Message'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Original (${originalLanguage.toUpperCase()}):',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              SizedBox(height: 4),
              Text(originalMessage),
              SizedBox(height: 12),
              Text(
                'Translated:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              SizedBox(height: 4),
              Text(translatedMessage),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // build message input
  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40.0),
      child: Row(
        children: [
          // textfield should take up most of the space
          Expanded(
            child: MyTextField(
              controller: _messageController,
              hintText: "Type a message...",
              obscureText: false,
              focusNode: myFocusNode,
            ),
          ),
          // send button
          Container(
            decoration: BoxDecoration(
              color: _isSending ? Colors.grey : Colors.green,
              shape: BoxShape.circle,
            ),
            margin: const EdgeInsets.only(right: 25),
            child: IconButton(
              onPressed: _isSending ? null : sendMessage,
              icon: _isSending 
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(
                    Icons.arrow_upward,
                    color: Colors.white,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}