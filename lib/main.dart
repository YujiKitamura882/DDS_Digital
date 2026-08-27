import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/dds_provider.dart';
import 'providers/employee_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final employeeProvider = EmployeeProvider();
  final ddsProvider = DdsProvider();

  await employeeProvider.loadEmployees();
  await ddsProvider.loadTopics();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: employeeProvider),
        ChangeNotifierProvider.value(value: ddsProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema DDS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}