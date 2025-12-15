import 'package:flutter/material.dart';
import '../models/recibo_model.dart';
import '../widgets/recibo_preview_widget.dart';
import '../services/pdf_service.dart';
import '../services/database_service.dart';
import '../services/security_service.dart';
import '../utils/error_handler.dart';
import 'criar_recibo_screen.dart';

class VisualizarReciboScreen extends StatefulWidget {
  final ReciboModel recibo;
  final bool isEditing;

  const VisualizarReciboScreen({
    super.key,
    required this.recibo,
    this.isEditing = false,
  });

  @override
  State<VisualizarReciboScreen> createState() => _VisualizarReciboScreenState();
}

class _VisualizarReciboScreenState extends State<VisualizarReciboScreen> {
  final DatabaseService _databaseService = DatabaseService();
  bool _isVerifying = false;

  Future<void> _verifyIntegrity() async {
    setState(() {
      _isVerifying = true;
    });

    final isValid = SecurityService.verifyHash(widget.recibo);

    setState(() {
      _isVerifying = false;
    });

    if (mounted) {
      if (isValid) {
        ErrorHandler.showSuccess(context, 'Integridade do recibo verificada!');
      } else {
        ErrorHandler.showError(
          context,
          'Atenção: O recibo pode ter sido alterado!',
          customMessage: 'Atenção: O recibo pode ter sido alterado!',
        );
      }
    }
  }

  Future<void> _sharePdf() async {
    await ErrorHandler.handleAsyncError(
      context,
      () => PdfService.sharePdf(widget.recibo),
      errorMessage: 'Erro ao compartilhar PDF',
    );
  }

  Future<void> _savePdf() async {
    await ErrorHandler.handleAsyncError(
      context,
      () async {
        await PdfService.savePdf(widget.recibo);
        return true;
      },
      errorMessage: 'Erro ao salvar PDF',
    );
    
    if (mounted) {
      ErrorHandler.showSuccess(context, 'PDF salvo com sucesso!');
    }
  }

  Future<void> _editRecibo() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CriarReciboScreen(recibo: widget.recibo),
      ),
    );

    if (result == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _deleteRecibo() async {
    if (widget.recibo.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja excluir este recibo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await ErrorHandler.handleAsyncError<int>(
        context,
        () => _databaseService.deleteRecibo(widget.recibo.id!),
        errorMessage: 'Erro ao excluir recibo',
      );
      
      if (result != null && result > 0 && mounted) {
        ErrorHandler.showSuccess(context, 'Recibo excluído com sucesso!');
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualizar Recibo'),
        actions: [
          if (widget.recibo.id != null) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _editRecibo,
              tooltip: 'Editar',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteRecibo,
              tooltip: 'Excluir',
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: ReciboPreviewWidget(recibo: widget.recibo),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.recibo.id != null)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isVerifying ? null : _verifyIntegrity,
                          icon: _isVerifying
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.verified_user),
                          label: const Text('Verificar Integridade'),
                        ),
                      ),
                    ],
                  ),
                if (widget.recibo.id != null) const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _sharePdf,
                        icon: const Icon(Icons.share),
                        label: const Text('Compartilhar PDF'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _savePdf,
                        icon: const Icon(Icons.download),
                        label: const Text('Salvar PDF'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

