import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'admin_panel.dart';
import 'suivi_dossier.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool loading = false;
  bool isAdmin = false;

  Future<void> login() async {
    setState(() { loading = true; });
    final url = isAdmin
        ? Uri.parse('http://localhost:8000/api/admin/login')
        : Uri.parse('http://localhost:8000/api/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password
      })
    );
    setState(() { loading = false; });
    if (response.statusCode == 200) {
      final jsonResp = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connexion réussie.')),
      );
      if (isAdmin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminPanelFlutter(token: jsonResp['token'])),
        );
      } else {
        // étudiant : naviguer vers suivi dossier !
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SuiviDossierScreen(token: jsonResp['token'], email: email)),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connexion')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                onChanged: (v) => email = v,
                validator: (v) => v!.isEmpty ? 'Obligatoire' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
                onChanged: (v) => password = v,
                validator: (v) => v!.isEmpty ? 'Obligatoire' : null,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: isAdmin,
                    onChanged: (v) => setState(() => isAdmin = v ?? false),
                  ),
                  Text('Je suis admin'),
                ],
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: loading
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        login();
                      }
                    },
                child: loading
                    ? CircularProgressIndicator()
                    : Text('Connexion'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
