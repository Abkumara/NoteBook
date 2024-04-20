import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

final _firebase = FirebaseAuth.instance;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _form = GlobalKey<FormState>();
  var _eneterUser = '';
  var _enterPassword = '';
  var _isAuthenticating = false;
  var _isLogin = true;
  var _enterUserEmail = '';

  void submit() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();
    print('$_eneterUser $_enterPassword');

    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (!_isLogin) {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: _enterUserEmail, password: _enterPassword);
        print(userCredentials);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({'username': _eneterUser, 'userEmail': _enterUserEmail});
      } else {
        final userCredentials = await _firebase.signInWithEmailAndPassword(
            email: _enterUserEmail, password: _enterPassword);
        print(userCredentials);
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        print('Alreay use that email');
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.message ?? 'Authentication failed')));
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _form,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isLogin)
              TextFormField(
                decoration: const InputDecoration(hintText: 'User Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Invalid User';
                  }
                  return null;
                },
                onSaved: (newValue) {
                  _eneterUser = newValue!;
                },
              ),
            TextFormField(
              decoration: const InputDecoration(hintText: 'User Email'),
              validator: (value) {
                if (value == null || value.isEmpty || !value.contains('@')) {
                  return 'Invalid User Email';
                }
                return null;
              },
              onSaved: (newValue) {
                _enterUserEmail = newValue!;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Password',
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty || value.length < 6) {
                  return 'Invalid Password';
                }
                return null;
              },
              onSaved: (newValue) {
                _enterPassword = newValue!;
              },
            ),
            if (_isAuthenticating) const CircularProgressIndicator(),
            if (!_isAuthenticating)
              ElevatedButton(
                onPressed: submit,
                child: Text(_isLogin ? 'Login' : 'Sign Up'),
              ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin;
                });
              },
              child: Text(
                  _isLogin ? 'Create New Account' : 'Already have an Account'),
            ),
          ],
        ),
      ),
    ));
  }
}
