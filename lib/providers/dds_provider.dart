import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dds_model.dart';

class DdsProvider extends ChangeNotifier {
  DateTime _selectedMonth = DateTime.now();
  int _selectedWeekIndex = 0;

  final Map<String, List<List<DateTime>>> _monthWeeksMap = {};
  final Map<String, DdsTopic> _topicsDB = {};
  static const String _storageKey = 'dds_topics_data';

  DateTime get selectedMonth => _selectedMonth;
  int get selectedWeekIndex => _selectedWeekIndex;

  int get numberOfWeeks {
    final key = _getMonthKey(_selectedMonth);
    return _monthWeeksMap[key]?.length ?? 0;
  }

  DdsProvider() {
    _generateAllWeeksFixed();
    _initializeCurrentMonth();
  }

  String _getMonthKey(DateTime date) {
    return DateFormat('yyyy-MM').format(date);
  }

  Future<void> loadTopics() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey);
    if (data != null) {
      final Map<String, dynamic> jsonMap = jsonDecode(data);
      jsonMap.forEach((key, value) {
        _topicsDB[key] = DdsTopic.fromJson(value);
      });
      notifyListeners();
    }
  }

  Future<void> _saveTopics() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> jsonMap = {};
    _topicsDB.forEach((key, value) {
      jsonMap[key] = value.toJson();
    });
    await prefs.setString(_storageKey, jsonEncode(jsonMap));
  }

  void _generateAllWeeksFixed() {
    for (int year = 2024; year <= 2040; year++) {
      for (int month = 1; month <= 12; month++) {
        final monthDate = DateTime(year, month, 1);
        final monthKey = _getMonthKey(monthDate);
        _monthWeeksMap[monthKey] = [];

        DateTime firstDayOfMonth = DateTime(year, month, 1);
        DateTime lastDayOfMonth = DateTime(year, month + 1, 0);

        int offset = firstDayOfMonth.weekday - DateTime.monday;
        DateTime currentMonday = firstDayOfMonth.subtract(Duration(days: offset));

        while (currentMonday.isBefore(lastDayOfMonth) || currentMonday.isAtSameMomentAs(lastDayOfMonth)) {
          List<DateTime> weekDays = [];
          int daysInTargetMonth = 0;

          for (int i = 0; i < 5; i++) {
            DateTime day = currentMonday.add(Duration(days: i));
            weekDays.add(day);

            if (day.month == month && day.year == year) {
              daysInTargetMonth++;
            }
          }

          if (daysInTargetMonth >= 3) {
            _monthWeeksMap[monthKey]!.add(weekDays);
          }

          currentMonday = currentMonday.add(const Duration(days: 7));
        }
      }
    }
  }

  void _initializeCurrentMonth() {
    final now = DateTime.now();
    setMonthAndYear(now.year, now.month);
  }

  void setMonthAndYear(int year, int month) {
    _selectedMonth = DateTime(year, month, 1);

    final now = DateTime.now();
    final monthKey = _getMonthKey(_selectedMonth);
    final weeks = _monthWeeksMap[monthKey] ?? [];

    if (now.year == year && now.month == month) {
      int foundIndex = -1;
      for (int w = 0; w < weeks.length; w++) {
        if (weeks[w].any((d) => d.year == now.year && d.month == now.month && d.day == now.day)) {
          foundIndex = w;
          break;
        }
      }
      _selectedWeekIndex = foundIndex != -1 ? foundIndex : 0;
    } else {
      _selectedWeekIndex = 0;
    }

    notifyListeners();
  }

  void setWeekIndex(int index) {
    if (index >= 0 && index < numberOfWeeks) {
      _selectedWeekIndex = index;
      notifyListeners();
    }
  }

  List<DdsTopic> get currentWeekTopics {
    final monthKey = _getMonthKey(_selectedMonth);
    final weeks = _monthWeeksMap[monthKey];

    if (weeks == null || weeks.isEmpty || _selectedWeekIndex >= weeks.length) {
      return [];
    }

    List<DateTime> currentWeekDays = weeks[_selectedWeekIndex];
    List<DdsTopic> weekTopics = [];

    for (DateTime day in currentWeekDays) {
      String key = DateFormat('yyyy-MM-dd').format(day);

      if (!_topicsDB.containsKey(key)) {
        _topicsDB[key] = DdsTopic(
          id: key,
          date: day,
          title: 'Definir Tema...',
          category: 'Geral',
          content: 'Adicione um conteúdo para este DDS.',
        );
      }
      weekTopics.add(_topicsDB[key]!);
    }

    return weekTopics;
  }

  void updateTopic(DdsTopic updatedTopic) {
    _topicsDB[updatedTopic.id] = updatedTopic;
    _saveTopics();
    notifyListeners();
  }

  void removeSignature(String ddsId, String employeeId) {
  if (_topicsDB.containsKey(ddsId)) {
    final topic = _topicsDB[ddsId]!;
    topic.signatures.removeWhere((sig) => sig.id == employeeId);
    
    if (topic.signatures.isEmpty) {
      topic.isCompleted = false;
    }
    
    _saveTopics();
    notifyListeners();
  }
}

  void addSignature(String ddsId, AttendanceRecord record) {
    if (_topicsDB.containsKey(ddsId)) {
      final topic = _topicsDB[ddsId]!;
      
      topic.signatures.removeWhere((sig) => sig.id == record.id);
      topic.signatures.add(record);
      topic.isCompleted = true;
      
      _saveTopics();
      notifyListeners();
    }
  }

  DdsTopic? getTopicById(String ddsId) {
    return _topicsDB[ddsId];
  }

  bool hasEmployeeSigned(String ddsId, String employeeId) {
    if (!_topicsDB.containsKey(ddsId)) return false;
    return _topicsDB[ddsId]!.signatures.any((record) => record.id == employeeId);
  }
}