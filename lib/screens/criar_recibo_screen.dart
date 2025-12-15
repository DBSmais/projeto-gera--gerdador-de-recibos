import 'package:flutter/material.dart';
import '../models/recibo_model.dart';
import '../widgets/recibo_form_widget.dart';
import '../widgets/recibo_preview_widget.dart';
import 'visualizar_recibo_screen.dart';
import '../services/database_service.dart';
import '../services/security_service.dart';
import '../utils/error_handler.dart';

class CriarReciboScreen extends StatefulWidget {
  final ReciboModel? recibo;

  const CriarReciboScreen({super.key, this.recibo});

  @override
  State<CriarReciboScreen> createState() => _CriarReciboScreenState();
}

class _CriarReciboScreenState extends State<CriarReciboScreen> {
  final DatabaseService _databaseService = DatabaseService();
  ReciboModel? _reciboPreview;
  bool _showPreview = false;

  void _handleSubmit(ReciboModel recibo) {
    setState(() {
      _reciboPreview = recibo;
      _showPreview = true;
    });
  }

  Future<void> _saveRecibo() async {
    if (_reciboPreview == null) return;

    try {
      final reciboComHash = SecurityService.addSecurityHash(_reciboPreview!);
      
      if (reciboComHash.id == null) {
        await _databaseService.insertRecibo(reciboComHash);
        if (mounted) {
          ErrorHandler.showSuccess(context, 'Recibo salvo com sucesso!');
          Navigator.pop(context, true);
        }
      } else {
        await _databaseService.updateRecibo(reciboComHash);
        if (mounted) {
          ErrorHandler.showSuccess(context, 'Recibo atualizado com sucesso!');
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e, customMessage: 'Erro ao salvar recibo');
      }
    }
  }

  void _goToVisualizar() {
    if (_reciboPreview != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VisualizarReciboScreen(recibo: _reciboPreview!),
        ),
      ).then((saved) {
        if (saved == true) {
          Navigator.pop(context, true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recibo == null ? 'Criar Recibo' : 'Editar Recibo'),
      ),
      body: _showPreview && _reciboPreview != null
          ? Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: ReciboPreviewWidget(recibo: _reciboPreview!),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _showPreview = false;
                            });
                          },
                          child: const Text('Voltar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveRecibo,
                          child: const Text('Salvar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _goToVisualizar,
                          icon: const Icon(Icons.visibility),
                          label: const Text('Visualizar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : ReciboFormWidget(
              recibo: widget.recibo,
              onSubmit: _handleSubmit,
            ),
    );
  }
}

