
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

part 'main.g.dart';

// Data Model for a Class
@JsonSerializable()
class Class {
  final String studentName;
  final String topic;
  final DateTime date;

  Class({required this.studentName, required this.topic, required this.date});

  factory Class.fromJson(Map<String, dynamic> json) => _$ClassFromJson(json);
  Map<String, dynamic> toJson() => _$ClassToJson(this);
}

// Service to handle JSON storage
class JsonStorageService {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/classes.json');
  }

  Future<List<Class>> readClasses() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      final List<dynamic> json = jsonDecode(contents);
      return json.map((e) => Class.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> writeClasses(List<Class> classes) async {
    final file = await _localFile;
    final json = classes.map((c) => c.toJson()).toList();
    await file.writeAsString(jsonEncode(json));
  }
}

// State Management with Provider
class TuitionProvider with ChangeNotifier {
  final JsonStorageService _storageService = JsonStorageService();
  List<Class> _classes = [];

  List<Class> get classes => _classes;

  TuitionProvider() {
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    _classes = await _storageService.readClasses();
    notifyListeners();
  }

  Future<void> _saveClasses() async {
    await _storageService.writeClasses(_classes);
  }

  List<Class> getClassesForDay(DateTime day) {
    return _classes.where((c) => isSameDay(c.date, day)).toList();
  }

  void addClass(Class newClass) {
    _classes.add(newClass);
    _saveClasses();
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => TuitionProvider(),
      child: const TuitionTrackerApp(),
    ),
  );
}

class TuitionTrackerApp extends StatelessWidget {
  const TuitionTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tuition Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme),
      ),
      home: const TuitionHomePage(),
    );
  }
}

class TuitionHomePage extends StatefulWidget {
  const TuitionHomePage({super.key});

  @override
  _TuitionHomePageState createState() => _TuitionHomePageState();
}

class _TuitionHomePageState extends State<TuitionHomePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  void _showAddClassDialog() {
    final studentNameController = TextEditingController();
    final topicController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Class'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: studentNameController,
                decoration: const InputDecoration(labelText: 'Student Name'),
              ),
              TextField(
                controller: topicController,
                decoration: const InputDecoration(labelText: 'Topic'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (studentNameController.text.isNotEmpty &&
                    topicController.text.isNotEmpty) {
                  final newClass = Class(
                    studentName: studentNameController.text,
                    topic: topicController.text,
                    date: _selectedDay!,
                  );
                  Provider.of<TuitionProvider>(context, listen: false)
                      .addClass(newClass);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tuition Tracker'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) {
              return Provider.of<TuitionProvider>(context, listen: false)
                  .getClassesForDay(day);
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: Consumer<TuitionProvider>(
              builder: (context, provider, child) {
                final classesForDay = provider.getClassesForDay(_selectedDay!);
                return ListView.builder(
                  itemCount: classesForDay.length,
                  itemBuilder: (context, index) {
                    final classInfo = classesForDay[index];
                    return ListTile(
                      title: Text(classInfo.studentName),
                      subtitle: Text(classInfo.topic),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddClassDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}


