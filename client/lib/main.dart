import 'dart:async';
import 'dart:convert';

import 'package:client/history/continuous.dart';
import 'package:client/history/highestlowest.dart';
import 'package:client/live/continuous.dart';
import 'package:client/notifications.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:dio/dio.dart';
import 'dart:io';

import 'dart:io' show Platform;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  String? minhaKey = dotenv.env["API_URL"];
  if (Platform.isAndroid) {
    await NotificationService.init(minhaKey!);
  }
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
  bool isShowingChartOpt = false;
  bool isShowingDropdown = false;
  bool isShowingArduinoOpt = false;
  bool areYouSureQuestion = false;
  List<String> continuousCollectionNames = [];
  List<DropdownMenuEntry> dropdownList = [];

  List<bool> _selectedToggle = [true, false];
  List<bool> _selectedToggleArduino = [true, false];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: areYouSureQuestion
          ? AlertDialog(
              backgroundColor: Colors.black54,
              title: Text(
                "Você tem certeza que deseja desligar o Arduino?",
                style: TextStyle(color: Colors.white),
              ),
              actions: [
                TextButton(
                    onPressed: () async {
                      await requestTurnOffArduino();
                      setState(() {
                        areYouSureQuestion = false;
                      });
                    },
                    child: Text(
                      "Sim",
                      style: TextStyle(color: Colors.blue),
                    )),
                TextButton(
                    onPressed: () {
                      setState(() {
                        areYouSureQuestion = false;
                      });
                    },
                    child: Text("Não", style: TextStyle(color: Colors.blue)))
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                        onPressed: () {
                          setState(() {
                            isShowingChartOpt = !isShowingChartOpt;
                          });
                        },
                        icon: Icon(
                          Icons.bar_chart,
                          size: 30,
                          color: Colors.blue[800],
                        )),
                    AnimatedOpacity(
                        opacity: isShowingChartOpt ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 1000),
                        child: isShowingChartOpt
                            ? Row(
                                children: [
                                  ToggleButtons(
                                    constraints: const BoxConstraints(
                                      minHeight: 40.0,
                                      minWidth: 80.0,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8)),
                                    selectedBorderColor: Colors.lightBlue[700],
                                    selectedColor: Colors.lightBlue[500],
                                    color: Colors.white,
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
                                    children: [
                                      Text(
                                        "Discreto",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        "Contínuo",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        setState(() {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    displayCharts(
                                                        context,
                                                        _selectedToggle[0],
                                                        API_URL!)),
                                          );
                                        });
                                      },
                                      icon: Icon(
                                        Icons.refresh,
                                        size: 25,
                                        color: Colors.blue[800],
                                      ))
                                ],
                              )
                            : SizedBox())
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                        onPressed: () {
                          setState(() {
                            isShowingArduinoOpt = !isShowingArduinoOpt;
                          });
                        },
                        icon: Icon(Icons.settings,
                            size: 30, color: Colors.blue[800])),
                    SizedBox(
                      height: 200,
                    ),
                    AnimatedOpacity(
                        opacity: isShowingArduinoOpt ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 1000),
                        child: isShowingArduinoOpt
                            ? ToggleButtons(
                                constraints: const BoxConstraints(
                                  minHeight: 40.0,
                                  minWidth: 120.0,
                                ),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(8)),
                                selectedBorderColor: Colors.lightBlue[700],
                                selectedColor: Colors.lightBlue[500],
                                color: Colors.white,
                                isSelected: _selectedToggleArduino,
                                onPressed: (int index) async {
                                  if (index == 0) {
                                    await requestTurnOnArduino();
                                  }
                                  if (index == 1) {
                                    setState(() {
                                      areYouSureQuestion = !areYouSureQuestion;
                                    });
                                  }
                                  setState(() {
                                    if (index == 0) {
                                      _selectedToggleArduino[0] = true;
                                      _selectedToggleArduino[1] = false;
                                    }
                                    if (index == 1) {
                                      _selectedToggleArduino[0] = false;
                                      _selectedToggleArduino[1] = true;
                                    }
                                  });
                                },
                                children: const [
                                  Text(
                                    "Ligar Arduino",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    "Desligar Arduino",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              )
                            : SizedBox()),
                  ],
                ),
                IconButton(
                    onPressed: () async {
                      // Fetch all /list/continuous
                      List<String> tmpString =
                          await getListCollectionsContinuous();
                      List<DropdownMenuEntry> tmpDropdown = [];
                      for (var name in tmpString) {
                        tmpDropdown.add(DropdownMenuEntry(
                          value: name,
                          label: name,
                          leadingIcon: IconButton(
                              onPressed: () {
                                deleteCollectionByName(name);
                                setState(() {
                                  isShowingDropdown = !isShowingDropdown;
                                });
                              },
                              icon: Icon(
                                Icons.delete,
                                color: Colors.blue,
                              )),
                          trailingIcon: IconButton(
                              onPressed: () {
                                downloadCsv(name);
                                setState(() {
                                  isShowingDropdown = !isShowingDropdown;
                                });
                              },
                              icon: Icon(
                                Icons.download,
                                color: Colors.blue,
                              )),
                        ));
                      }
                      setState(() {
                        dropdownList = tmpDropdown;
                        isShowingDropdown = !isShowingDropdown;
                      });
                    },
                    icon: Icon(Icons.download,
                        size: 30, color: Colors.blue[800])),
                isShowingDropdown
                    ? DropdownMenu(
                        menuHeight: 300,
                        onSelected: (item) async {
                          await downloadCsv(item);
                        },
                        dropdownMenuEntries: dropdownList,
                        textStyle: TextStyle(color: Colors.white),
                      )
                    : SizedBox(),
              ],
            ),
    );
  }
}

