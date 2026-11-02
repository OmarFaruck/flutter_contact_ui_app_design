import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../model/contact_model.dart';
import 'contact_form_screen.dart';

class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<Contact> contacts = [];

  final TextEditingController searchController =
  TextEditingController();

  bool showFavorites = false;

  // Load Contacts
  Future<void> loadContacts() async {

    final data = await DBHelper.instance.getContacts(
      search: searchController.text.trim(),
      favoritesOnly: showFavorites,
    );

    if (!mounted) return;

    setState(() {
      contacts = data;
    });
  }

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Navigate to Add/Edit Screen
  Future<void> openForm({Contact? contact}) async {

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactFormScreen(
          contact: contact,
        ),
      ),
    );

    if (result == true) {
      loadContacts();
    }
  }

  // Delete Contact
  Future<void> deleteContact(int id) async {

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: const Text(
          'Are you sure you want to delete this contact?',
        ),
        actions: [

          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('Cancel'),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Delete'),
          ),

        ],
      ),
    );

    if (confirm == true) {

      await DBHelper.instance.deleteContact(id);

      loadContacts();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contact deleted successfully!'),
        ),
      );
    }
  }

  // Favorite Contact
  Future<void> toggleFavorite(Contact contact) async {

    int newValue = contact.isFavorite == 1 ? 0 : 1;

    await DBHelper.instance.updateFavorite(
      contact.id!,
      newValue,
    );

    loadContacts();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: const Text(
          'My Contacts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2563EB),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            // Search Field
            TextField(
              controller: searchController,

              onChanged: (value) {
                loadContacts();
              },

              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: const Icon(Icons.search),

                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),

              ),
            ),

            const SizedBox(height: 16),

            // All / Favorite Filter
            Row(
              children: [

                Expanded(
                  child: ChoiceChip(
                    label: const Text('All Contacts'),
                    selected: !showFavorites,

                    onSelected: (value) {
                      setState(() {
                        showFavorites = false;
                      });

                      loadContacts();
                    },
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ChoiceChip(
                    label: const Text('★ Favorites'),
                    selected: showFavorites,

                    onSelected: (value) {
                      setState(() {
                        showFavorites = true;
                      });

                      loadContacts();
                    },
                  ),
                ),

              ],
            ),

            const SizedBox(height: 15),

            // Contact Count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                const Text(
                  'Contact List',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  '${contacts.length} Contacts',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 12),

            // Contact List
            Expanded(

              child: contacts.isEmpty

                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Icon(
                      Icons.contacts_outlined,
                      size: 70,
                      color: Colors.grey.shade400,
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'No Contacts Found!',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),

                  ],
                ),
              )

                  : ListView.builder(

                itemCount: contacts.length,

                itemBuilder: (context, index) {

                  final contact = contacts[index];

                  return Card(

                    color: Colors.white,

                    margin: const EdgeInsets.only(
                      bottom: 12,
                    ),

                    elevation: 2,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(12),

                      child: Column(
                        children: [

                          Row(
                            children: [

                              // Avatar
                              CircleAvatar(
                                radius: 25,
                                backgroundColor:
                                Colors.blue.shade100,

                                child: Text(
                                  contact.name.isNotEmpty
                                      ? contact.name[0].toUpperCase()
                                      : '?',

                                  style: const TextStyle(
                                    fontSize: 22,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              // Contact Information
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,

                                  children: [

                                    Text(
                                      contact.name,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    Text(
                                      contact.phone,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),

                                    Text(
                                      contact.email,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),

                                  ],
                                ),
                              ),

                              // Favorite Button
                              IconButton(
                                onPressed: () {
                                  toggleFavorite(contact);
                                },

                                icon: Icon(
                                  contact.isFavorite == 1
                                      ? Icons.star
                                      : Icons.star_border,

                                  color: Colors.amber,
                                  size: 28,
                                ),
                              ),

                            ],
                          ),

                          const Divider(),

                          // Address
                          Row(
                            children: [

                              const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 20,
                              ),

                              const SizedBox(width: 5),

                              Expanded(
                                child: Text(
                                  contact.address,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),

                            ],
                          ),

                          const SizedBox(height: 8),

                          // Contact ID + Edit + Delete
                          Row(
                            children: [

                              Text(
                                'ID: ${contact.id}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),

                              const Spacer(),

                              IconButton(
                                onPressed: () {
                                  openForm(contact: contact);
                                },

                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                              ),

                              IconButton(
                                onPressed: () {
                                  deleteContact(contact.id!);
                                },

                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),

                            ],
                          ),

                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          ],
        ),
      ),

      // Add Contact Button
      floatingActionButton: FloatingActionButton.extended(

        onPressed: () {
          openForm();
        },

        backgroundColor: const Color(0xFF2563EB),

        foregroundColor: Colors.white,

        icon: const Icon(Icons.person_add),

        label: const Text('Add Contact'),

      ),

    );
  }
}