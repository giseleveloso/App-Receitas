import 'dart:convert';
import 'package:http/http.dart' as http;
import '../modelos/receita_externa.dart';

class MealService {
  Future<ReceitaExterna?> buscarAleatoria() async {
    final uri = Uri.https('www.themealdb.com', '/api/json/v1/1/random.php');
    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 10));
      if (resp.statusCode != 200) return null;

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final meals = data['meals'] as List<dynamic>?;
      if (meals == null || meals.isEmpty) return null;

      return ReceitaExterna.fromJson(meals.first as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
