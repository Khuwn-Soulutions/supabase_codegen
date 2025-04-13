import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:supabase_codegen_example/types/database.dart';

class UsersEditScreen extends StatefulWidget {
  final UsersRow? user;

  const UsersEditScreen({super.key, this.user});

  @override
  State<UsersEditScreen> createState() => _UsersEditScreenState();
}

class _UsersEditScreenState extends State<UsersEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usersTable = UsersTable();
  bool _isLoading = false;

  // Controllers
  late TextEditingController _emailController;
  late TextEditingController _accNameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _newContactController;

  // State
  UserRole? _selectedRole;
  List<String> _contacts = [];

  bool get _isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.user?.email);
    _accNameController = TextEditingController(text: widget.user?.accName);
    _phoneNumberController = TextEditingController(
      text: widget.user?.phoneNumber,
    );
    _newContactController = TextEditingController();
    _selectedRole = widget.user?.role;
    // Create a mutable copy for editing
    _contacts = List<String>.from(widget.user?.contacts ?? []);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _accNameController.dispose();
    _phoneNumberController.dispose();
    _newContactController.dispose();
    super.dispose();
  }

  Future<void> _saveUser() async {
    // Close keyboard
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return; // Validation failed
    }
    if (_selectedRole == null) {
      // Show error if UserRole is not selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a UserRole.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final upsertData = UsersRow(
      id: widget.user?.id, // Include ID only if editing
      email: _emailController.text.trim(),
      accName:
          _accNameController.text.trim().isNotEmpty
              ? _accNameController.text.trim()
              : null,
      phoneNumber:
          _phoneNumberController.text.trim().isNotEmpty
              ? _phoneNumberController.text.trim()
              : null,
      role: _selectedRole!,
      contacts: _contacts,
    );

    try {
      await _usersTable.upsertRow(upsertData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'User ${_isEditing ? 'updated' : 'created'} successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Pop screen and indicate success (true) to the previous screen
        Navigator.of(context).pop(true);
      }
    } catch (e, stackTrace) {
      log('Error saving user: $e', error: e, stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving user: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _addContact() {
    final newContact = _newContactController.text.trim();
    if (newContact.isEmpty) return;

    // Basic email format check
    if (!newContact.contains('@') || !newContact.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email format for the contact.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_contacts.contains(newContact)) {
      setState(() {
        _contacts.add(newContact);
        _newContactController.clear();
        // Close keyboard after adding
        FocusScope.of(context).unfocus();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contact already exists.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _removeContact(String contact) {
    setState(() {
      _contacts.remove(contact);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_isEditing ? 'Edit' : 'Add'} User'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveUser,
              tooltip: 'Save User',
            ),
        ],
      ),
      // Use GestureDetector to dismiss keyboard when tapping outside fields
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          // Allows scrolling if content overflows
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch, // Make children wider
                children: [
                  // Email (Required)
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email *',
                      hintText: 'user@example.com',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter an email';
                      }
                      // Basic email validation
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Account Name (Optional)
                  TextFormField(
                    controller: _accNameController,
                    decoration: const InputDecoration(
                      labelText: 'User Name',
                      hintText: 'User Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Phone Number (Optional)
                  TextFormField(
                    controller: _phoneNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: '+1234567890',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  // UserRole (Required)
                  DropdownButtonFormField<UserRole>(
                    value: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'UserRole *',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        UserRole.values.map((UserRole role) {
                          return DropdownMenuItem<UserRole>(
                            value: role,
                            // Capitalize first letter for display
                            child: Text(
                              role.name[0].toUpperCase() +
                                  role.name.substring(1),
                            ),
                          );
                        }).toList(),
                    onChanged: (UserRole? newValue) {
                      setState(() {
                        _selectedRole = newValue;
                      });
                    },
                    validator:
                        (value) =>
                            value == null ? 'Please select a UserRole' : null,
                  ),
                  const SizedBox(height: 24),

                  // Contacts List (Optional)
                  Text(
                    'Contacts',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  // Input field for adding new contacts
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _newContactController,
                          decoration: const InputDecoration(
                            labelText: 'Add Contact Email',
                            hintText: 'contact@example.com',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          // Add contact on submit
                          onFieldSubmitted: (_) => _addContact(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.add),
                        onPressed: _addContact,
                        tooltip: 'Add Contact',
                        padding: const EdgeInsets.all(
                          12,
                        ), // Adjust padding for visual balance
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Display existing contacts
                  if (_contacts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'No contacts added yet.',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    )
                  else
                    // Use a Card for better visual separation
                    Card(
                      margin: EdgeInsets.zero, // Remove default Card margin
                      child: ListView.builder(
                        shrinkWrap:
                            true, // Important inside SingleChildScrollView
                        physics:
                            const NeverScrollableScrollPhysics(), // Disable ListView's own scrolling
                        itemCount: _contacts.length,
                        itemBuilder: (context, index) {
                          final contact = _contacts[index];
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.person_outline, size: 20),
                            title: Text(contact),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                size: 20,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => _removeContact(contact),
                              tooltip: 'Remove Contact',
                              padding: EdgeInsets.zero,
                              constraints:
                                  const BoxConstraints(), // Remove extra padding around icon
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 0,
                            ),
                          );
                        },
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                        ), // Padding inside the list
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
