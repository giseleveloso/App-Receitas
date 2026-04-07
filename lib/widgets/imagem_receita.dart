import 'dart:io';
import 'package:flutter/material.dart';
import 'app_theme.dart';

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
    if (path != null && path!.isNotEmpty) {
      return Image.file(
        File(path!), // Carrega imagem do armazenamento local
        width: width,
        height: height,
        fit: BoxFit.cover, // Preenche o espaço sem distorcer
        errorBuilder: (_, __, ___) => _placeholder(), // Se falhar, mostra ícone
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: AppTheme.laranjaClaro,
      child: const Icon(Icons.restaurant, color: AppTheme.laranja, size: 36),
    );
  }
}
