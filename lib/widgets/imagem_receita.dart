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

  bool get _isUrl =>
      path != null &&
      (path!.startsWith('http://') || path!.startsWith('https://'));

  @override
  Widget build(BuildContext context) {
    if (path == null || path!.isEmpty) return _placeholder();

//Receita API
    if (_isUrl) {
      return Image.network(
        path!,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

// Receita local
    return Image.file(
      File(path!),
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
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
