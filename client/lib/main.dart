import 'dart:convert';

import 'package:client/history/continuous.dart';
import 'package:client/history/highestlowest.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async{
  await dotenv.load(fileName: ".env");
  String? minhaKey = dotenv.env["API_URL"];
  print("Minha key: " + minhaKey!);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String? API_URL = dotenv.env["API_URL"];

  bool flag = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: Center(
        child: Column(
          children: [
            IconButton(
                onPressed:() {
                  setState(() {
                    flag = !flag;
                  });
                },
                icon: Icon(Icons.catching_pokemon, size: 90, color: Colors.red,)
            ),
            flag ?
            Row(
              children: [
                HistoryContinuous(API_URL: API_URL!),
                HistoryHighestlowest(API_URL: API_URL!)
              ],
            ) : SizedBox()
          ],
        ),
      ),
    );
  }
}

