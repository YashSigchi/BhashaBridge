import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:BhashaBridge/themes/theme_provider.dart';
import 'package:BhashaBridge/services/auth/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:BhashaBridge/pages/login_page.dart';
import 'package:BhashaBridge/pages/profile_page.dart';
import 'package:BhashaBridge/pages/about_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  void logout() {
    final auth = AuthService();
    auth.signOut();
    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage(onTap: () {})),
      (route) => false,
    );
  }

  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String _selectedLanguage = 'en';
  bool _isLoading = true;
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  final Map<String, Map<String, String>> _languages = {
    'en': {'name': 'English', 'flag': '🇺🇸', 'code': 'EN'},
    'ta': {'name': 'Tamil', 'flag': '🇮🇳', 'code': 'TA'},
    'hi': {'name': 'Hindi', 'flag': '🇮🇳', 'code': 'HI'},
    'ar': {'name': 'Arabic', 'flag': '🇸🇦', 'code': 'AR'},
    'as': {'name': 'Assamese', 'flag': '🇮🇳', 'code': 'AS'},
    'bn': {'name': 'Bengali', 'flag': '🇮🇳', 'code': 'BN'},
    'bho': {'name': 'Bhojpuri', 'flag': '🇮🇳', 'code': 'BHO'},
    'brx': {'name': 'Bodo', 'flag': '🇮🇳', 'code': 'BRX'},
    'zh': {'name': 'Chinese', 'flag': '🇨🇳', 'code': 'ZH'},
    'doi': {'name': 'Dogri', 'flag': '🇮🇳', 'code': 'DOI'},
    'nl': {'name': 'Dutch', 'flag': '🇳🇱', 'code': 'NL'},
    'fr': {'name': 'French', 'flag': '🇫🇷', 'code': 'FR'},
    'de': {'name': 'German', 'flag': '🇩🇪', 'code': 'DE'},
    'gu': {'name': 'Gujarati', 'flag': '🇮🇳', 'code': 'GU'},
    'it': {'name': 'Italian', 'flag': '🇮🇹', 'code': 'IT'},
    'ja': {'name': 'Japanese', 'flag': '🇯🇵', 'code': 'JA'},
    'kn': {'name': 'Kannada', 'flag': '🇮🇳', 'code': 'KN'},
    'ks': {'name': 'Kashmiri', 'flag': '🇮🇳', 'code': 'KS'},
    'gom': {'name': 'Konkani', 'flag': '🇮🇳', 'code': 'GOM'},
    'ko': {'name': 'Korean', 'flag': '🇰🇷', 'code': 'KR'},
    'mai': {'name': 'Maithili', 'flag': '🇮🇳', 'code': 'MAI'},
    'ml': {'name': 'Malayalam', 'flag': '🇮🇳', 'code': 'ML'},
    'mni': {'name': 'Manipuri', 'flag': '🇮🇳', 'code': 'MNI'},
    'mr': {'name': 'Marathi', 'flag': '🇮🇳', 'code': 'MR'},
    'my': {'name': 'Myanmar', 'flag': '🇲🇲', 'code': 'MY'},
    'ne': {'name': 'Nepali', 'flag': '🇳🇵', 'code': 'NE'},
    'or': {'name': 'Odia', 'flag': '🇮🇳', 'code': 'OR'},
    'pl': {'name': 'Polish', 'flag': '🇵🇱', 'code': 'PL'},
    'pt': {'name': 'Portuguese', 'flag': '🇵🇹', 'code': 'PT'},
    'pa': {'name': 'Punjabi', 'flag': '🇮🇳', 'code': 'PA'},
    'ru': {'name': 'Russian', 'flag': '🇷🇺', 'code': 'RU'},
    'sa': {'name': 'Sanskrit', 'flag': '🇮🇳', 'code': 'SA'},
    'sat': {'name': 'Santali', 'flag': '🇮🇳', 'code': 'SAT'},
    'sd': {'name': 'Sindhi', 'flag': '🇮🇳', 'code': 'SD'},
    'si': {'name': 'Sinhala', 'flag': '🇱🇰', 'code': 'SI'},
    'es': {'name': 'Spanish', 'flag': '🇪🇸', 'code': 'ES'},
    'sv': {'name': 'Swedish', 'flag': '🇸🇪', 'code': 'SV'},
    'te': {'name': 'Telugu', 'flag': '🇮🇳', 'code': 'TE'},
    'th': {'name': 'Thai', 'flag': '🇹🇭', 'code': 'TH'},
    'tr': {'name': 'Turkish', 'flag': '🇹🇷', 'code': 'TR'},
    'ur': {'name': 'Urdu', 'flag': '🇵🇰', 'code': 'UR'},
    'vi': {'name': 'Vietnamese', 'flag': '🇻🇳', 'code': 'VI'},
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserSettings();
  }

  void _initializeAnimations() {
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
    super.dispose();
  }

  Future<void> _loadUserSettings() async {
    try {
      final user = _authService.getCurrentUser();
      if (user != null) {
        final doc = await _firestore.collection('Users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          setState(() {
            _selectedLanguage = data['language'] ?? 'en';
            _notificationsEnabled = data['notificationsEnabled'] ?? true;
            _soundEnabled = data['soundEnabled'] ?? true;
            _vibrationEnabled = data['vibrationEnabled'] ?? true;
          });
        }
      }
    } catch (e) {
      print('Error loading user settings: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserSetting(String key, dynamic value) async {
    try {
      final user = _authService.getCurrentUser();
      if (user != null) {
        await _firestore.collection('Users').doc(user.uid).set({
          key: value,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error updating user setting: $e');
      _showSnackBar('Failed to update setting', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError 
            ? Colors.red.shade600 
            : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primary.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.language_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Select Language',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            // Search bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search languages...',
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            // Language list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _languages.length,
                itemBuilder: (context, index) {
                  final entry = _languages.entries.elementAt(index);
                  final langCode = entry.key;
                  final langData = entry.value;
                  final isSelected = langCode == _selectedLanguage;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: isSelected 
                          ? Border.all(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                              width: 1,
                            )
                          : null,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            langData['flag']!,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      title: Text(
                        langData['name']!,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        langData['code']!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      trailing: isSelected
                          ? Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedLanguage = langCode;
                        });
                        _updateUserSetting('language', langCode);
                        Navigator.pop(context);
                        _showSnackBar('Language changed to ${langData['name']}');
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.logout_rounded,
                color: Colors.red,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "Sign Out",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to sign out?",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                logout();
              },
              child: const Text(
                "Sign Out",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 32, 20, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
    bool isDangerous = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (iconColor ?? Theme.of(context).colorScheme.primary)
                        .withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? Theme.of(context).colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: isDangerous 
                              ? Colors.red 
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 16),
                  trailing,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required String settingKey,
    Color? iconColor,
  }) {
    return _buildSettingTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      iconColor: iconColor,
      trailing: Transform.scale(
        scale: 0.8,
        child: CupertinoSwitch(
          value: value,
          activeColor: Theme.of(context).colorScheme.primary,
          trackColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
          thumbColor: Colors.white,
          onChanged: (newValue) {
            onChanged(newValue);
            _updateUserSetting(settingKey, newValue);
          },
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    final user = _authService.getCurrentUser();
    if (user == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.7),
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
                user.email?.isNotEmpty == true 
                    ? user.email![0].toUpperCase() 
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.email?.split('@')[0] ?? 'User',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: _buildAppBar(),
        body: Center(
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
                "Loading settings...",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserInfo(),
                
                _buildSectionHeader("Appearance", Icons.palette_rounded),
                _buildSwitchTile(
                  icon: Provider.of<ThemeProvider>(context).isDarkMode 
                      ? Icons.dark_mode_rounded 
                      : Icons.light_mode_rounded,
                  title: "Dark Mode",
                  subtitle: "Switch between light and dark theme",
                  value: Provider.of<ThemeProvider>(context).isDarkMode,
                  onChanged: (value) {
                    Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                  },
                  settingKey: 'darkMode',
                ),
                _buildSettingTile(
                  icon: Icons.language_rounded,
                  title: "Language",
                  subtitle: _languages[_selectedLanguage]!['name'],
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _languages[_selectedLanguage]!['flag']!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                      ),
                    ],
                  ),
                  onTap: _showLanguageSelector,
                ),

                _buildSectionHeader("Notifications", Icons.notifications_rounded),
                _buildSwitchTile(
                  icon: Icons.notifications_rounded,
                  title: "Push Notifications",
                  subtitle: "Receive notifications for new messages",
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                  settingKey: 'notificationsEnabled',
                ),
                _buildSwitchTile(
                  icon: Icons.volume_up_rounded,
                  title: "Notification Sound",
                  subtitle: "Play sound for new messages",
                  value: _soundEnabled,
                  onChanged: (value) {
                    setState(() {
                      _soundEnabled = value;
                    });
                  },
                  settingKey: 'soundEnabled',
                ),
                _buildSwitchTile(
                  icon: Icons.vibration_rounded,
                  title: "Vibration",
                  subtitle: "Vibrate for new messages",
                  value: _vibrationEnabled,
                  onChanged: (value) {
                    setState(() {
                      _vibrationEnabled = value;
                    });
                  },
                  settingKey: 'vibrationEnabled',
                ),

                _buildSectionHeader("Account", Icons.person_rounded),
                _buildSettingTile(
                  icon: Icons.person_rounded,
                  title: "Profile",
                  subtitle: "Edit your profile information",
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const ProfilePage(),
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
                  },
                ),

                _buildSectionHeader("Support", Icons.help_rounded),
                _buildSettingTile(
                  icon: Icons.info_rounded,
                  title: "About",
                  subtitle: "App version and information",
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const AboutPage(),
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
                  },
                ),
                
                const SizedBox(height: 20),
                
                _buildSettingTile(
                  icon: Icons.logout_rounded,
                  title: "Sign Out",
                  subtitle: "Sign out from your account",
                  iconColor: Colors.red,
                  isDangerous: true,
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.red.withOpacity(0.6),
                  ),
                  onTap: _logout,
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
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
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Theme.of(context).colorScheme.background,
            ],
          ),
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).colorScheme.onSurface,
            size: 20,
          ),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.7),
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
            child: const Icon(
              Icons.settings_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "Settings",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      centerTitle: true,
    );
  }
}