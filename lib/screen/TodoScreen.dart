import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cloudtaskmanager/handlers/userHandler.dart';
import 'package:cloudtaskmanager/handlers/dataHandler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userEmail;
  List<Todo> todos = [];
  
  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getData();
    });
  }
  
  Future<void> getData() async{
    todos = await HandleTodoFromStore.getAllEntries("mydata", userEmail ?? '' );
    setState(() {});
  }

  Future<void> onAddOrUpdateTab({required bool isAdd, Todo? todo, int? index, required String email}) async {
    TextEditingController taskController = TextEditingController();

    if(!isAdd){
      taskController.text = todo!.task;
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text( isAdd? "추가하기": "수정하기" ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: taskController,
                decoration: InputDecoration(
                  labelText: "Task",
                ),
              )
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text("Cancel"),),
            TextButton(
              onPressed: () async {
                if(taskController.text.trim().isEmpty){
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Task cannot be empty"),
                      duration: Duration(
                        seconds: 1
                      ),
                    )
                  );
                  return;
                }
                if(isAdd){
                  Todo newTodo = Todo(
                      id: '',
                      task: taskController.text,
                      email: email
                  );
                  newTodo = await HandleTodoFromStore.addEntryWithAutoGenerateId("mydata", newTodo);
                  setState(() {
                    todos.add(newTodo);
                  });
                }else{
                  Todo updatedTodo = Todo(
                    id: todo!.id,
                    task: taskController.text,
                    email: email
                  );
                  await HandleTodoFromStore.updateEntryWithId("mydata", updatedTodo);
                  setState(() {
                    todos[index!] = updatedTodo;
                  });
                }
              },
              child: Text(isAdd ? "Add" : "Edit" ),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    userEmail = userProvider.user?.email;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${userProvider.user?.email}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          ElevatedButton.icon(
            icon: Icon(Icons.logout),
            label: Text('Logout'),
            onPressed: () async {
              await userProvider.signOut();
            },
          )
        ],
      ), 
      body:ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return Container(
            margin: EdgeInsets.only(left: 8,right: 8, top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.grey,
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: Offset(0, 2),
                )
              ]
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Text(
                    '${ index+ 1 }',
                    style: TextStyle(color: Colors.white ),
                  ),
                ),
                title: Text(todo.task),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () async {
                        onAddOrUpdateTab(isAdd: false, todo: todo, index: index, email: userEmail ?? '');
                      },
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.edit,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        await HandleTodoFromStore.deleteEntryWithId("mydata", todo.id);
                        setState(() {
                          todos.removeAt(index);
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => onAddOrUpdateTab( isAdd: true, email : userProvider.user?.email ?? '' ),
      ),
    );
  }
}
