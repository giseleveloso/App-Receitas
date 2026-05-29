import 'dart:io';
import 'package:flutter/material.dart';
import 'app_theme.dart';

// Widget reutilizável para exibir a imagem de uma receita.
// Detecta automaticamente se o caminho é uma URL (receita da API) ou
// um arquivo local (receita do usuário) e usa o widget correto em cada caso.
class ImagemReceita extends StatelessWidget {
  final String? path;
  final double width;
  final double height;

  const ImagemReceita({
    super.key,
    this.path,
    this.width = 80,
    this.height = 80,
  });

  // Verifica se o path é uma URL HTTP/HTTPS (imagem da API externa)
  bool get _isUrl =>
      path != null &&
      (path!.startsWith('http://') || path!.startsWith('https://'));

  @override
  Widget build(BuildContext context) {
    if (path == null || path!.isEmpty) return _placeholder();

    // Receita API — carrega da internet
    if (_isUrl) {
      return Image.network(
        path!,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    // Receita local — lê do sistema de arquivos do dispositivo
    return Image.file(
      File(path!),
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  // Exibido quando não há imagem ou quando o carregamento falha
  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: AppTheme.laranjaClaro,
      child: const Icon(Icons.restaurant, color: AppTheme.laranja, size: 36),
    );
  }
}
