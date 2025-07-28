import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderID;
  final String senderEmail;
  final String receiverID;
  final String message;
  final String? originalMessage; // Store original message before translation
  final String? senderLanguage;
  final String? receiverLanguage;
  final Timestamp timestamp;

  Message({
    required this.senderID,
    required this.senderEmail,
    required this.receiverID,
    required this.message,
    this.originalMessage,
    this.senderLanguage,
    this.receiverLanguage,
    required this.timestamp,
  });

  // Convert to a map
  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderEmail': senderEmail,
      'receiverID': receiverID,
      'message': message,
      'originalMessage': originalMessage ?? message,
      'senderLanguage': senderLanguage ?? 'en',
      'receiverLanguage': receiverLanguage ?? 'en',
      'timestamp': timestamp,
    };
  }

  // Create from Firestore document
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderID: map['senderID'] ?? '',
      senderEmail: map['senderEmail'] ?? '',
      receiverID: map['receiverID'] ?? '',
      message: map['message'] ?? '',
      originalMessage: map['originalMessage'],
      senderLanguage: map['senderLanguage'],
      receiverLanguage: map['receiverLanguage'],
      timestamp: map['timestamp'] ?? Timestamp.now(),
    );
  }
}