Future<List<String>> getListCollectionsContinuous() async {
  final response =
      await http.get(Uri.parse('${dotenv.env["API_URL"]}/list/continuous'));
  final response_json = json.decode(response.body);
  List<String> collectionNames = [];
  var collections = response_json["collections"];
  for (var collection in collections) {
    collectionNames.add(collection);
  }
  collectionNames.sort();
  return collectionNames;
}

Future<void> downloadCsv(String collName) async {
  final API_URL = dotenv.env["API_URL"];
  final dio = Dio();

  final rs = await dio.get(
    "${API_URL}/csv/continuous/${collName}",
    options: Options(responseType: ResponseType.stream),
  );

  String? outputFileName = await FilePicker.platform.saveFile(
    dialogTitle: 'Please select an output file:',
    fileName: '${collName.replaceAll(":", "-")}.csv',
  );

  if (outputFileName != null) {
    final file = File(outputFileName);
    final fileStream = file.openWrite();

    await for (final chunk in rs.data.stream) {
      fileStream.add(chunk);
    }

    await fileStream.close();
  }
}

Widget displayCharts(BuildContext context, bool scatterOpt, String api_url) {
  return Scaffold(
    backgroundColor: Colors.blueGrey[900],
    body: SingleChildScrollView(
      // Allow scrolling if content overflows
      child: Padding(
        // Optional padding to avoid content sticking to edges
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Adjusted alignment
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.arrow_back, size: 20, color: Colors.red),
              ),
              // Use widgets without Expanded or Flexible if height is not constrained
              HistoryContinuous(API_URL: api_url, isScatter: scatterOpt),
              SizedBox(height: 10),
              // Add spacing between widgets
              HistoryHighestlowest(API_URL: api_url),
              SizedBox(height: 10),
              // Add spacing between widgets
              LiveContinuous(API_URL: api_url),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> deleteCollectionByName(String collectionName) async{
  final response = await http.delete(Uri.parse('${dotenv.env["API_URL"]}/delete/$collectionName'), headers: {"Content-Type": "application/json"});
}

Future<void> requestTurnOnArduino() async {
  final response =
      await http.get(Uri.parse('${dotenv.env["API_URL"]}/arduino/on'));
  return;
}

Future<void> requestTurnOffArduino() async {
  final response =
      await http.get(Uri.parse('${dotenv.env["API_URL"]}/arduino/off'));
  return;
}