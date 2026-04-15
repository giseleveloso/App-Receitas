import 'dart:io';
import 'package:flutter/material.dart';
import 'app_theme.dart';

// Widget reutilizável que exibe a imagem de uma receita.
// Aceita um caminho de arquivo local (path). Se o path for nulo ou inválido,
// mostra um ícone de placeholder no lugar da imagem.
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

  @override
  Widget build(BuildContext context) {
    // Só tenta carregar a imagem se o path foi fornecido e não está vazio
    if (path != null && path!.isNotEmpty) {
      return Image.file(
        File(path!),
        width: width,
        height: height,
        fit: BoxFit.cover, // preenche o espaço sem distorcer a imagem
        errorBuilder: (_, __, ___) => _placeholder(), // se falhar ao carregar, exibe o placeholder
      );
    }
    return _placeholder();
  }

  // Exibido quando não há imagem disponível.
  // Fundo laranja claro com ícone central de talheres.
  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: AppTheme.laranjaClaro,
      child: const Icon(Icons.restaurant, color: AppTheme.laranja, size: 36),
    );
  }
}
