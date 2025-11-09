import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:she_sos/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.name);
    emailController = TextEditingController(text: widget.user.emailId);
    phoneController = TextEditingController(text: widget.user.phoneNumber);
    addressController = TextEditingController(text: widget.user.address);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void toggleEdit() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  Future<void> saveChanges() async {
    try {
      final updatedUser = widget.user.copyWith(
        name: nameController.text.trim(),
        emailId: emailController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        address: addressController.text.trim(),
      );

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(updatedUser.userId)
          .update(updatedUser.toMap());

      // Optional: show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        toggleEdit();
      });

      print('✅ Firestore Updated for ${updatedUser.name}');
    } catch (e) {
      print('❌ Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: isEditing ? saveChanges : toggleEdit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Picture
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundImage: user.profilePicture != null
                        ? NetworkImage(user.profilePicture!)
                        : const AssetImage('assets/google_logo.png')
                              as ImageProvider,
                  ),
                  if (isEditing)
                    CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      radius: 18,
                      child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          // TODO: Add image picker logic
                        },
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            buildTextField('Full Name', nameController, isEditing),
            buildTextField('Email', emailController, false),
            buildTextField('Phone Number', phoneController, isEditing),
            buildTextField('Address', addressController, isEditing),

            const SizedBox(height: 20),
            if (user.isVolunteer)
              Chip(
                avatar: const Icon(
                  Icons.volunteer_activism,
                  color: Colors.white,
                ),
                label: const Text(
                  'Volunteer',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.green,
              ),
            const SizedBox(height: 30),

            // Emergency Contacts
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Emergency Contacts",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 10),
            ...user.emergencyContacts.map((contact) {
              final name = contact['name'] ?? '';
              final number = contact['phone'] ?? '';
              return Card(
                elevation: 1,
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.redAccent),
                  title: Text(name),
                  subtitle: Text(number),
                  trailing: isEditing
                      ? IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            setState(() {
                              widget.user.emergencyContacts.remove(contact);
                            });
                          },
                        )
                      : null,
                ),
              );
            }).toList(),

            if (isEditing)
              TextButton.icon(
                onPressed: () {
                  // TODO: open dialog to add a new contact
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Contact'),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(
    String label,
    TextEditingController controller,
    bool enabled,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
