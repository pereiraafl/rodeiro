import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

class HistoryHighestlowest extends StatefulWidget {
  final String API_URL;
  const HistoryHighestlowest({super.key, required this.API_URL});

  @override
  State<HistoryHighestlowest> createState() => _HistoryHighestlowestState();
}

class _HistoryHighestlowestState extends State<HistoryHighestlowest> {

  late String apiUrl;

  List<HighestlowestPoints> _dataSource = [];

  @override
  void initState(){
    apiUrl = widget.API_URL;
    fetchContinuous(apiUrl).then((value) {
      setState(() {
        _dataSource = value;
      });
    },);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 700,
      height: 380,
      child: Column(
        children: [
          SfCartesianChart(
            isTransposed: true,
            title: ChartTitle(
              text: "Temperaturas máximas e mínimas em cada ciclo",
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            enableAxisAnimation: true,
            tooltipBehavior: TooltipBehavior(
              color: Colors.lightBlue.shade400,
              enable: true,
              borderColor: Colors.deepOrange,
              borderWidth: 2,
              header: "",
            ),
            zoomPanBehavior: ZoomPanBehavior(
              enablePanning: true,
              enableMouseWheelZooming: true,
              enablePinching: true,
            ),
            // Initialize category axis (e.g., x-axis)
            primaryXAxis: const NumericAxis(
              labelStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500
              ),
              majorGridLines: MajorGridLines(width: 0),
              axisLine: AxisLine(width: 0),
            ),
            primaryYAxis: const NumericAxis(
              //minimum: minYAxis - 3,
              //maximum: maxYAxis + 3,
              labelStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500
              ),
              majorGridLines: MajorGridLines(width: 0),
              axisLine: AxisLine(width: 0),
            ),
            series: <BarSeries<HighestlowestPoints, int>>[
              // Initialize line series with data points
              BarSeries <HighestlowestPoints, int>(
                color: Colors.lightBlue,
                dataSource: _dataSource,
                xValueMapper: (HighestlowestPoints value, _) => value.cycle,
                yValueMapper: (HighestlowestPoints value, _) => value.temp_init
              ),
              BarSeries <HighestlowestPoints, int>(
                  color: Colors.redAccent,
                  dataSource: _dataSource,
                  xValueMapper: (HighestlowestPoints value, _) => value.cycle,
                  yValueMapper: (HighestlowestPoints value, _) => value.temp_final
              ),
            ],
          )
        ],
      ),
    );
  }
}

class HighestlowestPoints {
  HighestlowestPoints (this.cycle, this.temp_init, this.temp_final);
  final int cycle;
  final double temp_init;
  final double temp_final;
}

Future<List<HighestlowestPoints>> fetchContinuous(String url) async {
  final response = await http.get(Uri.parse('${url}/continuous'));
  final response_json = json.decode(response.body);

  List<HighestlowestPoints> dataPoints = [];
  int index = 0;
  List<double> temps = [];
  for (var point in response_json) {
    if (point["cycle"] > index) {
      double maxTemp = temps.reduce(max);
      double minTemp = temps.reduce(min);
      dataPoints.add(HighestlowestPoints(index, minTemp, maxTemp));
      index = point["cycle"];
      temps = [];
    }
    temps.add(point["current_temp"].toDouble());
  }

  return dataPoints;
}