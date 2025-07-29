import 'package:flutter/material.dart';
import 'package:BhashaBridge/components/my_drawer.dart';
import 'package:BhashaBridge/components/user_tile.dart';
import 'package:BhashaBridge/pages/chat_page.dart';
import 'package:BhashaBridge/services/auth/auth_service.dart';
import 'package:BhashaBridge/services/chat/chat_service.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  //chat & auth service
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: _buildAppBar(),
      drawer: const MyDrawer(currentRoute: '/home'),
      // drawer: const MyDrawer(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              _buildSearchBar(),
              _buildOnlineStatus(),
              Expanded(child: _buildUserList()),
            ],
          ),
        ),
      ),
      // floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.background,
            ],
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.inversePrimary,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "Messages",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              _isSearchActive = !_isSearchActive;
              if (!_isSearchActive) {
                _searchController.clear();
                _searchQuery = '';
              }
            });
          },
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              _isSearchActive ? Icons.close_rounded : Icons.search_rounded,
              key: ValueKey(_isSearchActive),
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      height: _isSearchActive ? 80 : 0,
      child: _isSearchActive
          ? Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search conversations...",
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16,
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildOnlineStatus() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "Online now",
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        // Filter users based on search query
        List<Map<String, dynamic>> filteredUsers = snapshot.data!.where((userData) {
          if (_searchQuery.isEmpty) return true;
          
          String displayName = _getDisplayName(userData);
          String email = userData["email"]?.toString() ?? "";
          
          return displayName.toLowerCase().contains(_searchQuery) ||
                 email.toLowerCase().contains(_searchQuery);
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            return AnimatedContainer(
              duration: Duration(milliseconds: 300 + (index * 100)),
              curve: Curves.easeOutCubic,
              child: _buildUserListItem(filteredUsers[index], context, index),
            );
          },
        );
      },
    );
  }

  Widget _buildUserListItem(Map<String, dynamic> userData, BuildContext context, int index) {
    if (userData["email"] == _authService.getCurrentUser()!.email) {
      return const SizedBox.shrink();
    }

    String displayName = _getDisplayName(userData);
    String email = userData["email"]?.toString() ?? "Unknown";

    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 600 + (index * 100)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _navigateToChat(userData),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        _buildAvatar(displayName),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                email,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatar(String displayName) {
    return Hero(
      tag: "avatar_$displayName",
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.inversePrimary,
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            displayName.isNotEmpty ? displayName[0].toUpperCase() : "?",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Loading conversations...",
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: Colors.red.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Oops! Something went wrong",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Unable to load conversations",
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 60,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "No conversations yet",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Start chatting with someone!",
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildFloatingActionButton() {
  //   return FloatingActionButton.extended(
  //     onPressed: () {
  //       // Add functionality for starting new chat
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: const Text("New chat feature coming soon!"),
  //           backgroundColor: Theme.of(context).colorScheme.primary,
  //           behavior: SnackBarBehavior.floating,
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //         ),
  //       );
  //     },
  //     backgroundColor: Theme.of(context).colorScheme.primary,
  //     foregroundColor: Colors.white,
  //     elevation: 8,
  //     icon: const Icon(Icons.add_rounded),
  //     label: const Text(
  //       "New Chat",
  //       style: TextStyle(fontWeight: FontWeight.w600),
  //     ),
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(16),
  //     ),
  //   );
  // }

  String _getDisplayName(Map<String, dynamic> userData) {
    if (userData.containsKey("name") && 
        userData["name"] != null && 
        userData["name"].toString().trim().isNotEmpty) {
      return userData["name"].toString().trim();
    } else if (userData.containsKey("displayName") && 
               userData["displayName"] != null && 
               userData["displayName"].toString().trim().isNotEmpty) {
      return userData["displayName"].toString().trim();
    } else {
      String email = userData["email"]?.toString() ?? "Unknown User";
      return email.contains('@') ? email.split('@')[0] : email;
    }
  }

  void _navigateToChat(Map<String, dynamic> userData) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ChatPage(
          receiveEmail: userData["email"],
          receiverID: userData["uid"],
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = const Offset(1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.easeOutCubic;
          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}