import 'package:flutter/material.dart';
import 'register.dart';
import 'login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ecole des Hautes Études',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Filiere {
  final String nom;
  final int duree;
  final List<String> skills;
  final IconData icon;
  final Color color;
  Filiere(this.nom, this.duree, this.skills, this.icon, this.color);
}

final filieres = [
  Filiere('Informatique', 3, ['Python', 'Java', 'Algorithmique', 'FullStack Web/Mobile', 'Travail d\'équipe'], Icons.computer, Colors.blue),
  Filiere('Finance', 3, ['Gestion financière', 'Comptabilité', 'Marchés', 'Excel', 'Analyse'], Icons.attach_money, Colors.green),
  Filiere('Génie Civil', 5, ['Matériaux', 'Plans/DAO', 'Chantiers', 'Gestion de projet'], Icons.apartment, Colors.orange),
  Filiere('Industriel', 3, ['Lean management', 'Production', 'Qualité', 'Logistique', 'Automatisation'], Icons.engineering, Colors.purple),
];

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int pageIdx = 0;
  final pageCtrl = PageController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xFFF7F7FB),
      body: SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            SizedBox(height: 24),
            Center(
              child: Column(children:[
                CircleAvatar(radius:34, backgroundColor:Colors.blue.shade100,child:Icon(Icons.school,size:40,color:Colors.blue)),
                SizedBox(height:12),
                Text('Ecole des Hautes Études', style:TextStyle(fontWeight:FontWeight.bold,fontSize:24,color:Colors.blue[800])),
                SizedBox(height:4),
                Text('Préparez votre avenir avec excellence', style:TextStyle(fontSize:16,color:Colors.blueGrey)),
              ]),
            ),
            SizedBox(height: 24),
            Container(
              height: size.height>480?250:200,
              child: PageView.builder(
                controller: pageCtrl,
                onPageChanged: (i)=>setState(()=>pageIdx=i),
                itemCount: filieres.length,
                itemBuilder: (ctx,i){
                  final f=filieres[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal:28.0,vertical:12),
                    child: Card(
                      elevation:6, shadowColor: f.color.withOpacity(0.2),
                      shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(24)),
                      color: f.color.withOpacity(.07),
                      child: Padding(
                        padding: EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:[
                            Row(
                              children:[
                                CircleAvatar(backgroundColor:f.color.withOpacity(0.11),child:Icon(f.icon,color:f.color)),
                                SizedBox(width:14),
                                Text(f.nom, style:TextStyle(fontSize:20, fontWeight:FontWeight.bold, color: f.color)),
                                Spacer(),
                                Text('${f.duree} ans', style:TextStyle(color:Colors.blueGrey[700],fontWeight:FontWeight.w600)),
                              ]),
                            SizedBox(height:10),
                            Text('Compétences :',style:TextStyle(fontWeight:FontWeight.bold, color:f.color)),
                            SizedBox(height:3),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: 85, // permet plusieurs skills sans overflow
                                minHeight: 20,
                              ),
                              child: SingleChildScrollView(
                                child:Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:[
                                    ...f.skills.take(4).map((s)=>Padding(
                                      padding: EdgeInsets.only(left:8,top:2),
                                      child: Row(
                                        children:[Icon(Icons.check_circle_outline,size:16,color:f.color),SizedBox(width:6),Flexible(child:Text(s,style:TextStyle(color:Colors.blueGrey[800],fontSize:14),overflow:TextOverflow.fade))]
                                      ))),
                                    if(f.skills.length>4)
                                      Padding(
                                        padding: EdgeInsets.only(left:8,top:2),
                                        child: Text('+ ${f.skills.length-4} autres...',style:TextStyle(color:Colors.blueGrey[500],fontSize:13)),
                                      )
                                  ]
                                ),
                              ),
                            ),
                            SizedBox(height:8),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height:6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(filieres.length, (i) => AnimatedContainer(
                duration: Duration(milliseconds: 180),margin:EdgeInsets.symmetric(horizontal:3),
                width:8, height:8,
                decoration:BoxDecoration(
                  shape:BoxShape.circle,
                  color: i == pageIdx ? filieres[i].color:Colors.blueGrey[200],
                  boxShadow:i==pageIdx?[BoxShadow(color:filieres[i].color.withOpacity(0.7),blurRadius:6,spreadRadius:1)]:[]
                ))),
            ),
            SizedBox(height:20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.how_to_reg),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: filieres[pageIdx].color,
                    shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(18)),
                    padding: EdgeInsets.symmetric(horizontal:22,vertical:14),
                  ),
                  label: Text("S'inscrire", style: TextStyle(fontWeight:FontWeight.w600)),
                  onPressed: ()=>Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen())
                  ),
                ),
                SizedBox(width:20),
                OutlinedButton.icon(
                  icon: Icon(Icons.login),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: filieres[pageIdx].color,
                    side: BorderSide(color:filieres[pageIdx].color, width:1.8),
                    shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(18)),
                    padding: EdgeInsets.symmetric(horizontal:22,vertical:14),
                  ),
                  label: Text("Se connecter"),
                  onPressed: ()=>Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen())
                  ),
                ),
              ],
            ),
            SizedBox(height:36),
          ]
        ),
      ),
    );
  }
}
