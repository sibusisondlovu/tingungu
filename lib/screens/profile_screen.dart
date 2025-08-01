import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tingungu_app/utils/constants.dart';

import 'society_selection_screen.dart';

class ProfilePage extends StatefulWidget {
  static const String id = "profileScreen";

 const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Constants.primaryColor,
        iconTheme: IconThemeData(color: Colors.white), // makes the back icon white
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>?;

          return ListView(
            children: [
              SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('lib/assets/images/logo.png'),
              ),
              SizedBox(height: 20),
              _buildProfileTile(context, 'Name', userData?['name'] ?? '', 'name'),
              _buildProfileTile(context, 'Surname', userData?['surname'] ?? '', 'surname'),
              _buildProfileTile(context, 'Society', userData?['society'] ?? '', 'society'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileTile(BuildContext context, String title, String subtitle, String field) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle.isNotEmpty ? subtitle : 'Not provided'),
      trailing: Icon(Icons.edit, color: Constants.primaryColor),
      onTap: () {
        if (field == 'society') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SocietySelectionPage(
                currentSociety: subtitle,
              ),
            ),
          );
        }
      },
    );
  }
}
