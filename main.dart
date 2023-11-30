import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter/cupertino.dart';

import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const CupertinoApp(
    title: 'Navigation Basics',
    debugShowCheckedModeBanner:false,

    home: FirstRoute(),

  ));
}

class FirstRoute extends StatelessWidget {
  const FirstRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.white,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('First Route'),
      ),
      child: Center(
        child: CupertinoButton(
          child: const Text('Open route'),
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => const SecondRoute()),
            );
          },
        ),
      ),
    );
  }
}

class SecondRoute extends StatefulWidget {
  const SecondRoute({Key? key}) : super(key: key);

  @override
  _SecondRouteState createState() => _SecondRouteState();
}

class _SecondRouteState extends State<SecondRoute> {
  List<List<dynamic>> _data = [];
  int button = 0;
  bool showChart = false;

  void _loadCSV() async {
    final _rawData = await rootBundle.loadString("assets/ECG.csv");
    List<List<dynamic>> _listData =
    const CsvToListConverter().convert(_rawData);
    setState(() {
      _data = _listData;
      button = (button == 0) ? 1 : 0; // Toggle the button state
    });
  }

  void _toggleChart() {
    setState(() {
      showChart = !showChart;
      button=0;
      // print(showChart);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Second Route'),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Add padding for spacing
        child: Stack(
          children: [
            if (showChart)
              Container(
                height: 680,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _data
                            .skip(1)
                            .map(
                              (row) => FlSpot(
                            row[0].toDouble(),
                            row[1].toDouble(),
                          ),
                        )
                            .toList(),
                        isCurved: true,
                        color: Colors.blue,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            Align(
              alignment: Alignment.bottomRight,
              child: CupertinoButton(
                onPressed: _toggleChart,
                child: const Text('Plot'),
                color: Colors.red,
              ),
            ),
            if (button == 1)
              Container(
                height: 680,
                // margin: Top;
                child: ListView.builder(
                  itemCount: _data.length,
                  itemBuilder: (_, index) {
                    return Card(
                      margin: const EdgeInsets.all(3),
                      color: index == 0 ? Colors.amber : Colors.white,
                      child: ListTile(
                        leading: Text(_data[index][0].toString()),
                        title: Text(_data[index][1].toString()),
                        trailing: Text(_data[index][2].toString()),
                      ),
                    );
                  },
                ),
              ),
            Align(
              alignment: Alignment.bottomLeft,
              child: CupertinoButton(
                onPressed: () {
                  _loadCSV();
                  showChart = false;

                },
                child: const Text('Read CSV'),
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
