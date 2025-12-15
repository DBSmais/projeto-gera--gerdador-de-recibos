import 'package:flutter/material.dart';
import '../models/recibo_model.dart';
import '../utils/formatters.dart';

class ReciboPreviewWidget extends StatelessWidget {
  final ReciboModel recibo;

  const ReciboPreviewWidget({
    super.key,
    required this.recibo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            const Center(
              child: Text(
                'RECIBO',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),

            // Conteúdo principal
            Text(
              'Recebi de ${recibo.pagador}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'a quantia de ${Formatters.formatCurrency(recibo.valor)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              'referente a: ${recibo.descricao}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            // Detalhes
            _buildDetailRow('Data:', Formatters.formatDate(recibo.data)),
            const SizedBox(height: 12),
            _buildDetailRow('Forma de Pagamento:', recibo.formaPagamento),
            if (recibo.cpfCnpj != null && recibo.cpfCnpj!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildDetailRow(
                'CPF/CNPJ:',
                Formatters.formatCPFOrCNPJ(recibo.cpfCnpj),
              ),
            ],
            if (recibo.endereco != null && recibo.endereco!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildDetailRow('Endereço:', recibo.endereco!),
            ],
            const SizedBox(height: 24),

            // Partes envolvidas
            const Text(
              'Partes envolvidas:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text('Pagador: ${recibo.pagador}'),
            const SizedBox(height: 8),
            Text('Recebedor: ${recibo.recebedor}'),
            if (recibo.outroAgente != null && recibo.outroAgente!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Outro Agente: ${recibo.outroAgente}'),
            ],
            const SizedBox(height: 32),

            // Assinaturas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 1,
                        color: Colors.black,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        recibo.pagador,
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Pagador',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 1,
                        color: Colors.black,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        recibo.recebedor,
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Recebedor',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}

