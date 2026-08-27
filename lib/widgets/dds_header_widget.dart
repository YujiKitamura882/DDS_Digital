import 'package:flutter/material.dart';
import '../models/dds_model.dart';

class DdsHeaderWidget extends StatelessWidget {
  final DdsTopic topic;
  final bool isEditing;
  final TextEditingController titleController;
  final TextEditingController contentController;
  final int signedCount;
  final int totalEmployees;
  final VoidCallback onEditPressed;
  final VoidCallback onSavePressed;
  final VoidCallback onCancelPressed;

  const DdsHeaderWidget({
    super.key,
    required this.topic,
    required this.isEditing,
    required this.titleController,
    required this.contentController,
    required this.signedCount,
    required this.totalEmployees,
    required this.onEditPressed,
    required this.onSavePressed,
    required this.onCancelPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TEMA DO DIA',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              if (!isEditing)
                TextButton.icon(
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Editar'),
                  onPressed: onEditPressed,
                ),
            ],
          ),
          const SizedBox(height: 8),

          if (isEditing) ...[
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Título do Tema',
                hintText: 'Definir Tema...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Conteúdo / Descrição do DDS',
                hintText: 'Adicione um conteúdo para este DDS.',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            
            // Linha com os botões de Cancelar e Salvar
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Botão de Cancelar
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 2, 2),
                    foregroundColor: const Color.fromARGB(255, 251, 249, 249),
                    side: BorderSide(color: const Color.fromARGB(255, 255, 0, 0)),
                  ),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Cancelar'),
                  onPressed: () {
                    titleController.clear();
                    contentController.clear();
                    FocusScope.of(context).unfocus();
                    onCancelPressed();
                  },
                ),
                const SizedBox(width: 8),

                // Botão de Salvar
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A86B),
                  ),
                  icon: const Icon(Icons.save, color: Colors.white, size: 18),
                  label: const Text('Salvar Tema', style: TextStyle(color: Colors.white)),
                  onPressed: onSavePressed,
                ),
              ],
            ),
          ] else ...[
            Text(
              topic.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: topic.title == 'Definir Tema...' ? Colors.grey : const Color(0xFF1A2530),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              topic.content,
              style: TextStyle(
                fontSize: 14,
                color: topic.content == 'Adicione um conteúdo para este DDS.'
                    ? Colors.grey
                    : Colors.grey.shade800,
              ),
            ),
          ],

          const SizedBox(height: 12),
          Text(
            'Assinaturas: ($signedCount/$totalEmployees)',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}