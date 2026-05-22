import 'package:app_exercicio_aula1/telas/main_nav.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://qlgjjhenlvmizqzfqdju.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFsZ2pqaGVubHZtaXpxemZxZGp1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkzNzUxMDgsImV4cCI6MjA5NDk1MTEwOH0.Gu-9tEMYs6HHSfcE8AdQt9ETTDZuVDztOHBnmlvsNgU',
  );

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MainNav(),
  ));
}
