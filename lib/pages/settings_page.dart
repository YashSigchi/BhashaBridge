import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/themes/theme_provider.dart';
import 'package:myapp/services/auth/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/pages/login_page.dart'; // Adjust path as needed

// Import the new pages (you'll need to create these)
import 'package:myapp/pages/profile_page.dart';
import 'package:myapp/pages/about_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  
void logout() {
  //get auth service
  final auth = AuthService();
  auth.signOut();
  
  // Navigate to login page and remove all previous routes
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => LoginPage(onTap: () {})), // Empty function
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
    _loadUserSettings();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update setting'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select Language',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _languages.length,
                itemBuilder: (context, index) {
                  final entry = _languages.entries.elementAt(index);
                  final langCode = entry.key;
                  final langData = entry.value;
                  final isSelected = langCode == _selectedLanguage;

                  return ListTile(
                    leading: Text(
                      langData['flag']!,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(langData['name']!),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).primaryColor,
                          )
                        : null,
                    selected: isSelected,
                    onTap: () {
                      setState(() {
                        _selectedLanguage = langCode;
                      });
                      _updateUserSetting('language', langCode);
                      Navigator.pop(context);
                    },
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
      title: const Text("Sign Out"),
      content: const Text("Are you sure you want to sign out?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            logout(); // Call the logout function instead of _authService.signOut()
          },
          child: const Text(
            "Sign Out",
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: trailing,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
  }) {
    return _buildSettingTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: CupertinoSwitch(
        value: value,
        onChanged: (newValue) {
          onChanged(newValue);
          _updateUserSetting(settingKey, newValue);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: const Text("Settings"),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Settings
            _buildSectionHeader("App Settings"),
            _buildSwitchTile(
              icon: Icons.dark_mode,
              title: "Dark Mode",
              subtitle: "Switch between light and dark theme",
              value: Provider.of<ThemeProvider>(context).isDarkMode,
              onChanged: (value) {
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
              },
              settingKey: 'darkMode',
            ),
            _buildSettingTile(
              icon: Icons.language,
              title: "Language",
              subtitle: _languages[_selectedLanguage]!['name'],
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_languages[_selectedLanguage]!['flag']!),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: _showLanguageSelector,
            ),

            // Notification Settings
            _buildSectionHeader("Notifications"),
            _buildSwitchTile(
              icon: Icons.notifications,
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
              icon: Icons.volume_up,
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
              icon: Icons.vibration,
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

            // Account Settings
            _buildSectionHeader("Account"),
            _buildSettingTile(
              icon: Icons.person,
              title: "Profile",
              subtitle: "Edit your profile information",
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),

            // Support
            _buildSectionHeader("Support"),
            _buildSettingTile(
              icon: Icons.info,
              title: "About",
              subtitle: "App version and information",
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutPage()),
                );
              },
            ),
            _buildSettingTile(
              icon: Icons.logout,
              title: "Sign Out",
              subtitle: "Sign out from your account",
              trailing: const Icon(Icons.chevron_right),
              onTap: _logout,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}