import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/recibo_model.dart';
import '../utils/validators.dart';
import '../utils/formatters.dart';

class ReciboFormWidget extends StatefulWidget {
  final ReciboModel? recibo;
  final Function(ReciboModel) onSubmit;

  const ReciboFormWidget({
    super.key,
    this.recibo,
    required this.onSubmit,
  });

  @override
  State<ReciboFormWidget> createState() => _ReciboFormWidgetState();
}

class _ReciboFormWidgetState extends State<ReciboFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _pagadorController;
  late TextEditingController _recebedorController;
  late TextEditingController _outroAgenteController;
  late TextEditingController _valorController;
  late TextEditingController _descricaoController;
  late TextEditingController _cpfCnpjController;
  late TextEditingController _enderecoController;

  String _formaPagamento = 'Dinheiro';
  DateTime _data = DateTime.now();

  final List<String> _formasPagamento = [
    'Dinheiro',
    'PIX',
    'Cartão de Débito',
    'Cartão de Crédito',
    'Transferência Bancária',
    'Cheque',
    'Outro',
  ];

  @override
  void initState() {
    super.initState();
    final recibo = widget.recibo;
    _pagadorController = TextEditingController(text: recibo?.pagador ?? '');
    _recebedorController = TextEditingController(text: recibo?.recebedor ?? '');
    _outroAgenteController = TextEditingController(text: recibo?.outroAgente ?? '');
    _valorController = TextEditingController(
      text: recibo != null ? Formatters.formatCurrency(recibo.valor) : '',
    );
    _descricaoController = TextEditingController(text: recibo?.descricao ?? '');
    _cpfCnpjController = TextEditingController(text: recibo?.cpfCnpj ?? '');
    _enderecoController = TextEditingController(text: recibo?.endereco ?? '');
    _formaPagamento = recibo?.formaPagamento ?? 'Dinheiro';
    _data = recibo?.data ?? DateTime.now();
  }

  @override
  void dispose() {
    _pagadorController.dispose();
    _recebedorController.dispose();
    _outroAgenteController.dispose();
    _valorController.dispose();
    _descricaoController.dispose();
    _cpfCnpjController.dispose();
    _enderecoController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final valor = Formatters.parseCurrency(_valorController.text);
      final recibo = ReciboModel(
        id: widget.recibo?.id,
        pagador: Validators.sanitizeInput(_pagadorController.text),
        recebedor: Validators.sanitizeInput(_recebedorController.text),
        outroAgente: _outroAgenteController.text.trim().isEmpty
            ? null
            : Validators.sanitizeInput(_outroAgenteController.text),
        valor: valor,
        descricao: Validators.sanitizeInput(_descricaoController.text),
        data: _data,
        formaPagamento: _formaPagamento,
        cpfCnpj: _cpfCnpjController.text.trim().isEmpty
            ? null
            : Validators.sanitizeInput(_cpfCnpjController.text),
        endereco: _enderecoController.text.trim().isEmpty
            ? null
            : Validators.sanitizeInput(_enderecoController.text),
      );
      widget.onSubmit(recibo);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null && picked != _data) {
      setState(() {
        _data = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Pagador
          TextFormField(
            controller: _pagadorController,
            decoration: const InputDecoration(
              labelText: 'Nome do Pagador *',
              hintText: 'Digite o nome de quem está pagando',
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) => Validators.validateRequired(value, 'Pagador'),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),

          // Recebedor
          TextFormField(
            controller: _recebedorController,
            decoration: const InputDecoration(
              labelText: 'Nome do Recebedor *',
              hintText: 'Digite o nome de quem está recebendo',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) => Validators.validateRequired(value, 'Recebedor'),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),

          // Outro Agente (opcional)
          TextFormField(
            controller: _outroAgenteController,
            decoration: const InputDecoration(
              labelText: 'Outro Agente (opcional)',
              hintText: 'Digite o nome de outro agente envolvido',
              prefixIcon: Icon(Icons.people),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),

          // Valor
          TextFormField(
            controller: _valorController,
            decoration: const InputDecoration(
              labelText: 'Valor *',
              hintText: 'R\$ 0,00',
              prefixIcon: Icon(Icons.attach_money),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
            ],
            validator: (value) => Validators.validateValor(value),
            onChanged: (value) {
              // Formatação automática do valor
              if (value.isNotEmpty) {
                final doubleValue = Formatters.parseCurrency(value);
                if (doubleValue > 0) {
                  final formatted = Formatters.formatCurrency(doubleValue);
                  if (formatted != value) {
                    _valorController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(offset: formatted.length),
                    );
                  }
                }
              }
            },
          ),
          const SizedBox(height: 16),

          // Descrição
          TextFormField(
            controller: _descricaoController,
            decoration: const InputDecoration(
              labelText: 'Descrição do Serviço *',
              hintText: 'Descreva o serviço prestado',
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 3,
            validator: (value) => Validators.validateRequired(value, 'Descrição'),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),

          // Data
          InkWell(
            onTap: _selectDate,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Data *',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(Formatters.formatDate(_data)),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Forma de Pagamento
          DropdownButtonFormField<String>(
            initialValue: _formaPagamento,
            decoration: const InputDecoration(
              labelText: 'Forma de Pagamento *',
              prefixIcon: Icon(Icons.payment),
            ),
            items: _formasPagamento.map((forma) {
              return DropdownMenuItem(
                value: forma,
                child: Text(forma),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _formaPagamento = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),

          // CPF/CNPJ
          TextFormField(
            controller: _cpfCnpjController,
            decoration: const InputDecoration(
              labelText: 'CPF/CNPJ (opcional)',
              hintText: '000.000.000-00 ou 00.000.000/0000-00',
              prefixIcon: Icon(Icons.badge),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.-/]')),
            ],
            validator: (value) => Validators.validateCPFOrCNPJ(value),
            onChanged: (value) {
              // Formatação automática
              if (value.isNotEmpty) {
                final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
                if (cleanValue.length <= 11) {
                  final formatted = Formatters.formatCPF(value);
                  if (formatted != value && formatted.isNotEmpty) {
                    _cpfCnpjController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(offset: formatted.length),
                    );
                  }
                } else if (cleanValue.length <= 14) {
                  final formatted = Formatters.formatCNPJ(value);
                  if (formatted != value && formatted.isNotEmpty) {
                    _cpfCnpjController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(offset: formatted.length),
                    );
                  }
                }
              }
            },
          ),
          const SizedBox(height: 16),

          // Endereço
          TextFormField(
            controller: _enderecoController,
            decoration: const InputDecoration(
              labelText: 'Endereço (opcional)',
              hintText: 'Digite o endereço',
              prefixIcon: Icon(Icons.location_on),
            ),
            maxLines: 2,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 24),

          // Botão de submit
          ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Gerar Recibo',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

