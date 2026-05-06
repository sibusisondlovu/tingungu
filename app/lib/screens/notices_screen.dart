import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NoticesScreen extends StatelessWidget {
  const NoticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text('Notices', style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: const Color(0xFF3B0D11),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('notices').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFB8B24)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B0D11).withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No new notifications',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3B0D11)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'We will notify you when there is something new.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final notices = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notices.length,
            itemBuilder: (context, index) {
              final notice = notices[index].data() as Map<String, dynamic>;
              final title = notice['title'] ?? 'Notice';
              final message = notice['message'] ?? '';
              final date = notice['createdAt'] != null 
                  ? (notice['createdAt'] as Timestamp).toDate() 
                  : DateTime.now();

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                color: Colors.white,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFB8B24).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.campaign, color: Color(0xFFFB8B24)),
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF3B0D11)),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(message, style: TextStyle(color: Colors.grey[800], height: 1.4)),
                      const SizedBox(height: 12),
                      Text(
                        "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}",
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
