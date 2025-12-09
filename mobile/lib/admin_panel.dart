import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'admin_registration_detail.dart';

class AdminPanelFlutter extends StatefulWidget {
  final String token;
  AdminPanelFlutter({required this.token});
  @override
  _AdminPanelFlutterState createState() => _AdminPanelFlutterState();
}

class _AdminPanelFlutterState extends State<AdminPanelFlutter> {
  List registrations = [];
  List registrationsFiltered = [];
  bool loading = true;
  String? error;
  String search = '';
  String filtreStatus = 'all'; // all, pending, approved, rejected

  @override
  void initState() {
    super.initState();
    fetchRegistrations();
  }

  void applyFilters() {
    setState(() {
      registrationsFiltered = registrations.where((reg) {
        final student = reg['student'] ?? {};
        bool inSearch = search.isEmpty ||
            (student['first_name'] ?? '').toLowerCase().contains(search.toLowerCase()) ||
            (student['last_name'] ?? '').toLowerCase().contains(search.toLowerCase()) ||
            (reg['program'] ?? '').toLowerCase().contains(search.toLowerCase()) ||
            (student['email'] ?? '').toLowerCase().contains(search.toLowerCase());
        bool inStatus = filtreStatus == 'all' || reg['status'] == filtreStatus;
        return inSearch && inStatus;
      }).toList();
    });
  }

  Future<void> fetchRegistrations() async {
    setState(() { loading = true; error=null; });
    final uri = Uri.parse('http://127.0.0.1:8000/api/admin/registrations');
    try {
      final resp = await http.get(uri, headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Accept': 'application/json',
      });
      if (resp.statusCode == 200) {
        registrations = jsonDecode(resp.body);
        applyFilters();
        loading = false;
        setState(() {});
      } else {
        setState(() { error = resp.body; loading = false; });
      }
    } catch (e) {
      setState(() { error = e.toString(); loading = false; });
    }
  }

  Map<String,int> getStats() {
    return {
      'all': registrations.length,
      'pending': registrations.where((r)=>r['status']=='pending').length,
      'approved': registrations.where((r)=>r['status']=='approved').length,
      'rejected': registrations.where((r)=>r['status']=='rejected').length,
    };
  }

  Widget statsCards() {
    final stats = getStats();
    final cards = [
      {'label':'Total','val':stats['all'],'color':Colors.blue,'icon':Icons.folder_open},
      {'label':'En attente','val':stats['pending'],'color':Colors.orange,'icon':Icons.timer},
      {'label':'Acceptés','val':stats['approved'],'color':Colors.green,'icon':Icons.check_circle},
      {'label':'Rejetés','val':stats['rejected'],'color':Colors.red,'icon':Icons.cancel},
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: cards.map((info)=>Expanded(
        child: Card(
          shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(16)),
          color: (info['color'] as Color).withOpacity(0.09),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Icon(info['icon'] as IconData,color:info['color'] as Color,size:28),
                SizedBox(height:4),
                Text('${info['val']}',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold,color:info['color'] as Color)),
                Text(info['label'] as String,style:TextStyle(color:Colors.grey[800],fontWeight:FontWeight.w500)),
              ],
            ),
          ),
        ))).toList(),
    );
  }

  Widget statutBadge(String statut) {
    Color color = Colors.orange;
    if (statut == 'approved') color = Colors.green;
    if (statut == 'rejected') color = Colors.red;
    return AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 8,vertical: 4),
        decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(12)
        ),
        child: Text(statut, style: TextStyle(color: color))
    );
  }

  Widget searchBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: TextField(
      decoration: InputDecoration(
        hintText: 'Rechercher nom, email, filière...',
        prefixIcon: Icon(Icons.search,color: Colors.blueGrey),
        border: OutlineInputBorder(borderRadius:BorderRadius.circular(16),borderSide:BorderSide.none),
        filled: true, fillColor: Colors.blueGrey[50],
      ),
      onChanged: (v) {
        search = v;
        applyFilters();
      },
    ),
  );

  Widget filtresStatus() => Padding(
    padding: EdgeInsets.symmetric(vertical:10),
    child: Wrap(
      spacing: 8,
      children: [
        {'label':'Tous','val':'all','color':Colors.blue},
        {'label':'En attente','val':'pending','color':Colors.orange},
        {'label':'Acceptés','val':'approved','color':Colors.green},
        {'label':'Rejetés','val':'rejected','color':Colors.red},
      ].map((filtre) => ChoiceChip(
        label:Text(filtre['label'] as String,style:TextStyle(color: filtreStatus==filtre['val']?Colors.white:(filtre['color'] as Color))),
        selected: filtreStatus==filtre['val'],
        selectedColor: filtre['color'] as Color,
        backgroundColor: (filtre['color'] as Color).withOpacity(0.09),
        onSelected: (_){ setState(() { filtreStatus=filtre['val'] as String; applyFilters();}); },
      )).toList(),
    ),
  );

  Widget dossierCard(reg) {
    final student = reg['student'] ?? {};
    final color = reg['status']=='approved'?Colors.green:reg['status']=='rejected'?Colors.red:Colors.orange;
    return Card(
      shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(16)),
      elevation: 3,
      margin: EdgeInsets.symmetric(horizontal:16,vertical:10),
      shadowColor: color?.withOpacity(0.2),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical:14,horizontal:14),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.25),
            child: Text('${student['first_name']?[0] ?? ''}${student['last_name']?[0]?.toUpperCase() ?? ''}',style:TextStyle(color:color)),
            radius: 24,
          ),
          title: Text('${student['first_name'] ?? ''} ${student['last_name'] ?? ''}', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 3),
              Text('${reg['program'] ?? ''}  -  ${reg['level'] ?? ''}',style:TextStyle(color: Colors.grey[800])),
              SizedBox(height: 6),
              Row(
                children:[
                  Text('Statut a0: ',style:TextStyle(color:Colors.blueGrey[700])),
                  statutBadge(reg['status'] ?? 'pending'),
                ],
              ),
            ],
          ),
          trailing: ElevatedButton(
            style:ElevatedButton.styleFrom(
              backgroundColor:color,
              shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12)),
            ),
            child: Text('View',style:TextStyle(color: Colors.white)),
            onPressed: ()=>Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdminRegistrationDetail(registration: reg, token: widget.token)
              )
            ),
          ),
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F4F8),
      appBar: AppBar(
        title: Text('Admin Panel'),
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        backgroundColor: Colors.blue[600],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : error!=null
              ? Center(child: Text('Erreur : $error'))
              : Column(
                  children: [
                    statsCards(),
                    searchBar(),
                    filtresStatus(),
                    Expanded(
                      child: registrationsFiltered.isEmpty ?
                        Center(child: Text('Aucun dossier trouvé.', style: TextStyle(color: Colors.grey[700]))) :
                        ListView.builder(
                          itemCount: registrationsFiltered.length,
                          itemBuilder: (context, idx) {
                            final reg = registrationsFiltered[idx];
                            return dossierCard(reg);
                          },
                        )
                    ),
                  ],
                ),
    );
  }
}
