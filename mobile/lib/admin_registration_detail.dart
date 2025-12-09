import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminRegistrationDetail extends StatefulWidget {
  final Map registration;
  final String token;
  AdminRegistrationDetail({required this.registration, required this.token});
  @override
  State<AdminRegistrationDetail> createState() => _AdminRegistrationDetailState();
}

class _AdminRegistrationDetailState extends State<AdminRegistrationDetail> {
  late Map reg;
  late Map student;
  late List docs;
  String statut = 'pending';
  TextEditingController motifCtrl = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    reg = widget.registration;
    student = reg['student'] ?? {};
    docs = student['documents'] ?? [];
    statut = reg['status'] ?? 'pending';
    motifCtrl.text = reg['notes'] ?? '';
  }

  Future<void> updateStatus() async {
    setState(() { loading = true; });
    final url = Uri.parse('http://localhost:8000/api/admin/registrations/${reg['id']}/status');
    final resp = await http.post(url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'status': statut,
        'notes': motifCtrl.text,
      })
    );
    setState(() { loading = false; });
    if (resp.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mise à jour réussie !')));
      setState(() { reg['status'] = statut; reg['notes'] = motifCtrl.text; });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : ${resp.body}')));
    }
  }

  Widget statutDropdown() => DropdownButton<String>(
    value: statut,
    items: [
      DropdownMenuItem(child: Text('En attente'), value: 'pending'),
      DropdownMenuItem(child: Text('Accepté'), value: 'approved'),
      DropdownMenuItem(child: Text('Rejeté'), value: 'rejected'),
    ],
    onChanged: (v) => setState(() => statut = v ?? 'pending'),
  );

  Widget docItem(Map doc) => ListTile(
    title: Text(doc['type']??''),
    subtitle: Text(doc['file_path']??''),
    trailing: (doc['file_path']??'').endsWith('.jpg') || (doc['file_path']??'').endsWith('.png') 
      ? Image.network('http://localhost:8000${doc['file_path']}', width: 40, height: 40, errorBuilder: (_,__,___)=>Icon(Icons.broken_image))
      : null,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dossier étudiant'), leading: BackButton()),
      body: loading
        ? Center(child: CircularProgressIndicator())
        : ListView(
            padding: EdgeInsets.all(18),
            children: [
              Text('${student['first_name']??''} ${student['last_name']??''}', style:TextStyle(fontWeight: FontWeight.bold,fontSize:18)),
              SizedBox(height:4),
              Text('Filière: ${reg['program']??''}, Niveau: ${reg['level']??''}'),
              Text('Statut actuel: $statut'),
              SizedBox(height:12),
              statutDropdown(),
              if(statut=='rejected') TextFormField(controller:motifCtrl, decoration:InputDecoration(labelText:'Motif / commentaire')),
              SizedBox(height:10),
              ElevatedButton(onPressed:updateStatus, child: Text('Enregistrer')),
              Divider(),
              Text('Informations personnelles:', style:TextStyle(fontWeight: FontWeight.bold)),
              Text('Date naissance: ${student['date_of_birth']??''}'),
              Text('Lieu: ${student['birth_place']??''}'),
              Text('Adresse: ${student['address']??''}'),
              Text('CIN: ${student['cin_number']??''}'),
              Text('Téléphone: ${student['phone_number']??''}'),
              SizedBox(height:10),
              Text('Documents:', style:TextStyle(fontWeight: FontWeight.bold)),
              ...docs.map((d)=>docItem(d)).toList(),
              if(reg['notes']!=null && reg['notes']!='')
                Padding(
                  padding: EdgeInsets.only(top:16),
                  child:Text('Commentaire admin : ${reg['notes']}', style:TextStyle(color:Colors.grey[700]))
                ),
            ],
          ),
    );
  }
}
