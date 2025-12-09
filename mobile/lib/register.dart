import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

enum FileTypeKey {photoBac, cinRecto, cinVerso, photoPerso}

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String firstName = '', lastName = '', email = '', phoneNumber = '', dateOfBirth = '', birthPlace = '', address = '', gender = '', bacYear = '', bacSeries = '', bacAverage = '', bacSchool = '', parentInfo = '', tutorContact = '', cinNumber = '', password = '', passconf = '', program = '', level = '', schoolYear = '';
  Map<FileTypeKey, XFile?> files = {
    FileTypeKey.photoBac: null,
    FileTypeKey.cinRecto: null,
    FileTypeKey.cinVerso: null,
    FileTypeKey.photoPerso: null
  };
  bool loading = false;

  Future pickFile(FileTypeKey key) async {
    final ImagePicker picker = ImagePicker();
    XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        files[key] = picked;
      });
    }
  }

  Future<void> registerFull() async {
    if (!_formKey.currentState!.validate() || files[FileTypeKey.photoBac] == null || files[FileTypeKey.cinRecto] == null || files[FileTypeKey.cinVerso] == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tous les champs obligatoires doivent être remplis.')));
      return;
    }
    setState(() => loading = true);
    var uri = Uri.parse('http://localhost:8000/api/register-full');
    var request = http.MultipartRequest('POST', uri)
      ..fields['first_name'] = firstName
      ..fields['last_name'] = lastName
      ..fields['email'] = email
      ..fields['phone_number'] = phoneNumber
      ..fields['date_of_birth'] = dateOfBirth
      ..fields['birth_place'] = birthPlace
      ..fields['address'] = address
      ..fields['gender'] = gender
      ..fields['bac_year'] = bacYear
      ..fields['bac_series'] = bacSeries
      ..fields['bac_average'] = bacAverage
      ..fields['bac_school'] = bacSchool
      ..fields['parent_info'] = parentInfo
      ..fields['tutor_contact'] = tutorContact
      ..fields['cin_number'] = cinNumber
      ..fields['password'] = password
      ..fields['password_confirmation'] = passconf
      ..fields['program'] = program
      ..fields['level'] = level
      ..fields['school_year'] = schoolYear;
    request.files.add(await http.MultipartFile.fromPath('photo_bac', files[FileTypeKey.photoBac]!.path));
    request.files.add(await http.MultipartFile.fromPath('cin_recto', files[FileTypeKey.cinRecto]!.path));
    request.files.add(await http.MultipartFile.fromPath('cin_verso', files[FileTypeKey.cinVerso]!.path));
    if (files[FileTypeKey.photoPerso] != null) {
      request.files.add(await http.MultipartFile.fromPath('photo_perso', files[FileTypeKey.photoPerso]!.path));
    }
    try {
      var response = await request.send();
      setState(() => loading = false);
      var resp = await response.stream.bytesToString();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.statusCode==200 ? 'Succès: $resp' : 'Erreur: $resp')));
      if (response.statusCode == 200) Navigator.pop(context);
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de l\'envoi: $e')));
    }
  }

  Widget formSection({required String title, required IconData icon, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height:18),
        Row(
          children:[
            Icon(icon, color: Colors.blue, size:22),
            SizedBox(width:8),
            Text(title, style:TextStyle(fontWeight: FontWeight.bold,fontSize:15, color:Colors.blue[800])),
          ]
        ),
        SizedBox(height:5),
        Container(width:60, height:2, color:Colors.blue[50]),
        SizedBox(height:10),
        child
      ],
    );
  }

  Widget fichierSelector(FileTypeKey key, String label, bool obligatoire) {
    final f = files[key];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(Icons.insert_drive_file, color: Colors.indigo),
          SizedBox(width:8),
          Expanded(child: Text(f!=null?f.path.split("/").last:label,
            style: TextStyle(color:f!=null?Colors.green[700]:Colors.grey, fontWeight: f!=null ? FontWeight.bold:FontWeight.normal), overflow: TextOverflow.ellipsis,)),
          if (f!=null)
            Padding(
              padding:EdgeInsets.only(left:4),
              child: Icon(Icons.check_circle, color:Colors.green,size:19)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(padding:EdgeInsets.symmetric(horizontal:14),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(16)),backgroundColor: Colors.blue[50]),
            onPressed: ()=>pickFile(key),
            child: Text('Choisir', style: TextStyle(color:Colors.blue[700],fontWeight:FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  InputDecoration inputDeco(String label, IconData? icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon!=null? Icon(icon, color: Colors.blue[500]):null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: EdgeInsets.symmetric(vertical:14, horizontal:18),
      filled: true,
      fillColor: Colors.blueGrey[50],
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.blue,width:2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.red,width:2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inscription à l'école")),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 8,horizontal: 12),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              formSection(
                title: 'Informations personnelles',
                icon: Icons.person,
                child: Column(children:[
                  Row(children:[
                    Expanded(child:TextFormField(decoration:inputDeco('Prénom',Icons.person), onChanged:(v)=>firstName=v, validator:(v)=>v!.isEmpty?'Obligatoire':null)),
                    SizedBox(width:10),
                    Expanded(child:TextFormField(decoration:inputDeco('Nom',null), onChanged:(v)=>lastName=v, validator:(v)=>v!.isEmpty?'Obligatoire':null)),
                  ]),
                  SizedBox(height:10),
                  TextFormField(decoration:inputDeco('Email',Icons.email), keyboardType:TextInputType.emailAddress, onChanged:(v)=>email=v, validator:(v)=>v!.isEmpty?'Obligatoire':null),
                  SizedBox(height:10),
                  TextFormField(decoration:inputDeco('Téléphone',Icons.phone), keyboardType:TextInputType.phone, onChanged:(v)=>phoneNumber=v, validator:(v)=>v!.isEmpty?'Obligatoire':null),
                  SizedBox(height:10),
                  TextFormField(decoration:inputDeco('Date de naissance (YYYY-MM-DD)',Icons.calendar_month), onChanged:(v)=>dateOfBirth=v, validator:(v)=>v!.isEmpty?'Obligatoire':null),
                  SizedBox(height:10),
                  TextFormField(decoration:inputDeco('Lieu de naissance',Icons.location_on), onChanged:(v)=>birthPlace=v, validator:(v)=>v!.isEmpty?'Obligatoire':null),
                  SizedBox(height:10),
                  TextFormField(decoration:inputDeco('Adresse complète',Icons.home), onChanged:(v)=>address=v, validator:(v)=>v!.isEmpty?'Obligatoire':null),
                  SizedBox(height:10),
                  TextFormField(decoration:inputDeco('Genre (optionnel)',Icons.people_alt), onChanged:(v)=>gender=v),
                ]),
              ),

              formSection(
                title: 'Informations académiques',
                icon: Icons.school,
                child: Column(children:[
                  Row(children:[
                    Expanded(child:TextFormField(decoration:inputDeco("Année Bac",Icons.event), keyboardType:TextInputType.number, onChanged:(v)=>bacYear=v, validator:(v)=>v!.isEmpty?'Obligatoire':null)),
                    SizedBox(width:10),
                    Expanded(child:TextFormField(decoration:inputDeco('Série Bac',Icons.category), onChanged:(v)=>bacSeries=v, validator:(v)=>v!.isEmpty?'Obligatoire':null)),
                  ]),
                  SizedBox(height:10),
                  TextFormField(decoration:inputDeco('Moyenne Bac',Icons.grade), keyboardType:TextInputType.numberWithOptions(decimal:true), onChanged:(v)=>bacAverage=v, validator:(v)=>v!.isEmpty?'Obligatoire':null),
                  SizedBox(height:10),
                  TextFormField(decoration:inputDeco("Établissement Bac",Icons.business), onChanged:(v)=>bacSchool=v, validator:(v)=>v!.isEmpty?'Obligatoire':null),
                  SizedBox(height:10),
                  TextFormField(decoration:inputDeco('Parents / Responsable légal (optionnel)',Icons.family_restroom), onChanged:(v)=>parentInfo=v),
                  SizedBox(height:10),
                  TextFormField(decoration:inputDeco('Tuteur contact (optionnel)',Icons.contact_phone), onChanged:(v)=>tutorContact=v),
                  SizedBox(height:10),
                  TextFormField(decoration:inputDeco('Numéro CIN',Icons.badge), onChanged:(v)=>cinNumber=v, validator:(v)=>v!.isEmpty?'Obligatoire':null),
                  SizedBox(height:10),
                  Row(children:[
                    Expanded(child:TextFormField(decoration:inputDeco('Mot de passe',Icons.lock), obscureText:true, onChanged:(v)=>password=v, validator:(v)=>v!.isEmpty?'Obligatoire':null)),
                    SizedBox(width:10),
                    Expanded(child:TextFormField(decoration:inputDeco('Confirmation',Icons.lock_outline), obscureText:true, onChanged:(v)=>passconf=v, validator:(v)=>v!=password?'Différent':null)),
                  ]),
                ]),
              ),

              formSection(
                title: 'Documents à fournir',
                icon: Icons.attachment,
                child: Column(children:[
                  fichierSelector(FileTypeKey.photoBac, 'Photo du Bac (.jpg/png)', true),
                  fichierSelector(FileTypeKey.cinRecto, 'CIN recto (.jpg/png)', true),
                  fichierSelector(FileTypeKey.cinVerso, 'CIN verso (.jpg/png)', true),
                  fichierSelector(FileTypeKey.photoPerso, 'Photo personnelle (optionnelle)', false),
                ]),
              ),

              formSection(
                title: 'Choix de la formation',
                icon: Icons.account_balance,
                child: Column(children:[
                  Row(children:[
                    Expanded(child:DropdownButtonFormField<String>(
                      decoration: inputDeco('Filière', Icons.book),
                      value: program.isEmpty ? null : program,
                      items: ['Informatique','Finance','Génie Civil','Ingénierie Industrielle'].map((f)=>DropdownMenuItem(child:Text(f),value:f)).toList(),
                      onChanged: (v)=>setState(()=>program=v ?? ''),
                      validator: (v)=> v==null||v.isEmpty ? 'Obligatoire' : null,
                    )),
                    SizedBox(width:10),
                    Expanded(child:DropdownButtonFormField<String>(
                      decoration: inputDeco('Niveau', Icons.school_outlined),
                      value: level.isEmpty ? null : level,
                      items: ['Licence 1','Licence 2','Licence 3','Master 1','Master 2','Cycle Ingénieur'].map((n)=>DropdownMenuItem(child:Text(n),value:n)).toList(),
                      onChanged: (v)=>setState(()=>level=v ?? ''),
                      validator: (v)=> v==null||v.isEmpty ? 'Obligatoire' : null,
                    )),
                  ]),
                  SizedBox(height:10),
                  DropdownButtonFormField<String>(
                    decoration: inputDeco('Année universitaire', Icons.calendar_today),
                    value: schoolYear.isEmpty ? null : schoolYear,
                    items: ['2024-2025','2025-2026','2026-2027','2027-2028'].map((a)=>DropdownMenuItem(child:Text(a),value:a)).toList(),
                    onChanged: (v)=>setState(()=>schoolYear=v ?? ''),
                    validator: (v)=> v==null||v.isEmpty ? 'Obligatoire' : null,
                  ),
                ])),


              SizedBox(height:32),
              ElevatedButton(
                onPressed: loading?null:registerFull,
                style:ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical:18),
                  shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(16)),
                  backgroundColor: Colors.blue[700],
                  elevation:6,
                  textStyle:TextStyle(fontWeight:FontWeight.bold,fontSize:17)
                ),
                child: loading? CircularProgressIndicator(color:Colors.white):Text('Valider l\'inscription'),
              ),
              SizedBox(height:20)
            ],
          ),
        ),
      ),
    );
  }
}
