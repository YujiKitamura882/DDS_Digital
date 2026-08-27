import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/employee_model.dart';

class EmployeeProvider extends ChangeNotifier {
  List<Employee> _employees = [];
  static const String _storageKey = 'employees_data';

  // Retorna a lista garantindo a ordenação alfabética pelo nome
  List<Employee> get employees {
    _employees.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return _employees;
  }

  EmployeeProvider() {
    loadEmployees();
  }

  // Carrega os colaboradores salvos e os ordena
  Future<void> loadEmployees() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey);
    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      _employees = jsonList.map((e) => Employee.fromJson(e)).toList();
      
      // Ordena a lista após carregar do storage
      _employees.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      notifyListeners();
    }
  }

  // Salva os dados no SharedPreferences
  Future<void> _saveEmployees() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(_employees.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  // Adiciona um novo colaborador e reordena a lista
  void addEmployee(Employee employee) {
    _employees.add(employee);
    _employees.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    _saveEmployees();
    notifyListeners();
  }

  // Remove um colaborador
  void removeEmployee(String id) {
    _employees.removeWhere((emp) => emp.id == id);
    _saveEmployees();
    notifyListeners();
  }

  // Atualiza um colaborador e reordena caso o nome mude
  void updateEmployee(Employee updatedEmployee) {
    final index = _employees.indexWhere((emp) => emp.id == updatedEmployee.id);
    if (index != -1) {
      _employees[index] = updatedEmployee;
      _employees.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      _saveEmployees();
      notifyListeners();
    }
  }
}