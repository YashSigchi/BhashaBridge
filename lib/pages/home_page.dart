import 'package:flutter/material.dart';
import 'package:myapp/components/my_drawer.dart';
import 'package:myapp/components/user_tile.dart';
import 'package:myapp/pages/chat_page.dart';
import 'package:myapp/services/auth/auth_service.dart';
import 'package:myapp/services/chat/chat_service.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  //chat & auth service
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      drawer: const MyDrawer(),
      body: _buildUserList(),
    );
  }

  //build a list of users exception for the current logged in user
  Widget _buildUserList(){
    return StreamBuilder(
      stream: _chatService.getUsersStream(), 
      builder: (context, snapshot) {
        //error
        if(snapshot.hasError){
          print("Error in StreamBuilder: ${snapshot.error}");
          return const Text("Error loading users");
        }

        //loading..
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator());
        }

        //check if data is null or empty
        if(!snapshot.hasData || snapshot.data!.isEmpty){
          return const Text("No users found");
        }

        //return list view
        return ListView(
          children: snapshot.data!.map<Widget>((userData)=> _buildUserListItem(userData, context)).toList(),
        );
      }
    );
  }

  //build individual list title for user
  Widget _buildUserListItem(Map<String, dynamic> userData, BuildContext context){
    // Debug: Print userData to see what we're getting
    print("Building user item with data: $userData");
    
    //display all users except current user
    if(userData["email"] != _authService.getCurrentUser()!.email){
      
      // Get the display name with better handling
      String displayName;
      
      // First try to get the name field
      if (userData.containsKey("name") && userData["name"] != null && userData["name"].toString().trim().isNotEmpty) {
        displayName = userData["name"].toString().trim();
      }
      // Then try displayName field (if you have it)
      else if (userData.containsKey("displayName") && userData["displayName"] != null && userData["displayName"].toString().trim().isNotEmpty) {
        displayName = userData["displayName"].toString().trim();
      }
      // Finally fall back to email
      else {
        String email = userData["email"]?.toString() ?? "Unknown User";
        // Extract name part from email (everything before @)
        displayName = email.contains('@') ? email.split('@')[0] : email;
      }
      
      print("Display name for ${userData["email"]}: $displayName");
      
      return UserTile(
        text: displayName,
        onTap: (){
          //tapped on a user->go to chat page
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context)=> ChatPage(
                receiveEmail: userData["email"],
                receiverID: userData["uid"],
              ),
            ),
          );
        }
      );
    } else{
      return Container();
    }
  }
}