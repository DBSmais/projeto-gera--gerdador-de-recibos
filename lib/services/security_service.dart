import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/recibo_model.dart';

class SecurityService {
  static String generateHash(ReciboModel recibo) {
    // Cria uma string com todos os dados do recibo
    final data = '${recibo.id}_'
        '${recibo.pagador}_'
        '${recibo.recebedor}_'
        '${recibo.outroAgente ?? ''}_'
        '${recibo.valor}_'
        '${recibo.descricao}_'
        '${recibo.data.toIso8601String()}_'
        '${recibo.formaPagamento}_'
        '${recibo.cpfCnpj ?? ''}_'
        '${recibo.endereco ?? ''}';

    // Gera hash SHA-256
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool verifyHash(ReciboModel recibo) {
    if (recibo.hashSeguranca == null) return false;
    final calculatedHash = generateHash(recibo);
    return calculatedHash == recibo.hashSeguranca;
  }

  static ReciboModel addSecurityHash(ReciboModel recibo) {
    final hash = generateHash(recibo);
    return recibo.copyWith(hashSeguranca: hash);
  }
}

