import 'dart:async';


import 'package:csv/csv.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter/cupertino.dart';

import 'package:fl_chart/fl_chart.dart';

import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

DatabaseReference dbRef = FirebaseDatabase.instance.ref("potentiometers");
/*48aaaaaaal*/
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: FirstRoute(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RealTime extends StatefulWidget {
  const RealTime({Key? key}) : super(key: key);

  @override
  State<RealTime> createState() => _RealTimeState();
}

class _RealTimeState extends State<RealTime> {
  late DatabaseReference dbRef;

  @override
  void initState() {
    super.initState();
    dbRef = FirebaseDatabase.instance.reference();
  }

  Map<String, dynamic> flattenMap(Map<dynamic, dynamic> nestedMap,
      {String prefix = ''}) {
    Map<String, dynamic> flattenedMap = {};

    void flatten(Map<dynamic, dynamic> map, {String prefix = ''}) {
      map.forEach((key, value) {
        if (value is Map<dynamic, dynamic>) {
          flatten(value, prefix: '$prefix$key.');
        } else {
          flattenedMap['$prefix$key'] = value;
        }
      });
    }

    flatten(nestedMap);

    return flattenedMap;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-Time Data'),
      ),
      body: StreamBuilder(
        stream: dbRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            DataSnapshot dataValues = snapshot.data!.snapshot;
            Map<dynamic, dynamic>? potValues = dataValues.value as Map?;
            // print(flattenMap(potValues!));
            final output = flattenMap(potValues!);
            List<MapEntry<dynamic, dynamic>> items =
                output?.entries.toList() ?? [];
            items.sort((a, b) => a.key.compareTo(b.key));
            // print(potValues);
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(items[index].key.toString()),
                    subtitle: Text(items[index].value.toString()),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class FirstRoute extends StatelessWidget {
  const FirstRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.white60,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Home'),
        backgroundColor: Colors.cyan,
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const StadiumBorder(),
                        ),
                        child: const Text('Firebase Button'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => CsvScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const StadiumBorder(),
                        ),
                        child: const Text('Open route'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => const SecondRoute(),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const StadiumBorder(),
                        ),
                        child: const Text('real time'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RealTime(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Add your icon here
          const Positioned(
            bottom: 70.0,
            right: 16.0,
            child: Icon(
              Icons.monitor_outlined,
              color: Colors.black87,
              size: 50.0,
            ),
          ),
          // Centered text
          const Center(
            child: Text(
              'Monitor Application',
              style: TextStyle(
                decoration: TextDecoration.none,
                color: Colors.black87,
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class CsvScreen extends StatefulWidget {
  @override
  _CsvScreenState createState() => _CsvScreenState();
}

class _CsvScreenState extends State<CsvScreen> {
  late DatabaseReference dbRef2;
  List<List<dynamic>> data = [];
  List<FlSpot> spots = [];
  late Timer timer;
  int startIndex = 0;

  @override
  void initState() {
    super.initState();
    loadCsv();
    timer = Timer.periodic(const Duration(milliseconds: 100), _updateDataSource);
    dbRef2 = FirebaseDatabase.instance.reference().child("potentiometers");
  }

  Future<void> loadCsv() async {
    try {
      final storage = FirebaseStorage.instance;
      final csvDataRef = storage.ref('csv/ECG.csv');
      final dataBytes = await csvDataRef.getData();

      if (dataBytes == null) {
        print('CSV data is null.');
        return;
      }
      final csvData = String.fromCharCodes(dataBytes);
      final decoded = const CsvToListConverter().convert(csvData);
      setState(() {
        data = decoded;
        _updateSpots();
      });
    } catch (error) {
      print('Error loading CSV: $error');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to load CSV data. Please try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _updateDataSource(Timer timer) {
    setState(() {
      // Increment the startIndex to display the next 20 points
      startIndex += 1;
      // Update the spots based on the new startIndex
      _updateSpots();
    });
  }

  void _updateSpots() {
    final newPoints = data
        .skip(startIndex)
        .take(20)
        .map((row) => FlSpot(row[0].toDouble(), row[1].toDouble()))
        .toList();

    // Filter out points that are already present in the spots list
    final filteredNewPoints = newPoints.where((newPoint) {
      return !spots.any((existingPoint) =>
      existingPoint.x == newPoint.x && existingPoint.y == newPoint.y);
    }).toList();

    spots.addAll(filteredNewPoints);
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(foregroundColor: Colors.white,
        title: const Text('ECG Signal and Potentiometers',),backgroundColor: Colors.black,
      ),
      body: data.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Row(
        children: [
          Expanded(flex: 5,
            child: LineChart(
              LineChartData(
                backgroundColor: Colors.black87,
                minY: -0.8,
                maxY: 2,
                clipData: const FlClipData.all(),
                gridData: const FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  drawHorizontalLine: true,
                ),
                titlesData: const FlTitlesData(
                  show: false,
                  // rightTitles: AxisTitles(axisNameWidget: Text("Value")),
                  // topTitles: AxisTitles(axisNameWidget: Text("Time")),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.blue,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
          StreamBuilder(
            stream: dbRef2.onValue,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                DataSnapshot dataValues = snapshot.data!.snapshot;
                Map<dynamic, dynamic>? potValues =
                dataValues.value as Map?;
                List<MapEntry<dynamic, dynamic>> items =
                    potValues?.entries.toList() ?? [];
                items.sort((a, b) => a.key.compareTo(b.key));
                List keys = ["temp","Heart rate", "spo2"];
                return Expanded(
                  child: Container(
                    // color: Colors.black87,

                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: Colors.black,
                          child: ListTile(
                            title: Text(keys[index].toString(),style: const TextStyle(color: Colors.white,),),
                            subtitle: Text(items[index].value.toString(),style: const TextStyle(color: Colors.red,fontSize: 15),),

                          ),
                        );
                      },
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ],
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
      print(_data);
    });
  }

  void _toggleChart() {
    setState(() {
      showChart = !showChart;
      button = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Second Route'),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            if (showChart)
              Container(
                height: 680,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    titlesData: const FlTitlesData(show: false),
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
                        dotData: const FlDotData(show: false),

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
