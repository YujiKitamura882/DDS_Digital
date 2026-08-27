import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/employee_model.dart';
import '../providers/employee_provider.dart';

class CollaboratorsScreen extends StatelessWidget {
  const CollaboratorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeeProvider>();
    final employees = provider.employees;

    List<List<Employee>> columns = [];
    for (var i = 0; i < employees.length; i += 10) {
      columns.add(
        employees.sublist(i, i + 10 > employees.length ? employees.length : i + 10),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: Text('Colaboradores (${employees.length})'),
        backgroundColor: const Color(0xFF1A2530),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF00A86B),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Novo Colaborador', style: TextStyle(color: Colors.white)),
        onPressed: () => _showEmployeeDialog(context),
      ),
      body: employees.isEmpty
          ? const Center(
              child: Text(
                'Nenhum colaborador cadastrado.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: columns.map((columnItems) {
                    return Container(
                      width: 320,
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              'Coluna (${columnItems.length}/10)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          ...columnItems.map((emp) => _buildEmployeeCard(context, emp)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
    );
  }

  Widget _buildEmployeeCard(BuildContext context, Employee employee) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        title: Text(
          employee.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text('Matrícula: ${employee.registration} | Função: ${employee.role}'),
            Text(
              'Admissão: ${dateFormat.format(employee.admissionDate)}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
              onPressed: () => _showEmployeeDialog(context, employee: employee),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 18, color: Colors.red),
              onPressed: () => _confirmDelete(context, employee),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmployeeDialog(BuildContext context, {Employee? employee}) {
  final isEditing = employee != null;
  final nameController = TextEditingController(text: employee?.name ?? '');
  final regController = TextEditingController(text: employee?.registration ?? '');

  final List<String> roles = [
    'Analista Gestão Estoque I',
    'Analista Logístico II',
    'Analista Qualidade PL',
    'Analista Site',
    'Aprendiz',
    'Assistente Logístico I',
    'Auxiliar Operacional II',
    'Auxiliar Operacional II p/h',
    'Controlador Estoque I',
    'Fiscal de Prevenção',
    'Líder Manutenção',
    'Líder Operações',
    'Técnico Manutenção',
  ];

  String selectedRole = (employee != null && roles.contains(employee.role))
      ? employee.role
      : roles.first;

  DateTime selectedDate = employee?.admissionDate ?? DateTime.now();
  
  // Variável para controlar a mensagem de erro interna do modal
  String? errorMessage;

  showDialog(
    context: context,
    builder: (dialogCtx) {
      return StatefulBuilder(
        builder: (context, setStateModal) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(isEditing ? 'Editar Colaborador' : 'Novo Colaborador'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nome Completo'),
                    onChanged: (_) {
                      if (errorMessage != null) {
                        setStateModal(() => errorMessage = null);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: regController,
                    decoration: const InputDecoration(labelText: 'Matrícula'),
                    onChanged: (_) {
                      if (errorMessage != null) {
                        setStateModal(() => errorMessage = null);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Função / Cargo',
                      border: UnderlineInputBorder(),
                    ),
                    isExpanded: true,
                    items: roles.map((String role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(role, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setStateModal(() {
                          selectedRole = newValue;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Admissão: ${DateFormat('dd/MM/yyyy').format(selectedDate)}'),
                      TextButton(
                        child: const Text('Alterar Data'),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(1970),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setStateModal(() {
                              selectedDate = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  // Banner de erro interno no modal
                  if (errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              errorMessage!,
                              style: TextStyle(color: Colors.red.shade800, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A86B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  final name = nameController.text.trim();
                  final reg = regController.text.trim();

                  if (name.isEmpty || reg.isEmpty) {
                    setStateModal(() {
                      errorMessage = 'Preencha todos os campos obrigatórios.';
                    });
                    return;
                  }

                  final provider = context.read<EmployeeProvider>();

                  // Validação de duplicidade de Nome
                  final nameExists = provider.employees.any((emp) =>
                      emp.name.toLowerCase() == name.toLowerCase() &&
                      (!isEditing || emp.id != employee.id));

                  if (nameExists) {
                    setStateModal(() {
                      errorMessage = 'Já existe um colaborador cadastrado com o nome "$name".';
                    });
                    return;
                  }

                  // Validação de duplicidade de Matrícula
                  final regExists = provider.employees.any((emp) =>
                      emp.registration.toLowerCase() == reg.toLowerCase() &&
                      (!isEditing || emp.id != employee.id));

                  if (regExists) {
                    setStateModal(() {
                      errorMessage = 'Já existe um colaborador cadastrado com a matrícula "$reg".';
                    });
                    return;
                  }

                  final updatedEmployee = Employee(
                    id: isEditing ? employee.id : DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    registration: reg,
                    admissionDate: selectedDate,
                    role: selectedRole,
                  );

                  if (isEditing) {
                    provider.updateEmployee(updatedEmployee);
                  } else {
                    provider.addEmployee(updatedEmployee);
                  }
                  Navigator.pop(dialogCtx);
                },
                child: const Text('Salvar', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    },
  );
}

  void _confirmDelete(BuildContext context, Employee employee) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Excluir Colaborador'),
        content: Text('Deseja realmente remover ${employee.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<EmployeeProvider>().removeEmployee(employee.id);
              Navigator.pop(dialogCtx);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}