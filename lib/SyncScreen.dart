
import 'dart:async';

import 'package:face_recognition_with_images/DB/syncronize.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({Key? key}) : super(key: key);

  @override
  State<SyncScreen> createState() => _HomePageState();
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false;
    //..customAnimation = CustomAnimation();
}



class _HomePageState extends State<SyncScreen> {
  late Timer _timer;
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController gender = TextEditingController();

  late List list;
  bool loading = true;


    Future isInteret()async{
    await SyncronizationData.isInternet().then((connection){
      if (connection) {
        
        print("Internet connection abailale");
      }else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No Internet")));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sync Sqflite to Mysql"),
        actions: [
          IconButton(icon: Icon(Icons.refresh_sharp), onPressed: (){
            
          })
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: name,
              decoration: InputDecoration(hintText: 'Enter name'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: email,
              decoration: InputDecoration(hintText: 'Enter email'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: gender,
              decoration: InputDecoration(hintText: 'Enter gender'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () async{
                
              },
              child: Text("Save"),
            ),
          ),
          loading ?Center(child: CircularProgressIndicator()):Expanded(
            child: ListView.builder(
                itemCount: list.length==null?0:list.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text(list[index]['id'].toString()),
                      SizedBox( width: 5,),
                      Text(list[index]['name']),
                    ],),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                      Text(list[index]['email']),
                      Text(list[index]['gender']),
                    ],),
                    );
                },
              ),
          ),
        ],
      ),
    );
  }
}