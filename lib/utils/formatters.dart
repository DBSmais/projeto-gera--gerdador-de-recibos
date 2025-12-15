import 'package:intl/intl.dart';

class Formatters {
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }

  static String formatCurrency(double value) {
    return _currencyFormat.format(value);
  }

  static String formatCPF(String cpf) {
    final cleanCpf = cpf.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanCpf.length != 11) return cpf;
    return '${cleanCpf.substring(0, 3)}.${cleanCpf.substring(3, 6)}.${cleanCpf.substring(6, 9)}-${cleanCpf.substring(9)}';
  }

  static String formatCNPJ(String cnpj) {
    final cleanCnpj = cnpj.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanCnpj.length != 14) return cnpj;
    return '${cleanCnpj.substring(0, 2)}.${cleanCnpj.substring(2, 5)}.${cleanCnpj.substring(5, 8)}/${cleanCnpj.substring(8, 12)}-${cleanCnpj.substring(12)}';
  }

  static String formatCPFOrCNPJ(String? value) {
    if (value == null || value.isEmpty) return '';
    final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanValue.length == 11) {
      return formatCPF(value);
    } else if (cleanValue.length == 14) {
      return formatCNPJ(value);
    }
    return value;
  }

  static double parseCurrency(String value) {
    final cleanValue = value.replaceAll(RegExp(r'[^\d,.]'), '');
    return double.tryParse(cleanValue.replaceAll(',', '.')) ?? 0.0;
  }
}

