import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';


class HistoryContinuous extends StatefulWidget {
  final String API_URL;
  final bool isScatter;
  HistoryContinuous({super.key, required this.API_URL, required this.isScatter});

  @override
  State<HistoryContinuous> createState() => _HistoryContinuousState();
}

class _HistoryContinuousState extends State<HistoryContinuous> {

  late String apiUrl;
  late bool isScatter = false;
  List<ContinuousPoints> _dataSource = [];

  @override
  void initState(){
    apiUrl = widget.API_URL;
    isScatter = false;
    isScatter = widget.isScatter;
    fetchContinuousData(apiUrl).then((value) {
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
      height: 500,
      child: Column(
        children: [
          SfCartesianChart(
            title: ChartTitle(
              text: "Temperatura ao longo dos ciclos",
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
            primaryXAxis: const CategoryAxis(
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
            series: isScatter ? <ScatterSeries<ContinuousPoints, int>>[
              // Initialize line series with data points
              ScatterSeries<ContinuousPoints, int>(
                color: Colors.lightBlue,
                dataSource: _dataSource,
                xValueMapper: (ContinuousPoints value, _) => value.cycle,
                yValueMapper: (ContinuousPoints value, _) => value.temp,
              ),
            ] : <FastLineSeries<ContinuousPoints, int>>[
              // Initialize line series with data points
              FastLineSeries <ContinuousPoints, int>(
                color: Colors.lightBlue,
                dataSource: _dataSource,
                xValueMapper: (ContinuousPoints value, _) => value.index,
                yValueMapper: (ContinuousPoints value, _) => value.temp,
              ),
            ]

          )
        ],
      ),
    );
  }
}

class ContinuousPoints {
  ContinuousPoints (this.cycle, this.temp, this.index);
  final int cycle;
  final double temp;
  final int index;
}

Future<List<ContinuousPoints>> fetchContinuousData(String url) async {
  final response = await http.get(Uri.parse('${url}/continuous'));
  final response_json = json.decode(response.body);

  List<ContinuousPoints> dataPoints = [];
  int index = 0;
  for (var point in response_json) {
    int cycle = point["cycle"].toInt();
    double current_temp = point["current_temp"].toDouble();
    ContinuousPoints continuousPoints = ContinuousPoints(cycle, current_temp, index);
    dataPoints.add(continuousPoints);
    index+=1;
  }
  return dataPoints;
}

