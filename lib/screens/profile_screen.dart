import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'society_selection_screen.dart';

class ProfilePage extends StatefulWidget {
  static const String id = "profileScreen";

  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;

  Future<void> _updateField(String field, String currentValue, String title) async {
    TextEditingController controller = TextEditingController(text: currentValue);
    String? newValue = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $title', style: const TextStyle(color: Color(0xFF3B0D11))),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter $title'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B0D11)),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (newValue != null && newValue.trim().isNotEmpty && newValue != currentValue) {
      await FirebaseFirestore.instance.collection('users').doc(user?.uid).update({
        field: newValue.trim(),
      });
      _checkProfileCompletion();
    }
  }

  Future<void> _checkProfileCompletion() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      final displayname = data['displayname'] ?? '';
      final society = data['society'] ?? '';
      final dob = data['dob'] ?? '';
      if (displayname.isNotEmpty && society.isNotEmpty && dob.isNotEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(user?.uid).update({
          'profile_completed': true,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Profile', style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: const Color(0xFF3B0D11),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF3B0D11)));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};

          String avatarUrl = userData['avatar'] ?? '';
          String displayName = userData['displayname'] ?? '';
          String society = userData['society'] ?? '';
          String dob = userData['dob'] ?? '';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 20),
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                      child: avatarUrl.isEmpty ? const Icon(Icons.person, size: 50, color: Colors.grey) : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          // Implement photo upload logic here
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Avatar upload not implemented yet')));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFB8B24),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildProfileTile('Display Name', displayName, 'displayname'),
              _buildProfileTile('Society', society, 'society'),
              _buildProfileTile('Date of Birth', dob, 'dob'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileTile(String title, String subtitle, String field) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        subtitle: Text(
          subtitle.isNotEmpty ? subtitle : 'Not provided',
          style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.edit, color: Color(0xFFFB8B24)),
        onTap: () async {
          if (field == 'society') {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SocietySelectionPage(currentSociety: subtitle)),
            );
            _checkProfileCompletion();
          } else {
            _updateField(field, subtitle, title);
          }
        },
      ),
    );
  }
}
