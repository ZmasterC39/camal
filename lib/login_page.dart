import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:iscocongacamal/create_user_page.dart';
import 'package:iscocongacamal/public_user_page.dart';
import 'package:iscocongacamal/admin_home_page.dart'; // Importa la página de administrador

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  late String email, password;
  final _formKey = GlobalKey<FormState>();
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Rutas UNC"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Login Page",
                style: TextStyle(color: Colors.black, fontSize: 24),
              ),
            ),
            if (error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  error,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: formulario(),
            ),
            butonLogin(),
            nuevoAqui(),
            buildOrLine(),
            BotonesGooleApple(),
          ],
        ),
      ),
    );
  }

  Widget BotonesGooleApple() {
    return Column(
      children: [
        SignInButton(Buttons.Google, onPressed: () async {
          await entrarConGoogle();
          if (FirebaseAuth.instance.currentUser != null) {
            _navigateToRoleBasedPage(FirebaseAuth.instance.currentUser!);
          }
        }),
        if (Platform.isIOS)
          SignInButton(Buttons.Apple, onPressed: () async {
            await entrarConApple();
            if (FirebaseAuth.instance.currentUser != null) {
              _navigateToRoleBasedPage(FirebaseAuth.instance.currentUser!);
            }
          }),
      ],
    );
  }

  Future<void> entrarConGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? authentication = await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: authentication?.accessToken,
      idToken: authentication?.idToken,
    );

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      await _asignarRolSiEsNuevoUsuario(userCredential.user);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        List<String> userSignInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(e.email!);
        if (userSignInMethods.contains('password')) {
          _showPasswordDialog(e.email!);
        } else {
          setState(() {
            error = "La cuenta existe con diferentes credenciales.";
          });
        }
      } else {
        setState(() {
          error = "Error al iniciar sesión con Google: ${e.message}";
        });
      }
    }
  }

  Future<void> _asignarRolSiEsNuevoUsuario(User? user) async {
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'role': 'user',
          'email': user.email,
        });
      }
    }
  }

  Future<void> _showPasswordDialog(String email) async {
    String password = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Iniciar sesión con contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (value) {
                password = value;
              },
              obscureText: true,
              decoration: InputDecoration(labelText: 'Contraseña'),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Iniciar sesión'),
            onPressed: () async {
              Navigator.of(context).pop();
              await loginWithPassword(email, password);
            },
          ),
        ],
      ),
    );
  }

  Future<void> loginWithPassword(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!userCredential.user!.emailVerified) {
        setState(() {
          error = "Debes verificar tu correo antes de acceder.";
        });
        return;
      }

      _navigateToRoleBasedPage(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = e.message ?? "Error desconocido";
      });
    }
  }

  Future<UserCredential> entrarConApple() async {
    final rawNonce = generateNonce();
    final nonce = sha256toString(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    final authCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(authCredential);
    await _asignarRolSiEsNuevoUsuario(userCredential.user);
    return userCredential;
  }

  String sha256toString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Widget buildOrLine() {
    return const FractionallySizedBox(
      widthFactor: 0.6,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: Divider()),
          Text("ó"),
          Expanded(child: Divider()),
        ],
      ),
    );
  }

  Widget nuevoAqui() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Nuevo aquí"),
        TextButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => CreateUserPage()));
          },
          child: const Text("Registrarse"),
        ),
      ],
    );
  }

  Widget formulario() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildEmail(),
          const Padding(padding: EdgeInsets.only(top: 12)),
          buildPassword(),
        ],
      ),
    );
  }

  Widget buildEmail() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Correo",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      onSaved: (String? value) {
        email = value!;
      },
      validator: (value) {
        if (value!.isEmpty) {
          return "Este campo es obligatorio";
        }
        return null;
      },
    );
  }

  Widget buildPassword() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Password",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
      obscureText: true,
      validator: (value) {
        if (value!.isEmpty) {
          return "Este campo es obligatorio";
        }
        return null;
      },
      onSaved: (String? value) {
        password = value!;
      },
    );
  }

  Widget butonLogin() {
    return FractionallySizedBox(
      widthFactor: 0.6,
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            UserCredential? credenciales = await login(email, password);
            if (credenciales != null && credenciales.user != null) {
              if (credenciales.user!.emailVerified) {
                _navigateToRoleBasedPage(credenciales.user!);
              } else {
                setState(() {
                  error = "Debes verificar tu correo antes de acceder.";
                });
              }
            }
          }
        },
        child: const Text("Login"),
      ),
    );
  }

  Future<UserCredential?> login(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!userCredential.user!.emailVerified) {
        setState(() {
          error = "Debes verificar tu correo antes de acceder.";
        });
        return null;
      }

      _navigateToRoleBasedPage(userCredential.user!);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = e.message ?? "Error desconocido";
      });
      return null;
    }
  }

  void _navigateToRoleBasedPage(User user) async {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    String role = docSnapshot['role'];

    if (role == 'admin') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => AdminHomePage()),
            (Route<dynamic> route) => false,
      );
    } else if (role == 'manager') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => AdminHomePage()),
            (Route<dynamic> route) => false,
      );
    } else if (role == 'supervisor') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => AdminHomePage()),
            (Route<dynamic> route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => PublicUserPage()),
            (Route<dynamic> route) => false,
      );
    }
  }

}
