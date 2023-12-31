import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ToDoApp());
}

class ToDoApp extends StatelessWidget {
  const ToDoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.from(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
      home: const ToDoList(title: 'Todo app'),
    );
  }
}

class ToDoList extends StatefulWidget {
  const ToDoList({super.key, required this.title});

  final String title;

  @override
  State<ToDoList> createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  late List<ToDo> _todos = <ToDo>[];
  final TextEditingController _textFieldController = TextEditingController();
  late SharedPreferences _prefs;

  void initState() {
    super.initState();
    _loadPrefs();
  }

  void _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    final List<String>? todos = _prefs.getStringList('todos');
    final List<String>? todosState = _prefs.getStringList('todosState');
    final List<bool> todosCompleted =
        todosState?.map((state) => state == 'true').toList() ?? [];
    for (var e = 0; e < todos!.length; e++) {
      _todos.add(ToDo(name: todos[e], completed: todosCompleted[e]));
    }
    setState(() {});
  }

  void _saveTodos() {
    _prefs.setStringList('todos', _todos.map((todo) => todo.name).toList());
    setState(() {});
  }

  void _saveTodosState() {
    _prefs.setStringList(
        'todosState', _todos.map((todo) => todo.completed.toString()).toList());
    setState(() {});
  }

  void _addTodoItem(String name) {
    setState(() {
      _todos.add(ToDo(name: name, completed: false));
    });
    _saveTodos();
    _textFieldController.clear();
  }

  void _handleTodoChange(ToDo todo) {
    setState(() {
      todo.completed = !todo.completed;
    });
    _saveTodosState();
  }

  void _deleteTodo(ToDo todo) {
    setState(() {
      _todos.removeWhere((element) => element.name == todo.name);
    });
    _saveTodos();
    _saveTodosState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.title)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: _todos.map((ToDo todo) {
          return TodoItem(
            todo: todo,
            onTodoChanged: _handleTodoChange,
            removeTodo: _deleteTodo,
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _displayDialog(),
        tooltip: 'Add a ToDo',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _displayDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a todo'),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: 'Type your todo'),
            autofocus: true,
          ),
          actions: <Widget>[
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                _addTodoItem(_textFieldController.text);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class ToDo {
  ToDo({required this.name, required this.completed});
  String name;
  bool completed;
}

class TodoItem extends StatelessWidget {
  TodoItem(
      {required this.todo,
      required this.onTodoChanged,
      required this.removeTodo})
      : super(key: ObjectKey(todo));

  final void Function(ToDo todo) removeTodo;
  final ToDo todo;
  final void Function(ToDo todo) onTodoChanged;

  TextStyle? _getTextStyle(bool checked) {
    if (!checked) return TextStyle(color: Colors.black54, fontSize: 20);

    return const TextStyle(
      color: Colors.black54,
      fontSize: 20,
      decoration: TextDecoration.lineThrough,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        onTodoChanged(todo);
      },
      leading: Checkbox(
        value: todo.completed,
        onChanged: (value) {
          onTodoChanged(todo);
        },
      ),
      title: Row(children: <Widget>[
        Expanded(
          child: Text(todo.name, style: _getTextStyle(todo.completed)),
        ),
        IconButton(
          iconSize: 25,
          icon: Icon(
            Icons.delete,
            color: Colors.red[300],
          ),
          alignment: Alignment.centerRight,
          onPressed: () {
            removeTodo(todo);
          },
        ),
      ]),
    );
  }
}
