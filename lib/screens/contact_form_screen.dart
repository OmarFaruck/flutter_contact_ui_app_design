import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../model/contact_model.dart';

class ContactFormScreen extends StatefulWidget {

  final Contact? contact;

  const ContactFormScreen({
    super.key,
    this.contact,
  });

  @override
  State<ContactFormScreen> createState() =>
      _ContactFormScreenState();
}

class _ContactFormScreenState extends State<ContactFormScreen> {

  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController addressController;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.contact?.name ?? '',
    );

    phoneController = TextEditingController(
      text: widget.contact?.phone ?? '',
    );

    emailController = TextEditingController(
      text: widget.contact?.email ?? '',
    );

    addressController = TextEditingController(
      text: widget.contact?.address ?? '',
    );
  }

  @override
  void dispose() {

    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();

    super.dispose();
  }

  // Save Contact
  Future<void> saveContact() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {

      Contact contact = Contact(

        id: widget.contact?.id,

        name: nameController.text.trim(),

        phone: phoneController.text.trim(),

        email: emailController.text.trim(),

        address: addressController.text.trim(),

        isFavorite: widget.contact?.isFavorite ?? 0,

      );

      if (widget.contact == null) {

        // INSERT
        await DBHelper.instance.insertContact(contact);

      } else {

        // UPDATE
        await DBHelper.instance.updateContact(contact);

      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.contact == null
                ? 'Contact added successfully!'
                : 'Contact updated successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong: $e'),
        ),
      );

    } finally {

      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }

    }
  }

  // Reusable Input Field
  Widget buildTextField({

    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,

  }) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),

      child: TextFormField(

        controller: controller,

        keyboardType: keyboardType,

        decoration: InputDecoration(

          labelText: label,

          prefixIcon: Icon(icon),

          filled: true,

          fillColor: Colors.grey.shade100,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),

        ),

        validator: (value) {

          if (value == null || value.trim().isEmpty) {
            return '$label is required';
          }

          return null;
        },

      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    bool isEditing = widget.contact != null;

    return Scaffold(

      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(

        title: Text(
          isEditing ? 'Update Contact' : 'Add New Contact',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor: const Color(0xFF2563EB),

        foregroundColor: Colors.white,

        centerTitle: true,

      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Card(

          elevation: 2,

          color: Colors.white,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),

          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Form(

              key: _formKey,

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  const Center(
                    child: Icon(
                      Icons.account_circle,
                      size: 80,
                      color: Color(0xFF2563EB),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: Text(
                      isEditing
                          ? 'Edit Contact Information'
                          : 'Enter Contact Information',

                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Name
                  buildTextField(
                    label: 'Full Name',
                    icon: Icons.person,
                    controller: nameController,
                  ),

                  // Phone
                  buildTextField(
                    label: 'Phone Number',
                    icon: Icons.phone,
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                  ),

                  // Email
                  buildTextField(
                    label: 'Email Address',
                    icon: Icons.email,
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  // Address
                  buildTextField(
                    label: 'Address',
                    icon: Icons.location_on,
                    controller: addressController,
                  ),

                  const SizedBox(height: 15),

                  // Save Button
                  SizedBox(

                    width: double.infinity,

                    height: 52,

                    child: ElevatedButton.icon(

                      onPressed: isSaving ? null : saveContact,

                      style: ElevatedButton.styleFrom(

                        backgroundColor: const Color(0xFF2563EB),

                        foregroundColor: Colors.white,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),

                      ),

                      icon: isSaving
                          ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : Icon(
                        isEditing ? Icons.update : Icons.save,
                      ),

                      label: Text(
                        isSaving
                            ? 'Saving...'
                            : isEditing
                            ? 'Update Contact'
                            : 'Save Contact',
                      ),

                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}