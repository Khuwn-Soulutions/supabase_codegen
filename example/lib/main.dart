import 'package:flutter/material.dart';
import 'package:supabase_codegen/supabase_codegen.dart';
import 'package:supabase_codegen_example/users/users_master_screen.dart';

void main() async {
  // Load the supabase client using the default config.env file
  await loadClientFromEnv();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Supabase Codegen Example App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const UsersMasterScreen(),
    );
  }
}
