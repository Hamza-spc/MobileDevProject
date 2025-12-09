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
    final url = Uri.parse('http://127.0.0.1:8000/api/admin/registrations/${reg['id']}/status');
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

  String getDocTypeLabel(String? type) {
    switch(type) {
      case 'photo_bac': return 'Photo du Baccalauréat';
      case 'cin_recto': return 'CIN - Recto';
      case 'cin_verso': return 'CIN - Verso';
      case 'photo_perso': return 'Photo personnelle';
      default: return type ?? 'Document';
    }
  }

  void showImageFullScreen(String imageUrl, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(title)),
          body: Center(
            child: InteractiveViewer(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                headers: {
                  'Accept': 'image/*',
                },
                errorBuilder: (context, error, stackTrace) {
                  print('Erreur plein écran: $error');
                  print('URL: $imageUrl');
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Impossible de charger l\'image', style: TextStyle(color: Colors.grey)),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(imageUrl, style: TextStyle(color: Colors.grey[600], fontSize: 10)),
                      ),
                    ],
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget docItem(Map doc) {
    final filePath = doc['file_path'] ?? '';
    final docType = doc['type'] ?? '';
    final isImage = filePath.endsWith('.jpg') || filePath.endsWith('.jpeg') || filePath.endsWith('.png');
    // TOUJOURS utiliser la route API pour les images (avec CORS)
    String imageUrl;
    if (filePath.startsWith('/storage/')) {
      // Enlever le /storage/ du début et utiliser la route API
      final pathWithoutStorage = filePath.replaceFirst('/storage/', '');
      imageUrl = 'http://127.0.0.1:8000/api/storage/$pathWithoutStorage';
    } else if (filePath.startsWith('http://localhost/storage/')) {
      // Gérer les anciens chemins avec localhost
      final pathWithoutStorage = filePath.replaceFirst('http://localhost/storage/', '');
      imageUrl = 'http://127.0.0.1:8000/api/storage/$pathWithoutStorage';
    } else {
      imageUrl = 'http://127.0.0.1:8000$filePath';
    }
    print('Image URL: $imageUrl'); // Debug
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description, color: Colors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    getDocTypeLabel(docType),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (isImage)
              GestureDetector(
                onTap: () => showImageFullScreen(imageUrl, getDocTypeLabel(docType)),
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        headers: {
                          'Accept': 'image/*',
                        },
                        errorBuilder: (context, error, stackTrace) {
                          print('Erreur chargement image: $error');
                          print('URL: $imageUrl');
                          print('Stack trace: $stackTrace');
                          return Container(
                            color: Colors.grey[200],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.broken_image, size: 48, color: Colors.grey[400]),
                                SizedBox(height: 8),
                                Text('Image non disponible', style: TextStyle(color: Colors.grey[600])),
                                SizedBox(height: 4),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    imageUrl,
                                    style: TextStyle(color: Colors.grey[500], fontSize: 10),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                                SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // Ouvrir l'URL dans le navigateur pour tester
                                    print('Tester URL: $imageUrl');
                                  },
                                  icon: Icon(Icons.open_in_browser, size: 16),
                                  label: Text('Tester URL'),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 8),
                                Text('Chargement...', style: TextStyle(color: Colors.grey[600])),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ),
              )
            else
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.insert_drive_file, size: 32, color: Colors.grey[600]),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        filePath.split('/').last,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 8),
            if (isImage)
              TextButton.icon(
                onPressed: () => showImageFullScreen(imageUrl, getDocTypeLabel(docType)),
                icon: Icon(Icons.fullscreen, size: 18),
                label: Text('Voir en plein écran'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                ),
              ),
          ],
        ),
      ),
    );
  }

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
