import 'dart:convert';

import 'package:client/history/continuous.dart';
import 'package:client/history/highestlowest.dart';
import 'package:client/live/continuous.dart';
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

  List<bool> _selectedToggle = [true, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child:
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed:() {
                        setState(() {
                          flag = !flag;
                        });
                      },
                      icon: Icon(Icons.catching_pokemon, size: 20, color: Colors.red,)
                  ),
                  ToggleButtons(
                    children: [
                      Icon(Icons.calendar_view_month),
                      Icon(Icons.timeline)
                    ],
                    isSelected: _selectedToggle,
                    onPressed: (int index) {
                      setState(() {
                        if (index == 0) {
                          _selectedToggle[0] = true;
                          _selectedToggle[1] = false;
                        }
                        if (index == 1) {
                          _selectedToggle[0] = false;
                          _selectedToggle[1] = true;
                        }
                      });
                    },
                  ),
                ],
              ),
          ),
          flag ?
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  HistoryContinuous(API_URL: API_URL!, isScatter: _selectedToggle[0],),
                  HistoryHighestlowest(API_URL: API_URL!)
                ],
              ),
              LiveContinuous(API_URL: API_URL!, isScatter: _selectedToggle[0],)
            ],
          ) : SizedBox()
        ],
      ),
    );
  }
}

