import 'package:flutter/material.dart';
import 'package:BhashaBridge/pages/home_page.dart';
import 'package:BhashaBridge/pages/image_translate.dart';
import 'package:BhashaBridge/pages/settings_page.dart';
import 'package:BhashaBridge/pages/translator_page.dart';
import 'package:BhashaBridge/services/auth/auth_service.dart';

class MyDrawer extends StatefulWidget {
  final String? currentRoute;
  
  const MyDrawer({super.key, this.currentRoute});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  int _selectedIndex = 0;
  bool _isExpanded = false;

  // In your MyDrawer class, update the _menuItems list:
final List<DrawerMenuItem> _menuItems = [
  DrawerMenuItem(
    title: 'Home',
    icon: Icons.home_rounded,
    activeIcon: Icons.home,
    index: 0,
    route: '/home',
    page: () => HomePage(),
  ),
  DrawerMenuItem(
    title: 'Translator',
    icon: Icons.translate_rounded,
    activeIcon: Icons.translate,
    index: 1,
    route: '/translator',
    page: () => TranslatorPage(),
  ),
  DrawerMenuItem(
    title: 'Settings',
    icon: Icons.settings_rounded,
    activeIcon: Icons.settings,
    index: 2,
    route: '/settings', // Add this route back
    page: () => SettingsPage(),
  ),
];

  @override
  void initState() {
    super.initState();
    
    // Set selected index based on current route
    if (widget.currentRoute != null) {
      final currentItem = _menuItems.firstWhere(
        (item) => item.route != null && item.route == widget.currentRoute,
        orElse: () => _menuItems[0],
      );
      _selectedIndex = currentItem.index;
    }
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.logout_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Sign Out',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to sign out?',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                final auth = AuthService();
                auth.signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  // Update the _navigateToPage method:
void _navigateToPage(DrawerMenuItem item) {
  // Don't navigate if already on the same page
  if (item.route != null && widget.currentRoute == item.route) {
    Navigator.pop(context);
    return;
  }
  
  setState(() {
    _selectedIndex = item.index;
  });
  
  Navigator.pop(context); // Close drawer first
    
  // For Settings page, use push instead of pushReplacement
  if (item.title == 'Settings') {
    Navigator.push(
      context,
      PageRouteBuilder(
        settings: RouteSettings(name: item.route),
        pageBuilder: (context, animation, secondaryAnimation) => item.page(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
      ),
    );
  } else {
    // For other pages, use pushReplacement
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        settings: RouteSettings(name: item.route),
        pageBuilder: (context, animation, secondaryAnimation) => item.page(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.background,
              colorScheme.background.withOpacity(0.95),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(5, 0),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Avatar with glow effect
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.primary.withOpacity(0.7),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.chat_bubble_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // App Title
                      Text(
                        'ChatApp',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Stay Connected',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface.withOpacity(0.6),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Menu Items
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _menuItems.length,
                  itemBuilder: (context, index) {
                    final item = _menuItems[index];
                    final isSelected = _selectedIndex == item.index;
                    
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _navigateToPage(item),
                            borderRadius: BorderRadius.circular(16),
                            splashColor: colorScheme.primary.withOpacity(0.1),
                            highlightColor: colorScheme.primary.withOpacity(0.05),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: isSelected
                                    ? colorScheme.primary.withOpacity(0.1)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? colorScheme.primary.withOpacity(0.3)
                                      : Colors.transparent,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: isSelected
                                          ? colorScheme.primary
                                          : colorScheme.primary.withOpacity(0.1),
                                    ),
                                    child: Icon(
                                      isSelected ? item.activeIcon : item.icon,
                                      color: isSelected
                                          ? Colors.white
                                          : colorScheme.primary,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? colorScheme.primary
                                            : colorScheme.onSurface,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: colorScheme.primary,
                                      size: 16,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Bottom Section
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Divider
                      Container(
                        height: 1,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              colorScheme.onSurface.withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      
                      // Logout Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: logout,
                          borderRadius: BorderRadius.circular(16),
                          splashColor: Colors.red.withOpacity(0.1),
                          highlightColor: Colors.red.withOpacity(0.05),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.red.withOpacity(0.1),
                                  ),
                                  child: const Icon(
                                    Icons.logout_rounded,
                                    color: Colors.red,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Text(
                                    'Sign Out',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.red,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.red,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DrawerMenuItem {
  final String title;
  final IconData icon;
  final IconData activeIcon;
  final int index;
  final String? route;  // Made optional with ?
  final Widget Function() page;

  DrawerMenuItem({
    required this.title,
    required this.icon,
    required this.activeIcon,
    required this.index,
    this.route,  // Made optional (removed required)
    required this.page,
  });
}