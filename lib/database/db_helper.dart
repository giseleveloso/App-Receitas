import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';
import '../modelos/receita.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get _database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    return openDatabase(
      join(await getDatabasesPath(), 'a1receitas.db'),
      onCreate: (db, v) async {
        await db.execute('''
          CREATE TABLE receitas(
            id TEXT PRIMARY KEY,
            nome TEXT NOT NULL,
            categoria TEXT NOT NULL,
            tempo_preparo INTEGER NOT NULL,
            porcoes INTEGER NOT NULL,
            ingredientes TEXT NOT NULL,
            modo_preparo TEXT NOT NULL,
            imagem_path TEXT,
            criado_em TEXT NOT NULL,
            favorito INTEGER NOT NULL DEFAULT 0
          )
        ''');
        final uuid = const Uuid();
        final now = DateTime.now().toIso8601String();
        await db.insert('receitas', {
          'id': uuid.v4(),
          'nome': 'Ovos mexidos',
          'categoria': 'Café da manhã',
          'tempo_preparo': 10,
          'porcoes': 2,
          'ingredientes': jsonEncode(['3 ovos', '1 colher de manteiga', 'Sal a gosto']),
          'modo_preparo': jsonEncode([
            'Derreta a manteiga em fogo baixo.',
            'Quebre os ovos e mexa devagar.',
            'Tempere com sal e sirva.',
          ]),
          'imagem_path': null,
          'criado_em': now,
          'favorito': 1,
        });
        await db.insert('receitas', {
          'id': uuid.v4(),
          'nome': 'Sopa rápida',
          'categoria': 'Almoço',
          'tempo_preparo': 25,
          'porcoes': 4,
          'ingredientes': jsonEncode(['2 batatas', '1 cenoura', '1 cebola', 'Sal e pimenta']),
          'modo_preparo': jsonEncode([
            'Corte os legumes em cubos.',
            'Cozinhe em água com sal por 20 minutos.',
            'Bata no liquidificador e sirva quente.',
          ]),
          'imagem_path': null,
          'criado_em': now,
          'favorito': 1,
        });
      },
      version: 1,
    );
  }

  Future<void> inserir(Receita r) async {
    final db = await _database;
    await db.insert('receitas', r.toMap());
  }

  Future<List<Receita>> getReceitas() async {
    final db = await _database;
    final maps = await db.query('receitas', orderBy: 'criado_em DESC');
    return maps.map(Receita.fromMap).toList();
  }

  Future<List<Receita>> getDestaques() async {
    final db = await _database;
    final maps = await db.query('receitas',
        where: 'favorito = 1', orderBy: 'criado_em DESC');
    return maps.map(Receita.fromMap).toList();
  }

  Future<void> resetDb() async {
    final path = join(await getDatabasesPath(), 'receitas.db');
    await _db?.close();
    _db = null;
    await deleteDatabase(path);
  }

  Future<void> toggleFavorito(String id, bool favorito) async {
    final db = await _database;
    await db.update('receitas', {'favorito': favorito ? 1 : 0},
        where: 'id = ?', whereArgs: [id]);
  }
}
