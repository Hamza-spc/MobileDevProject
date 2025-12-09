import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SuiviDossierScreen extends StatefulWidget {
  final String token;
  final String email;
  SuiviDossierScreen({required this.token, required this.email});
  @override
  State<SuiviDossierScreen> createState() => _SuiviDossierScreenState();
}

class _SuiviDossierScreenState extends State<SuiviDossierScreen> {
  Map<String, dynamic>? etudiant;
  Map<String, dynamic>? registration;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchStatutDossier();
  }

  Future<void> fetchStatutDossier() async {
    setState(() { loading = true; error=null; });
    try {
      final uriReg = Uri.parse('http://localhost:8000/api/etudiant/statut?email=${Uri.encodeComponent(widget.email)}');
      final resp = await http.get(uriReg, headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Accept': 'application/json',
      });
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        registration = data['registration'];
        etudiant = data['student'];
        setState(() { loading = false; });
      } else {
        setState(() { error = resp.body; loading = false; });
      }
    } catch (e) {
      setState(() { error = e.toString(); loading = false; });
    }
  }

  Widget statutBadge(String statut) {
    Color color = Colors.orange;
    if (statut == 'approved') color = Colors.green;
    if (statut == 'rejected') color = Colors.red;
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 8,vertical: 4),
        decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(12)
        ),
        child: Text(statut, style: TextStyle(color: color))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Suivi de mon dossier'), leading: BackButton()),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : registration==null
            ? Center(child: Text(error!=null ? 'Erreur : $error' : "Aucun dossier trouvé."))
            : Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nom: ${etudiant?['first_name']??''} ${etudiant?['last_name']??''}', style:TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text('Filière: ${registration?['program']??''}', style:TextStyle(fontSize: 16)),
                    Text('Niveau: ${registration?['level']??''}', style:TextStyle(fontSize: 16)),
                    SizedBox(height:8),
                    Row(children:[
                      Text('Statut: ', style:TextStyle(fontSize: 16)),
                      statutBadge(registration?['status']??''),
                    ]),
                    if((registration?['status']??'')=='rejected' && (registration?['notes']??'')!='')
                      Padding(
                        padding: EdgeInsets.only(top:12),
                        child:Text('Motif : ${registration?['notes']}', style:TextStyle(color:Colors.red)),
                      ),
                  ],
                ),
              ),
    );
  }
}
