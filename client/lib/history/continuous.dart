import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';


class HistoryContinuous extends StatefulWidget {
  final String API_URL;
  HistoryContinuous({super.key, required this.API_URL});

  @override
  State<HistoryContinuous> createState() => _HistoryContinuousState();
}

class _HistoryContinuousState extends State<HistoryContinuous> {

  late String apiUrl;

  List<ContinuousPoints> _dataSource = [];

  @override
  void initState(){
    apiUrl = widget.API_URL;
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
      width: 500,
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
            series: <ScatterSeries<ContinuousPoints, int>>[
              // Initialize line series with data points
              ScatterSeries <ContinuousPoints, int>(
                color: Colors.lightBlue,
                dataSource: _dataSource,
                xValueMapper: (ContinuousPoints value, _) => value.cycle,
                yValueMapper: (ContinuousPoints value, _) => value.temp,
              ),
            ],

          )
        ],
      ),
    );
  }
}

class ContinuousPoints {
  ContinuousPoints (this.cycle, this.temp);
  final int cycle;
  final double temp;
}

Future<List<ContinuousPoints>> fetchContinuousData(String url) async {
  final response = await http.get(Uri.parse('${url}/continuous'));
  final response_json = json.decode(response.body);

  List<ContinuousPoints> dataPoints = [];
  for (var point in response_json) {
    int cycle = point["cycle"].toInt();
    double current_temp = point["current_temp"].toDouble();
    ContinuousPoints continuousPoints = ContinuousPoints(cycle, current_temp);
    dataPoints.add(continuousPoints);
  }

  return dataPoints;
}

