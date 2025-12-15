class Validators {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName é obrigatório';
    }
    return null;
  }

  static String? validateCPF(String? cpf) {
    if (cpf == null || cpf.trim().isEmpty) {
      return null; // CPF é opcional
    }

    // Remove caracteres não numéricos
    final cleanCpf = cpf.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanCpf.length != 11) {
      return 'CPF deve conter 11 dígitos';
    }

    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1+$').hasMatch(cleanCpf)) {
      return 'CPF inválido';
    }

    // Validação dos dígitos verificadores
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cleanCpf[i]) * (10 - i);
    }
    int digit1 = (sum * 10) % 11;
    if (digit1 == 10) digit1 = 0;
    if (digit1 != int.parse(cleanCpf[9])) {
      return 'CPF inválido';
    }

    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cleanCpf[i]) * (11 - i);
    }
    int digit2 = (sum * 10) % 11;
    if (digit2 == 10) digit2 = 0;
    if (digit2 != int.parse(cleanCpf[10])) {
      return 'CPF inválido';
    }

    return null;
  }

  static String? validateCNPJ(String? cnpj) {
    if (cnpj == null || cnpj.trim().isEmpty) {
      return null; // CNPJ é opcional
    }

    // Remove caracteres não numéricos
    final cleanCnpj = cnpj.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanCnpj.length != 14) {
      return 'CNPJ deve conter 14 dígitos';
    }

    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1+$').hasMatch(cleanCnpj)) {
      return 'CNPJ inválido';
    }

    // Validação dos dígitos verificadores
    int length = cleanCnpj.length - 2;
    String numbers = cleanCnpj.substring(0, length);
    final String digits = cleanCnpj.substring(length);
    int sum = 0;
    int pos = length - 7;

    for (int i = length; i >= 1; i--) {
      sum += int.parse(numbers[length - i]) * pos--;
      if (pos < 2) pos = 9;
    }

    int result = sum % 11 < 2 ? 0 : 11 - sum % 11;
    if (result != int.parse(digits[0])) {
      return 'CNPJ inválido';
    }

    length = length + 1;
    numbers = cleanCnpj.substring(0, length);
    sum = 0;
    pos = length - 7;

    for (int i = length; i >= 1; i--) {
      sum += int.parse(numbers[length - i]) * pos--;
      if (pos < 2) pos = 9;
    }

    result = sum % 11 < 2 ? 0 : 11 - sum % 11;
    if (result != int.parse(digits[1])) {
      return 'CNPJ inválido';
    }

    return null;
  }

  static String? validateCPFOrCNPJ(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // É opcional
    }

    final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanValue.length == 11) {
      return validateCPF(value);
    } else if (cleanValue.length == 14) {
      return validateCNPJ(value);
    } else {
      return 'CPF deve ter 11 dígitos ou CNPJ deve ter 14 dígitos';
    }
  }

  static String? validateValor(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Valor é obrigatório';
    }

    final cleanValue = value.replaceAll(RegExp(r'[^\d,.]'), '');
    final doubleValue = double.tryParse(cleanValue.replaceAll(',', '.'));

    if (doubleValue == null || doubleValue <= 0) {
      return 'Valor deve ser maior que zero';
    }

    return null;
  }

  static String sanitizeInput(String input) {
    // Remove caracteres perigosos para SQL injection
    return input
        .replaceAll("'", "''")
        .replaceAll(';', '')
        .replaceAll('--', '')
        .replaceAll('/*', '')
        .replaceAll('*/', '')
        .trim();
  }
}

