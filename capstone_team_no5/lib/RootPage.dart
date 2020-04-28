import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:recycle/MainPage.dart';
import 'MyApp_config.dart';
import 'TabPage.dart';

class RootPage extends StatefulWidget {
  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage>{
  final _db = Firestore.instance;
  DocumentSnapshot _currentDoc;
  @override
  void initState() { 
    super.initState();
    MyApp_config();

    _delaying(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: ,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage('assets/images/Logo.png')),
            Padding(padding: EdgeInsets.all(8.0)),
            Text('생활 폐기물 품목 측정 기술', style: TextStyle(
              fontSize: 27.0,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),),
            Padding(padding: EdgeInsets.all(3.0)),
            Text('캡스톤 01반 5조', style: TextStyle(
              fontSize: 15.0,
            ),),
            Padding(padding: EdgeInsets.all(3.0)),
            Text('외 유 내 강', style: TextStyle(
              fontSize: 15.0,
            ),),
          ],
        ),
      ),
    );
  }

  Future<void> _delaying(BuildContext context) async{
    await Future.delayed(Duration(milliseconds: 2500));

    MyApp_config().readMyconfig().then((MyApp_config onValue) async{
      // TODO : 1. 자동 로그인 될 때도 안 될때도 있음... 
      // TODO : 2. 자동 로그인이면 상관 없는데 아닌경우, 앱을 그냥 끄면 로그인 상태에서 로그아웃됨...
      // (2020-04-28 :: 17:19)

      // TEST OUTPUT
      print("TEST OUTPUT 1 : " + onValue.toString());  // { admin, false, false }

      await accessMyFirestore(onValue.receiveID);

      if(_currentDoc != null && onValue.chkboxAUTO == true){
        // Navigator.pushReplacement로 하면 뒤로 다시 돌아올 수 없다.
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            child: TabPage(_currentDoc),
            duration: Duration(milliseconds: 900),
          ),
        ).then((onValue){
          // 자동 로그인을 했을 때 로그아웃하면 RootPage로 돌아와버리기 때문에 바로 로그인 페이지로 이동시킨다.
          Navigator.push(context, MaterialPageRoute(builder: (context) => MainPage()));
        });
      }
      else{
        // Navigator.pushReplacement로 하면 뒤로 다시 돌아올 수 없다.
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            child: MainPage(),
            duration: Duration(milliseconds: 900),
          ),
        );
      }
    });
    return;
  }

  // * 계정 정보가 있으면 qs.documents.single을 반환, 계정 정보를 찾지 못하면 null반환.
  Future<void> accessMyFirestore(String chkID) async{
    Future<dynamic> doc = _db.collection('user').where('id', isEqualTo: chkID).getDocuments();
    await doc.then((qs){
      _currentDoc = (qs.documents.isEmpty)? null : qs.documents.single;
    });

    return;
  }
} 