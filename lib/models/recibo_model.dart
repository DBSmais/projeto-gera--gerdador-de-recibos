class ReciboModel {
  final int? id;
  final String pagador;
  final String recebedor;
  final String? outroAgente;
  final double valor;
  final String descricao;
  final DateTime data;
  final String formaPagamento;
  final String? cpfCnpj;
  final String? endereco;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;
  final String? hashSeguranca;

  ReciboModel({
    this.id,
    required this.pagador,
    required this.recebedor,
    this.outroAgente,
    required this.valor,
    required this.descricao,
    required this.data,
    required this.formaPagamento,
    this.cpfCnpj,
    this.endereco,
    this.criadoEm,
    this.atualizadoEm,
    this.hashSeguranca,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pagador': pagador,
      'recebedor': recebedor,
      'outroAgente': outroAgente,
      'valor': valor,
      'descricao': descricao,
      'data': data.toIso8601String(),
      'formaPagamento': formaPagamento,
      'cpfCnpj': cpfCnpj,
      'endereco': endereco,
      'criadoEm': criadoEm?.toIso8601String(),
      'atualizadoEm': atualizadoEm?.toIso8601String(),
      'hashSeguranca': hashSeguranca,
    };
  }

  factory ReciboModel.fromMap(Map<String, dynamic> map) {
    return ReciboModel(
      id: map['id'] as int?,
      pagador: map['pagador'] as String,
      recebedor: map['recebedor'] as String,
      outroAgente: map['outroAgente'] as String?,
      valor: map['valor'] as double,
      descricao: map['descricao'] as String,
      data: DateTime.parse(map['data'] as String),
      formaPagamento: map['formaPagamento'] as String,
      cpfCnpj: map['cpfCnpj'] as String?,
      endereco: map['endereco'] as String?,
      criadoEm: map['criadoEm'] != null
          ? DateTime.parse(map['criadoEm'] as String)
          : null,
      atualizadoEm: map['atualizadoEm'] != null
          ? DateTime.parse(map['atualizadoEm'] as String)
          : null,
      hashSeguranca: map['hashSeguranca'] as String?,
    );
  }

  ReciboModel copyWith({
    int? id,
    String? pagador,
    String? recebedor,
    String? outroAgente,
    double? valor,
    String? descricao,
    DateTime? data,
    String? formaPagamento,
    String? cpfCnpj,
    String? endereco,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    String? hashSeguranca,
  }) {
    return ReciboModel(
      id: id ?? this.id,
      pagador: pagador ?? this.pagador,
      recebedor: recebedor ?? this.recebedor,
      outroAgente: outroAgente ?? this.outroAgente,
      valor: valor ?? this.valor,
      descricao: descricao ?? this.descricao,
      data: data ?? this.data,
      formaPagamento: formaPagamento ?? this.formaPagamento,
      cpfCnpj: cpfCnpj ?? this.cpfCnpj,
      endereco: endereco ?? this.endereco,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      hashSeguranca: hashSeguranca ?? this.hashSeguranca,
    );
  }
}

