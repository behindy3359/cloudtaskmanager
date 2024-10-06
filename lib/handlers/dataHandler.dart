import 'package:cloud_firestore/cloud_firestore.dart';

class HandleTodoFromStore{

  static Future<List<Todo>> getAllEntries(String collection, String email) async{
    var collectionReference = FirebaseFirestore.instance.collection(collection);
    var querySnapshot = await collectionReference.where('email', isEqualTo: email).get();

    List<Todo> todos = querySnapshot.docs.map((doc) {
      return Todo(
        id : doc.id,
        task : doc.data()['task'],
        email : email,
      );
    }).toList();

    return todos;
  }

  static Future<Todo> addEntryWithAutoGenerateId(String collection, Todo todo) async {
    var collectionReference = FirebaseFirestore.instance.collection(collection);
    var docRef = await collectionReference.add(todo.toMap());

    Todo newTodo = Todo(
      id: docRef.id,
      task : todo.task,
      email : todo.email,
    );

    return newTodo;
  }

  static Future<void> updateEntryWithId(String collection, Todo todo) async{
    var docRef = FirebaseFirestore.instance.collection(collection).doc(todo.id);
    await docRef.update(todo.toMap());
  }

  static Future<void> deleteEntryWithId(String collection, String documentId) async{
    var docRef = FirebaseFirestore.instance.collection(collection).doc(documentId);
    await docRef.delete();
  }
}

class Todo{
  Todo({required this.id, required this.task, required this.email});

  final String id;
  final String task;
  final String email;

  Map<String, dynamic> toMap() => {"id" : id, "task" : task, "email": email};
}