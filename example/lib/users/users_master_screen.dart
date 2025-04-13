import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:supabase_codegen_example/types/database.dart';
import 'package:supabase_codegen_example/supabase_codegen_example.dart';

class UsersMasterScreen extends StatefulWidget {
  const UsersMasterScreen({super.key});

  @override
  State<UsersMasterScreen> createState() => _UsersMasterScreenState();
}

class _UsersMasterScreenState extends State<UsersMasterScreen> {
  final UsersTable _usersTable = UsersTable();
  late Future<List<UsersRow>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    // Fetch all users.
    _usersFuture = _usersTable.queryRows();
  }

  Future<void> _refreshUsers() async {
    setState(() {
      _loadUsers();
    });
  }

  void _navigateToDetail(BuildContext context, UsersRow user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UsersDetailScreen(user: user)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Supabase Codegen Example - Users List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshUsers,
            tooltip: 'Refresh Users',
          ),
        ],
      ),
      body: FutureBuilder<List<UsersRow>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            log(snapshot.error.toString());
            return Center(
              child: Text('Error loading users: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          final users = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refreshUsers,
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final hasUserName = user.accName?.isNotEmpty == true;

                return ListTile(
                  leading: CircleAvatar(
                    // Display initials or a placeholder icon
                    child: Text(
                      hasUserName
                          ? user.accName![0].toUpperCase()
                          : user.email[0].toUpperCase(),
                    ),
                  ),
                  title: Text(hasUserName ? user.accName! : user.email),
                  subtitle: hasUserName ? Text(user.email) : null,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _navigateToDetail(context, user),
                );
              },
            ),
          );
        },
      ),
      // Add a new user
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to an Add/Edit User screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
