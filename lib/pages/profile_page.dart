import 'package:flutter/material.dart';
import 'package:BhashaBridge/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  
  bool _isLoading = true;
  String _userEmail = '';
  String _userName = '';
  String _userStatus = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = _authService.getCurrentUser();
      if (user != null) {
        _userEmail = user.email ?? '';
        
        final doc = await _firestore.collection('Users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          _userName = data['name'] ?? '';
          _userStatus = data['status'] ?? 'Hey there! I am using this chat app.';
        }
        
        _nameController.text = _userName;
        _statusController.text = _userStatus;
      }
    } catch (e) {
      print('Error loading profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    try {
      final user = _authService.getCurrentUser();
      if (user != null) {
        await _firestore.collection('Users').doc(user.uid).set({
          'name': _nameController.text.trim(),
          'status': _statusController.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        setState(() {
          _userName = _nameController.text.trim();
          _userStatus = _statusController.text.trim();
        });
        
        // Navigate back to settings page after successful update
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update profile'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _updateProfile,
            child: Text(
              'Save',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Picture Section
                  Container(
                    margin: const EdgeInsets.only(bottom: 32),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            _userName.isNotEmpty ? _userName[0].toUpperCase() : _userEmail[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _userName.isNotEmpty ? _userName : 'User',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _userEmail,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Name Field
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
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
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Display Name',
                        prefixIcon: Icon(Icons.person, color: Theme.of(context).primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                      ),
                    ),
                  ),
                  
                  // Status Field
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
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
                    child: TextField(
                      controller: _statusController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Status',
                        prefixIcon: Icon(Icons.info, color: Theme.of(context).primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                      ),
                    ),
                  ),
                  
                  // Email Field (Read-only)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
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
                    child: TextField(
                      controller: TextEditingController(text: _userEmail),
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email, color: Colors.grey[600]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Update Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Update Profile',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _statusController.dispose();
    super.dispose();
  }
}