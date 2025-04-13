import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_codegen_example/types/database.dart';

class UsersDetailScreen extends StatelessWidget {
  final UsersRow user;

  const UsersDetailScreen({required this.user, super.key});

  // Helper to display optional fields
  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value ?? '')),
        ],
      ),
    );
  }

  // Helper to format dates
  String _formatDate(DateTime dateTime) {
    return DateFormat.yMMMd().add_jms().format(dateTime); // Example format
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        // Show user's name or email in the title
        title: Text(
          user.accName?.isNotEmpty == true ? user.accName! : user.email,
        ),
        // Edit/Delete actions
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              /* Navigate to edit */
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              /* Show delete confirmation */
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetailRow('ID', user.id),
            _buildDetailRow('Email', user.email),
            _buildDetailRow('Account Name', user.accName),
            _buildDetailRow('Phone Number', user.phoneNumber),
            _buildDetailRow('Role', user.role.name),
            _buildDetailRow('Created At', _formatDate(user.createdAt)),
            const SizedBox(height: 10),
            const Text(
              'Contacts:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            if (user.contacts.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Text('N/A'),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Column(
                  children:
                      user.contacts.map((contact) {
                        return ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(contact),
                        );
                      }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
