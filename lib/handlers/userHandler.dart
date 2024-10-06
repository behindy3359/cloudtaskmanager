import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum Status {
  uninitialized, authenticated, authenticating, unauthenticated
}

class UserProvider extends ChangeNotifier {
  final FirebaseAuth _auth;
  Status _status = Status.uninitialized;
  User? _user;

  Status get status => _status;
  User? get user => _user;

  UserProvider()
    : _auth = FirebaseAuth.instance,
      _user = FirebaseAuth.instance.currentUser,
      _status = FirebaseAuth.instance.currentUser != null
        ? Status.authenticated
        : Status.unauthenticated{
    _auth.authStateChanges().listen(_onStateChanged);
  }

  Future<String> signUp(String email, String password) async {
    try{
      _status = Status.authenticating;
      notifyListeners();
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return 'Success';
    } on FirebaseAuthException catch (e) {
      _status = Status.unauthenticated;
      notifyListeners();
      if(e.message!.contains("weak-password")){
        return "취약한 비밀번호 입니다.";
      }else if( e.message!.contains("email-already-in-use")){
        return "이미 사용중인 이메일 입니다.";
      }else{
        return e.toString();
      }
    }catch(e){
      return e.toString();
    }
  }

  Future<String> signIn(String email, String password) async{
    try{
      _status = Status.authenticating;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return "Success";
    }on FirebaseAuthException catch(e){
      _status = Status.unauthenticated;
      notifyListeners();
      if(e.message!.contains("user-not-found")){
        return "해당하는 유저를 찾을 수 없습니다.";
      }else if(e.message!.contains("wrong-password")){
        return "비밀번호가 틀렸습니다.";
      }else{
        return e.toString();
      }
    }catch(e){
      return e.toString();
    }
  }

  Future<void> signOut() async{
    await _auth.signOut();
    _status = Status.unauthenticated;
    notifyListeners();
  }

  Future<void> _onStateChanged(User? user) async {
    if (user == null) {
      _status = Status.unauthenticated;
    } else {
      _status = Status.authenticated;
      _user = user;
    }
    notifyListeners();
  }
}