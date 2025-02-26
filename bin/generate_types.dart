import 'dart:io';
import 'package:supabase_codegen/supabase_codegen.dart';

void main() async {
  try {
    await generateSupabaseTypes();
    exit(0);
  } on Exception catch (e) {
    // Use print to debug code
    // ignore: avoid_print
    print('Error: $e');
    exit(1);
  }
}
