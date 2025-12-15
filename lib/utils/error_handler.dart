import 'package:flutter/material.dart';

class ErrorHandler {
  static void showError(BuildContext? context, dynamic error, {String? customMessage}) {
    if (context == null) return;

    String message = customMessage ?? 'Ocorreu um erro inesperado';
    
    // Log seguro (sem dados sensíveis)
    _logError(error);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  static void showSuccess(BuildContext? context, String message) {
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static void _logError(dynamic error) {
    // Log seguro - não expõe dados sensíveis
    // Em produção, isso poderia enviar para um serviço de logging
    final errorMessage = error.toString();
    
    // Remove possíveis dados sensíveis do log
    final safeMessage = errorMessage
        .replaceAll(RegExp(r'\d{3}\.\d{3}\.\d{3}-\d{2}'), '[CPF]')
        .replaceAll(RegExp(r'\d{2}\.\d{3}\.\d{3}/\d{4}-\d{2}'), '[CNPJ]')
        .replaceAll(RegExp(r'R\$\s*[\d,\.]+'), '[VALOR]');
    
    // Em produção, usar um serviço de logging adequado
    // Exemplo: Firebase Crashlytics, Sentry, etc.
    debugPrint('Erro: $safeMessage');
  }

  static Future<T?> handleAsyncError<T>(
    BuildContext? context,
    Future<T> Function() operation, {
    String? errorMessage,
    T? defaultValue,
  }) async {
    try {
      return await operation();
    } catch (e) {
      if (context != null) {
        showError(context, e, customMessage: errorMessage);
      }
      return defaultValue;
    }
  }
}

