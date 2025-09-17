import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SchoolContactsPage extends StatefulWidget {
  const SchoolContactsPage({super.key});

  @override
  State<SchoolContactsPage> createState() => _SchoolContactsPageState();
}

class _SchoolContactsPageState extends State<SchoolContactsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedDepartment = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تواصل معنا'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade800, Colors.indigo.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إدارة المدرسة',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Reach out to our team members',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            // Department Filter Dropdown
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('schoolcontacts').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox();
                }

                // Get all unique departments
                final departments = <String>{'All'};
                for (var doc in snapshot.data!.docs) {
                  final department =
                      (doc.data() as Map<String, dynamic>)['department'] ??
                          'General';
                  departments.add(department);
                }

                return DropdownButtonFormField<String>(
                  value: _selectedDepartment,
                  decoration: InputDecoration(
                    labelText: 'اختر الإدارة',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  items: departments.map((department) {
                    return DropdownMenuItem<String>(
                      value: department,
                      child: Text(department),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDepartment = value ?? 'All';
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 16),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('schoolcontacts')
                    .orderBy('position')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No contacts available'));
                  }

                  // Filter by selected department
                  final filteredDocs = snapshot.data!.docs.where((doc) {
                    if (_selectedDepartment == 'All') return true;
                    final data = doc.data() as Map<String, dynamic>;
                    return data['department'] == _selectedDepartment;
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      var contactItem = filteredDocs[index];
                      var data = contactItem.data() as Map<String, dynamic>;

                      return _buildContactCard(
                        name: data['name'] ?? 'No Name',
                        position: data['position'] ?? 'Staff',
                        email: data['email'] ?? '',
                        phone: data['phone'] ?? '',
                        imageUrl: data['imageUrl'] ?? '',
                        department: data['department'] ?? 'General',
                      );
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

  Widget _buildContactCard({
    required String name,
    required String position,
    required String email,
    required String phone,
    required String imageUrl,
    required String department,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: Colors.indigo.shade100,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade200,
                    child:
                        const Icon(Icons.person, size: 40, color: Colors.grey),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade200,
                    child:
                        const Icon(Icons.person, size: 40, color: Colors.grey),
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Contact Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    position,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.indigo.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    department,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Contact Buttons with Font Awesome Icons
                  Row(
                    children: [
                      if (phone.isNotEmpty)
                        IconButton(
                          icon: const FaIcon(FontAwesomeIcons.phone, size: 16),
                          color: Colors.indigo,
                          onPressed: () async {
                            final Uri url = Uri(scheme: "tel", path: phone);
                            await launchUrl(url);
                          },
                          // onPressed: () => _launchPhone(phone),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      if (phone.isNotEmpty) const SizedBox(width: 12),
                      if (email.isNotEmpty)
                        IconButton(
                          icon:
                              const FaIcon(FontAwesomeIcons.envelope, size: 16),
                          color: Colors.indigo,
                          onPressed: () {
                            String? encodeQueryParameters(
                                Map<String, String> params) {
                              return params.entries
                                  .map((MapEntry<String, String> e) =>
                                      '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
                                  .join('&');
                            }

// ···
                            final Uri emailLaunchUri = Uri(
                              scheme: 'mailto',
                              path: email,
                              query: encodeQueryParameters(<String, String>{
                                'subject':
                                    'استفسار',
                              }),
                            );

                            launchUrl(emailLaunchUri);
                          },
                          // onPressed: () => _launchEmail(email),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      if (email.isNotEmpty) const SizedBox(width: 12),
                      IconButton(
                        icon:
                            const FaIcon(FontAwesomeIcons.circleInfo, size: 16),
                        color: Colors.indigo,
                        onPressed: () => _showContactDetails(
                          name: name,
                          position: position,
                          email: email,
                          phone: phone,
                          imageUrl: imageUrl,
                          department: department,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch phone')),
      );
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch email')),
      );
    }
  }

  void _showContactDetails({
    required String name,
    required String position,
    required String email,
    required String phone,
    required String imageUrl,
    required String department,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Profile Image
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(60),
                    border: Border.all(
                      color: Colors.indigo.shade100,
                      width: 3,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.person,
                            size: 50, color: Colors.grey),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.person,
                            size: 50, color: Colors.grey),
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Name
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                // Position
                Text(
                  position,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.indigo.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                // Department
                Text(
                  department,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 24),

                // Contact Info with Font Awesome Icons
                if (phone.isNotEmpty) ...[
                  ListTile(
                    leading: const FaIcon(FontAwesomeIcons.phone,
                        color: Colors.indigo),
                    title: Text(phone),
                    // onTap: () => _launchPhone(phone),
                    onTap: () async {
                      // var _phone = data.docs[index]['tel1'];
                      final Uri url = Uri(scheme: "tel", path: phone);
                      await launchUrl(url);
                    },
                  ),
                  const Divider(height: 1),
                ],

                if (email.isNotEmpty) ...[
                  ListTile(
                    leading: const FaIcon(FontAwesomeIcons.envelope,
                        color: Colors.indigo),
                    title: Text(email),
                    onTap: () => _launchEmail(email),
                  ),
                  const Divider(height: 1),
                ],

                const SizedBox(height: 16),

                // Close Button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CLOSE'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
