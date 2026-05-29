import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../modelos/receita.dart';

// Camada de acesso ao Supabase
// Toda comunicação com o Supabase passa por aqui, o resto do app não acessa o _client diretamente.
class DBHelper {
  // Cliente Supabase inicializado uma única vez em main.dart
  static final _client = Supabase.instance.client;
  static const _table = 'receitas';
  static const _bucket = 'imagens-receitas';

  Future<List<Receita>> getReceitas() async {
    final data = await _client
        .from(_table)
        .select()
        .order('criado_em', ascending: false);
    return data.map((m) => Receita.fromMap(m)).toList();
  }

  Future<List<Receita>> getDestaques() async {
    final data = await _client
        .from(_table)
        .select()
        .eq('favorito', true)
        .order('criado_em', ascending: false);
    return data.map((m) => Receita.fromMap(m)).toList();
  }

  Future<void> inserir(Receita r) async {
    await _client.from(_table).insert(r.toMap());
  }

  Future<void> toggleFavorito(String id, bool favorito) async {
    await _client.from(_table).update({'favorito': favorito}).eq('id', id);
  }

  // Faz upload de uma imagem para o Storage do Supabase e retorna a URL pública
  // O nome do arquivo usa o timestamp em ms para garantir unicidade
  Future<String> uploadImagem(XFile imagem) async {
    final bytes = await imagem.readAsBytes();
    final ext = imagem.path.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _client.storage.from(_bucket).uploadBinary(fileName, bytes);
    return _client.storage.from(_bucket).getPublicUrl(fileName);
  }

  Future<void> resetDb() async {
    await _client.from(_table).delete().neq('id', '');
  }
}
