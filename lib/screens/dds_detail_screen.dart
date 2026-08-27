import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dds_model.dart';
import '../models/employee_model.dart';
import '../providers/dds_provider.dart';
import '../providers/employee_provider.dart';
import '../widgets/dds_header_widget.dart';
import '../widgets/employee_signature_tile.dart';
import '../widgets/signature_model.dart';

class DdsDetailScreen extends StatefulWidget {
  final DdsTopic topic;

  const DdsDetailScreen({super.key, required this.topic});

  @override
  State<DdsDetailScreen> createState() => _DdsDetailScreenState();
}

class _DdsDetailScreenState extends State<DdsDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _titleController = TextEditingController(
      text: widget.topic.title == 'Definir Tema...' ? '' : widget.topic.title,
    );
    _contentController = TextEditingController(
      text: widget.topic.content == 'Adicione um conteúdo para este DDS.'
          ? ''
          : widget.topic.content,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _openSignatureDialog(Employee employee) async {
    final result = await showDialog<List<Offset?>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SignaturePadDialog(employeeName: employee.name),
    );

    if (result != null && result.isNotEmpty && mounted) {
      final pointsData = result
          .map((p) => p != null ? {'dx': p.dx, 'dy': p.dy} : null)
          .toList();

      final record = AttendanceRecord(
        id: employee.id,
        name: employee.name,
        role: employee.role,
        signatureBase64: '',
        signedAt: DateTime.now(),
        pointsJson: jsonEncode(pointsData),
      );

      context.read<DdsProvider>().addSignature(widget.topic.id, record);
    }
  }

  void _saveTopic() {
    final newTitle = _titleController.text.trim();
    widget.topic.title = newTitle.isEmpty ? 'Definir Tema...' : newTitle;

    final newContent = _contentController.text.trim();
    widget.topic.content = newContent.isEmpty
        ? 'Adicione um conteúdo para este DDS.'
        : newContent;

    context.read<DdsProvider>().updateTopic(widget.topic);

    setState(() {
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tema salvo com sucesso!'),
        backgroundColor: Color(0xFF00A86B),
      ),
    );
  }

  void _cancelEditing() {
    _initControllers();
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final employees = context.watch<EmployeeProvider>().employees;
    final ddsProvider = context.watch<DdsProvider>();
    final currentTopic =
        ddsProvider.getTopicById(widget.topic.id) ?? widget.topic;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text('Detalhes do DDS'),
        backgroundColor: const Color(0xFF1A2530),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          DdsHeaderWidget(
            topic: currentTopic,
            isEditing: _isEditing,
            titleController: _titleController,
            contentController: _contentController,
            signedCount: currentTopic.signatures.length,
            totalEmployees: employees.length,
            onEditPressed: () {
              _initControllers();
              setState(() => _isEditing = true);
            },
            onSavePressed: _saveTopic,
            onCancelPressed: _cancelEditing,
          ),
          const Divider(height: 1),
          Expanded(
            child: employees.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum colaborador cadastrado.\nCadastre na tela de Colaboradores.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: employees.length,
                    itemBuilder: (context, index) {
                      final emp = employees[index];
                      final isSigned = currentTopic.signatures.any(
                        (sig) => sig.id == emp.id,
                      );

                      return EmployeeSignatureTile(
                        employee: emp,
                        isSigned: isSigned,
                        onSignPressed: () => _openSignatureDialog(emp),
                        onDeletePressed: () {
                          context.read<DdsProvider>().removeSignature(
                            widget.topic.id,
                            emp.id,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
