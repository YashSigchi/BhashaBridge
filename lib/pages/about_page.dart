import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _appVersion = '';
  String _buildNumber = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _appVersion = '1.0.0';
        _buildNumber = '1';
        _isLoading = false;
      });
    }
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

  Widget _buildInfoTile({
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
        trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('Could not open link');
      }
    } catch (e) {
      _showSnackBar('Error opening link');
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    _showSnackBar('Copied to clipboard');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showCredits() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Credits'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Development Team',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text('• Lead Developer: Yash Sigchi'),
              const Text('• UI/UX Designer: Yash Sigchi'),
              const Text('• Backend Developer: Yash Sigchi'),
              const SizedBox(height: 16),
              const Text(
                'Special Thanks',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text('• Flutter Team for the amazing framework'),
              const Text('• Firebase for backend services'),
              const Text('• Open source community'),
              const SizedBox(height: 16),
              const Text(
                'Icon Credits',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text('• Icons from Material Design'),
              const Text('• Emoji flags from Unicode Consortium'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showBugReportDialog() {
    showDialog(
      context: context,
      builder: (context) => _BugReportDialog(
        onSubmit: (String bugText, String emailText) {
          _showSnackBar('Bug report submitted successfully! Thank you for your feedback.');
          // Here you would typically send the bug report to your backend
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Info Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Theme.of(context).primaryColor,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).primaryColor.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.chat,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'MyApp',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Connect with friends and family',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Version $_appVersion ($_buildNumber)',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // App Information
                  _buildSectionHeader('App Information'),
                  _buildInfoTile(
                    icon: Icons.info,
                    title: 'Version',
                    subtitle: '$_appVersion ($_buildNumber)',
                    trailing: IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      onPressed: () => _copyToClipboard('$_appVersion ($_buildNumber)'),
                    ),
                  ),
                  _buildInfoTile(
                    icon: Icons.update,
                    title: 'Check for Updates',
                    subtitle: 'Tap to check for new versions',
                    onTap: () {
                      _showSnackBar('You are using the latest version!');
                    },
                  ),
                  _buildInfoTile(
                    icon: Icons.bug_report,
                    title: 'Report a Bug',
                    subtitle: 'Help us improve the app',
                    onTap: _showBugReportDialog,
                  ),

                  // // Legal & Privacy
                  // _buildSectionHeader('Legal & Privacy'),
                  // _buildInfoTile(
                  //   icon: Icons.description,
                  //   title: 'Terms of Service',
                  //   subtitle: 'Read our terms and conditions',
                  //   onTap: () => _launchURL('https://myapp.com/terms'),
                  // ),
                  // _buildInfoTile(
                  //   icon: Icons.privacy_tip,
                  //   title: 'Privacy Policy',
                  //   subtitle: 'Learn how we protect your data',
                  //   onTap: () => _launchURL('https://myapp.com/privacy'),
                  // ),

                  // Credits
                  _buildSectionHeader('Credits'),
                  _buildInfoTile(
                    icon: Icons.people,
                    title: 'Credits',
                    subtitle: 'Meet the team behind the app',
                    onTap: _showCredits,
                  ),

                  // Social & Contact
                  _buildSectionHeader('Connect With Us'),
                  _buildInfoTile(
                    icon: Icons.email,
                    title: 'Contact Support',
                    subtitle: 'yash.sigchi2023@vitstudent.ac.in',
                    onTap: () => _copyToClipboard('yash.sigchi2023@vitstudent.ac.in'),
                  ),

                  // Social Media
                  // _buildSectionHeader('Follow Us'),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //   children: [
                  //     _buildSocialButton(
                  //       icon: Icons.facebook,
                  //       label: 'Facebook',
                  //       onTap: () => _launchURL('https://facebook.com/myapp'),
                  //     ),
                  //     _buildSocialButton(
                  //       icon: Icons.alternate_email,
                  //       label: 'Twitter',
                  //       onTap: () => _launchURL('https://twitter.com/myapp'),
                  //     ),
                  //     _buildSocialButton(
                  //       icon: Icons.camera_alt,
                  //       label: 'Instagram',
                  //       onTap: () => _launchURL('https://instagram.com/myapp'),
                  //     ),
                  //   ],
                  // ),

                  const SizedBox(height: 32),

                  // Footer
                  Center(
                    child: Column(
                      children: [
                        Text(
                          '© 2024 MyApp. All rights reserved.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Made with ❤️ using Flutter',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Column(
          children: [
            Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BugReportDialog extends StatefulWidget {
  final Function(String bugText, String emailText) onSubmit;
  
  const _BugReportDialog({required this.onSubmit});

  @override
  State<_BugReportDialog> createState() => _BugReportDialogState();
}

class _BugReportDialogState extends State<_BugReportDialog> {
  final TextEditingController _bugController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _bugController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Report a Bug'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Help us improve the app by reporting any bugs you encounter.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Your Email (Optional)',
                hintText: 'Enter your email for follow-up',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bugController,
              decoration: const InputDecoration(
                labelText: 'Bug Description *',
                hintText: 'Please describe the bug in detail...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.bug_report),
              ),
              maxLines: 5,
              minLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_bugController.text.trim().isEmpty) {
              _showSnackBar('Please describe the bug');
              return;
            }
            
            final bugText = _bugController.text.trim();
            final emailText = _emailController.text.trim();
            
            Navigator.pop(context);
            widget.onSubmit(bugText, emailText);
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}