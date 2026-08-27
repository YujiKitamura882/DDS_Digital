import 'package:flutter/material.dart';
import '../models/employee_model.dart';

class EmployeeSignatureTile extends StatelessWidget {
  final Employee employee;
  final bool isSigned;
  final VoidCallback onSignPressed;
  final VoidCallback? onDeletePressed;

  const EmployeeSignatureTile({
    super.key,
    required this.employee,
    required this.isSigned,
    required this.onSignPressed,
    this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Matrícula: ${employee.id} | Função: ${employee.role}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSigned) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF00A86B)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Assinado',
                      style: TextStyle(
                        color: Color(0xFF00A86B),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.check_box_rounded,
                      color: Color(0xFF00A86B),
                      size: 16,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                tooltip: 'Excluir assinatura',
                onPressed: onDeletePressed,
              ),
            ],
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              tooltip: isSigned ? 'Editar assinatura' : 'Assinar',
              onPressed: onSignPressed,
            ),
          ],
        ),
      ),
    );
  }
}