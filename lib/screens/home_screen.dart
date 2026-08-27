import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/dds_provider.dart';
import 'collaborators_screen.dart';
import 'dds_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<String> _months = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DdsProvider>();
    final dayNames = ['Segunda-Feira', 'Terça-Feira', 'Quarta-Feira', 'Quinta-Feira', 'Sexta-Feira'];

    final List<int> years = List.generate(2040 - 2024 + 1, (index) => 2024 + index);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text('Agenda DDS'),
        backgroundColor: const Color(0xFF1A2530),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 📅 CABEÇALHO DA TELA
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1A2530),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Dropdown do Ano
                    SizedBox(
                      width: 150,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            value: provider.selectedMonth.year,
                            dropdownColor: const Color(0xFF1A2530),
                            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                            items: years.map((int year) {
                              return DropdownMenuItem<int>(
                                value: year,
                                child: Text('$year'),
                              );
                            }).toList(),
                            onChanged: (int? newYear) {
                              if (newYear != null) {
                                provider.setMonthAndYear(newYear, provider.selectedMonth.month);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Dropdown do Mês
                    SizedBox(
                      width: 250,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            value: provider.selectedMonth.month,
                            dropdownColor: const Color(0xFF1A2530),
                            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                            items: List.generate(12, (index) {
                              return DropdownMenuItem<int>(
                                value: index + 1,
                                child: Text(
                                  _months[index],
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }),
                            onChanged: (int? newMonth) {
                              if (newMonth != null) {
                                provider.setMonthAndYear(provider.selectedMonth.year, newMonth);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Lista de Semanas
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(provider.numberOfWeeks, (index) {
                            final isSelected = provider.selectedWeekIndex == index;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text('Semana ${index + 1}'),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) provider.setWeekIndex(index);
                                },
                                selectedColor: const Color(0xFF00A86B),
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black87,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      icon: const Icon(Icons.people_alt_outlined, color: Colors.white, size: 20),
                      label: const Text(
                        'Colaboradores',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CollaboratorsScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.currentWeekTopics.length,
              itemBuilder: (context, index) {
                final topic = provider.currentWeekTopics[index];
                final dayLabel = dayNames[index];
                final isPendingTopic = topic.title == 'Definir Tema...';

                return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: const Color.fromARGB(255, 1, 25, 67),
                    foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                    child: const Icon(Icons.calendar_today),
                  ),
                  title: Text(
                    '$dayLabel - ${DateFormat('dd/MM').format(topic.date)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      topic.title,
                      style: TextStyle(
                        color: isPendingTopic ? Colors.grey.shade500 : Colors.grey.shade800,
                        fontSize: 13,
                        fontStyle: isPendingTopic ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DdsDetailScreen(topic: topic),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
 }
}