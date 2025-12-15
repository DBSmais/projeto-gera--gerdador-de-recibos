import 'package:flutter/material.dart';
import '../models/recibo_model.dart';
import '../services/database_service.dart';
import '../widgets/recibo_card_widget.dart';
import '../utils/formatters.dart';
import '../utils/error_handler.dart';
import 'visualizar_recibo_screen.dart';

class HistoricoScreen extends StatefulWidget {
  const HistoricoScreen({super.key});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();
  List<ReciboModel> _recibos = [];
  List<ReciboModel> _filteredRecibos = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadRecibos();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterRecibos();
    });
  }

  void _filterRecibos() {
    if (_searchQuery.isEmpty) {
      _filteredRecibos = List.from(_recibos);
    } else {
      _filteredRecibos = _recibos.where((recibo) {
        final query = _searchQuery.toLowerCase();
        return recibo.pagador.toLowerCase().contains(query) ||
            recibo.recebedor.toLowerCase().contains(query) ||
            recibo.descricao.toLowerCase().contains(query) ||
            Formatters.formatCurrency(recibo.valor).toLowerCase().contains(query);
      }).toList();
    }
  }

  Future<void> _loadRecibos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final recibos = await _databaseService.getAllRecibos();
      setState(() {
        _recibos = recibos;
        _filterRecibos();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ErrorHandler.showError(context, e, customMessage: 'Erro ao carregar recibos');
      }
    }
  }

  Future<void> _deleteRecibo(ReciboModel recibo) async {
    if (recibo.id == null) return;

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
        () => _databaseService.deleteRecibo(recibo.id!),
        errorMessage: 'Erro ao excluir recibo',
      );
      
      if (result != null && result > 0) {
        _loadRecibos();
        if (mounted) {
          ErrorHandler.showSuccess(context, 'Recibo excluído com sucesso!');
        }
      }
    }
  }

  Future<void> _showFilters() async {
    DateTime? startDate;
    DateTime? endDate;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Filtros'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Data inicial'),
                  subtitle: Text(startDate != null
                      ? Formatters.formatDate(startDate!)
                      : 'Selecione uma data'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      locale: const Locale('pt', 'BR'),
                    );
                    if (date != null) {
                      setDialogState(() {
                        startDate = date;
                      });
                    }
                  },
                ),
                ListTile(
                  title: const Text('Data final'),
                  subtitle: Text(endDate != null
                      ? Formatters.formatDate(endDate!)
                      : 'Selecione uma data'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      locale: const Locale('pt', 'BR'),
                    );
                    if (date != null) {
                      setDialogState(() {
                        endDate = date;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setDialogState(() {
                  startDate = null;
                  endDate = null;
                });
              },
              child: const Text('Limpar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                List<ReciboModel> filtered = List.from(_recibos);

                if (startDate != null && endDate != null) {
                  filtered = await _databaseService.filterRecibosByDate(
                    startDate as DateTime,
                    endDate as DateTime,
                  );
                }

                setState(() {
                  _filteredRecibos = filtered;
                });
                Navigator.pop(context);
              },
              child: const Text('Aplicar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Recibos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
            tooltip: 'Filtros',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de busca
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar recibos...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Lista de recibos
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredRecibos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'Nenhum recibo encontrado'
                                  : 'Nenhum recibo salvo',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadRecibos,
                        child: ListView.builder(
                          itemCount: _filteredRecibos.length,
                          itemBuilder: (context, index) {
                            final recibo = _filteredRecibos[index];
                            return ReciboCardWidget(
                              recibo: recibo,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        VisualizarReciboScreen(recibo: recibo),
                                  ),
                                ).then((_) => _loadRecibos());
                              },
                              onDelete: () => _deleteRecibo(recibo),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

