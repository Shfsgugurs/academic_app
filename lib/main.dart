import 'package:flutter/material.dart';
void main() => runApp(AcademicApp());
// --- Data Model ---
class Task {
  String subject;
  String time;
  bool isDone;
  Task({required this.subject, required this.time, this.isDone = false});
}
// --- Main Application ---
class AcademicApp extends StatefulWidget {
  @override
  _AcademicAppState createState() => _AcademicAppState();
}
class _AcademicAppState extends State<AcademicApp> {
  ThemeMode _themeMode = ThemeMode.light;
  String userName = "طالب";
  List<Task> tasks = [];
  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }
  void updateUserName(String newName) {
    if (newName.trim().isNotEmpty) {
      setState(() {
        userName = newName;
      });
    }
  }
  void addTask(Task newTask) {
    setState(() {
      tasks.add(newTask);
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: HomeScreen(
        tasks: tasks,
        toggleTheme: toggleTheme,
        themeMode: _themeMode,
        userName: userName,
        updateName: updateUserName,
        onAddTask: addTask,
      ),
    );
  }
}
// --- Home Screen (Task List) ---
class HomeScreen extends StatelessWidget {
  final List<Task> tasks;
  final VoidCallback toggleTheme;
  final ThemeMode themeMode;
  final String userName;
  final Function(String) updateName;
  final Function(Task) onAddTask;
  HomeScreen({
    required this.tasks,
    required this.toggleTheme,
    required this.themeMode,
    required this.userName,
    required this.updateName,
    required this.onAddTask,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("أهلاً $userName")),
      body: tasks.isEmpty
          ? Center(child: Text("لا توجد مهمات مضافة حالياً", style: TextStyle(fontSize: 18)))
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, i) => ListTile(
                title: Text(tasks[i].subject),
                subtitle: Text("مدة المذاكرة: ${tasks[i].time} دقيقة"),
                trailing: Icon(
                  tasks[i].isDone ? Icons.check_circle : Icons.circle_outlined,
                  color: tasks[i].isDone ? Colors.green : null,
                ),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DetailsScreen(task: tasks[i])),
                  );
                  // إعادة رسم الشاشة لتحديث حالة المهمة عند العودة
                  (context as Element).markNeedsBuild();
                },
              ),
            ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.bar_chart),
              tooltip: "الإحصائيات",
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => StatsScreen(tasks)),
              ),
            ),
            IconButton(
              icon: Icon(Icons.settings),
              tooltip: "الإعدادات",
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(
                    toggleTheme: toggleTheme,
                    themeMode: themeMode,
                    updateName: updateName,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final newTask = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddTaskScreen()),
          );
          if (newTask != null && newTask is Task) {
            onAddTask(newTask);
          }
        },
      ),
    );
  }
}
// --- Add Task Screen (Form) ---
class AddTaskScreen extends StatelessWidget {
  final _subCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("إضافة مهمة جديدة")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _subCtrl,
              decoration: InputDecoration(labelText: "اسم المادة"),
            ),
            TextFormField(
              controller: _timeCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "وقت المذاكرة (بالدقائق)"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_subCtrl.text.isNotEmpty && _timeCtrl.text.isNotEmpty) {
                  Navigator.pop(
                    context,
                    Task(subject: _subCtrl.text, time: _timeCtrl.text),
                  );
                }
              },
              child: Text("حفظ المهمة"),
            ),
          ],
        ),
      ),
    );
  }
}
// --- Details Screen ---
class DetailsScreen extends StatefulWidget {
  final Task task;
  DetailsScreen({required this.task});
  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}
class _DetailsScreenState extends State<DetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("تفاصيل المهمة")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("المادة: ${widget.task.subject}", style: TextStyle(fontSize: 24)),
            SizedBox(height: 10),
            Text("الوقت المحدد: ${widget.task.time} دقيقة", style: TextStyle(fontSize: 18)),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  widget.task.isDone = !widget.task.isDone;
                });
              },
              child: Text(widget.task.isDone ? "إلغاء الإنجاز" : "تم الإنجاز"),
            ),
          ],
        ),
      ),
    );
  }
}
// --- Stats Screen (Progress Indicator) ---
class StatsScreen extends StatelessWidget {
  final List<Task> tasks;
  StatsScreen(this.tasks);
  @override
  Widget build(BuildContext context) {
    int done = tasks.where((t) => t.isDone).length;
    double progress = tasks.isEmpty ? 0 : done / tasks.length;
    return Scaffold(
      appBar: AppBar(title: Text("الإحصائيات")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("نسبة الإنجاز: ${(progress * 100).toInt()}%", style: TextStyle(fontSize: 22)),
            SizedBox(height: 20),
            LinearProgressIndicator(value: progress, minHeight: 10),
          ],
        ),
      ),
    );
  }
}
// --- Settings Screen ---
class SettingsScreen extends StatelessWidget {
  final VoidCallback toggleTheme;
  final ThemeMode themeMode;
  final Function(String) updateName;
  SettingsScreen({
    required this.toggleTheme,
    required this.themeMode,
    required this.updateName,
  });
  @override
  Widget build(BuildContext context) {
    bool isDark = themeMode == ThemeMode.dark;
    return Scaffold(
      appBar: AppBar(title: Text("الإعدادات")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: Text("الوضع الداكن (Dark Mode)"),
              trailing: Switch(
                value: isDark,
                onChanged: (v) => toggleTheme(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: "تعديل اسم الطالب",
                border: OutlineInputBorder(),
              ),
              onSubmitted: (val) {
                updateName(val);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("تم تحديث الاسم بنجاح")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
