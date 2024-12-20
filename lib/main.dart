import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supanew/auth/auth_gate.dart';

void main() async {
  await Supabase.initialize(
      url: 'https://laskopfypkrlvkgmlioh.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxhc2tvcGZ5cGtybHZrZ21saW9oIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzM1NzAyMjIsImV4cCI6MjA0OTE0NjIyMn0.pKVX9_APZR4Df7W-oPcEVE-FkrkCG6HRanoORmdmpoA');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: const AuthGate(),
    );
  }
}
