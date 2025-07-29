import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:BhashaBridge/models/messsage.dart';
import 'package:BhashaBridge/services/translation/translation_services.dart';

class ChatService {
  //get instance of firestore & auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //get user stream
  Stream<List<Map<String,dynamic>>> getUsersStream(){
    return _firestore.collection("Users").snapshots().map((snapshot){
      return snapshot.docs.map((doc){
        final user = doc.data();
        
        // Ensure the document ID (uid) is included in the data
        user['uid'] = doc.id;
        
        // Debug: Print the user data to see what's being returned
        print("User data: $user");
        print("Name field: ${user['name']}");
        print("Email field: ${user['email']}");
        print("UID field: ${user['uid']}");
        
        return user;
      }).toList();
    });
  }

  // Get user's preferred language
  Future<String> getUserLanguage(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection("Users").doc(userId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data['language'] ?? 'en'; // Default to English if no language set
      }
      return 'en';
    } catch (e) {
      print('Error getting user language: $e');
      return 'en';
    }
  }

  //send messages with automatic translation
  Future<void> sendMessage(String receiverID, String message) async {
    try {
      //get current user info
      final String currentUserID = _auth.currentUser!.uid;
      final String currentUserEmail = _auth.currentUser!.email!;
      final Timestamp timestamp = Timestamp.now();

      // Get receiver's preferred language
      String receiverLanguage = await getUserLanguage(receiverID);
      
      // Get sender's preferred language (for storing original)
      String senderLanguage = await getUserLanguage(currentUserID);

      // Translate message to receiver's language
      String translatedMessage = message;
      if (receiverLanguage != 'en' && receiverLanguage != senderLanguage) {
        translatedMessage = await TranslationService.translateText(message, receiverLanguage);
        print('Original message: $message');
        print('Translated to $receiverLanguage: $translatedMessage');
      }

      //create a new message with both original and translated text
      Message newMessage = Message(
        senderID: currentUserID, 
        senderEmail: currentUserEmail, 
        receiverID: receiverID, 
        message: translatedMessage, // Store translated message
        originalMessage: message, // Store original message
        senderLanguage: senderLanguage,
        receiverLanguage: receiverLanguage,
        timestamp: timestamp
      );

      //construct chat room ID for the two users (sorted to ensure uniqueness)
      List<String> ids = [currentUserID, receiverID];
      ids.sort(); // sort the ids
      String chatRoomID = ids.join('_');

      //add new message to database
      await _firestore
          .collection("chat_rooms")
          .doc(chatRoomID)
          .collection("messages")
          .add(newMessage.toMap());

    } catch (e) {
      print('Error sending message: $e');
      // Fallback: send original message without translation
      await _sendOriginalMessage(receiverID, message);
    }
  }

  // Fallback method to send original message if translation fails
  Future<void> _sendOriginalMessage(String receiverID, String message) async {
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderID: currentUserID, 
      senderEmail: currentUserEmail, 
      receiverID: receiverID, 
      message: message, 
      originalMessage: message,
      senderLanguage: 'en',
      receiverLanguage: 'en',
      timestamp: timestamp
    );

    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');

    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());
  }

  //get messages
  Stream<QuerySnapshot> getMessages(String userID, String otherUserID){
    //construct a chatroom id for the two users
    List <String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }
}