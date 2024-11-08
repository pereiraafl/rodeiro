import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

class LiveContinuous extends StatefulWidget {
  final String API_URL;
  const LiveContinuous({super.key, required this.API_URL});

  @override
  State<LiveContinuous> createState() => _LiveContinuousState();
}

class _LiveContinuousState extends State<LiveContinuous> {

  late String apiUrl;
  late bool isScatter = false;
  Timer? timer;
  List<ContinuousPoints>? chartData;

  late ChartSeriesController chartSeriesController_;

  @override
  void initState(){
    apiUrl = widget.API_URL;
    chartData = <ContinuousPoints>[];
    timer = Timer.periodic(const Duration(milliseconds: 500), _updateDataSource);
    super.initState();
  }

  Future<void> _updateDataSource(Timer timer) async {
    ContinuousPoints continuosPoint = await fetchContinuousData(apiUrl);
    chartData!.add(continuosPoint);
    if (chartData?.length == 100) {
      chartData?.removeAt(0);
      chartSeriesController_.updateDataSource(
        addedDataIndexes: <int>[chartData!.length - 1],
        removedDataIndexes: <int>[0],
      );
    } else {
      chartSeriesController_.updateDataSource(
        addedDataIndexes: <int>[chartData!.length - 1],
      );
    }
  }

  Future<ContinuousPoints> fetchContinuousData(String url) async {
    final response = await http.get(Uri.parse('${url}/continuous/last'));
    final response_json = json.decode(response.body);
    int cycle = response_json["cycle"].toInt();
    double current_temp = response_json["current_temp"].toDouble();
    ContinuousPoints continuousPoints = ContinuousPoints(cycle, current_temp, chartData!.length);
    return continuousPoints;
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      height: 320,
      child: Column(
        children: [
          SfCartesianChart(
            title: ChartTitle(
              text: "Temperatura ao vivo",
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
            series: <FastLineSeries<ContinuousPoints, int>>[
    // Initialize line series with data points
                FastLineSeries<ContinuousPoints, int>(
                onRendererCreated: (ChartSeriesController controller) {
                  chartSeriesController_ = controller;
                },
                color: Colors.lightBlue,
                dataSource: chartData,
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

