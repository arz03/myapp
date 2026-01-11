
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

// Data Model for a Class
class Class {
  final String studentName;
  final String topic;
  final DateTime date;

  Class({required this.studentName, required this.topic, required this.date});
}

// State Management with Provider
class TuitionProvider with ChangeNotifier {
  final List<Class> _classes = [];

  List<Class> get classes => _classes;

  List<Class> getClassesForDay(DateTime day) {
    return _classes.where((c) => isSameDay(c.date, day)).toList();
  }

  void addClass(Class newClass) {
    _classes.add(newClass);
    notifyListeners();
  }
}

void main() {
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
              return Provider.of<TuitionProvider>(context, listen: false).getClassesForDay(day);
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
