import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/recibo_model.dart';
import '../utils/formatters.dart';

class PdfService {
  static Future<Uint8List> generatePdf(ReciboModel recibo) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Título
              pw.Center(
                child: pw.Text(
                  'RECIBO',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 30),

              // Informações do recibo
              pw.Text(
                'Recebi de ${recibo.pagador}',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),

              pw.Text(
                'a quantia de ${Formatters.formatCurrency(recibo.valor)}',
                style: const pw.TextStyle(fontSize: 14),
              ),
              pw.SizedBox(height: 10),

              pw.Text(
                'referente a: ${recibo.descricao}',
                style: const pw.TextStyle(fontSize: 14),
              ),
              pw.SizedBox(height: 20),

              // Linha divisória
              pw.Divider(),
              pw.SizedBox(height: 20),

              // Detalhes
              _buildDetailRow('Data:', Formatters.formatDate(recibo.data)),
              pw.SizedBox(height: 8),
              _buildDetailRow('Forma de Pagamento:', recibo.formaPagamento),
              if (recibo.cpfCnpj != null && recibo.cpfCnpj!.isNotEmpty) ...[
                pw.SizedBox(height: 8),
                _buildDetailRow(
                  'CPF/CNPJ:',
                  Formatters.formatCPFOrCNPJ(recibo.cpfCnpj),
                ),
              ],
              if (recibo.endereco != null && recibo.endereco!.isNotEmpty) ...[
                pw.SizedBox(height: 8),
                _buildDetailRow('Endereço:', recibo.endereco!),
              ],
              pw.SizedBox(height: 20),

              // Agentes
              pw.Text(
                'Partes envolvidas:',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Pagador: ${recibo.pagador}'),
              pw.SizedBox(height: 5),
              pw.Text('Recebedor: ${recibo.recebedor}'),
              if (recibo.outroAgente != null &&
                  recibo.outroAgente!.isNotEmpty) ...[
                pw.SizedBox(height: 5),
                pw.Text('Outro Agente: ${recibo.outroAgente}'),
              ],
              pw.Spacer(),

              // Assinaturas
              pw.SizedBox(height: 40),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Column(
                    children: [
                      pw.Container(
                        width: 200,
                        height: 1,
                        color: PdfColors.black,
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        recibo.pagador,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        'Pagador',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Container(
                        width: 200,
                        height: 1,
                        color: PdfColors.black,
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        recibo.recebedor,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        'Recebedor',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildDetailRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 120,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: const pw.TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  static Future<void> sharePdf(ReciboModel recibo) async {
    final pdfBytes = await generatePdf(recibo);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }

  static Future<void> savePdf(ReciboModel recibo) async {
    final pdfBytes = await generatePdf(recibo);
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'recibo_${recibo.id}_${Formatters.formatDate(recibo.data).replaceAll('/', '_')}.pdf',
    );
  }
}

