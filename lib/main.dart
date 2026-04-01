import 'dart:io';
import 'package:app_exercicio_aula1/telas/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  // 1. Garante a inicialização dos Widgets antes de qualquer lógica assíncrona
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Configuração específica para Desktop (Windows/Linux)
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomeScreen(),
  ));
}
