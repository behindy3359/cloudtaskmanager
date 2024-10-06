import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'package:cloudtaskmanager/screen/AuthenticationScreen.dart';
import 'package:cloudtaskmanager/handlers/userHandler.dart';
import 'package:cloudtaskmanager/screen/TodoScreen.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
         home: Consumer<UserProvider>(
           builder:
             (context, user, child) => user.status == Status.authenticated
               ? HomeScreen()
               : AuthenticationScreen()
         ),
      ),
    );
  }
}


