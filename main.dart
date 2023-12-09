import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter/cupertino.dart';

import 'package:fl_chart/fl_chart.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:path_provider/path_provider.dart';

import 'firebase_options.dart';

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
    return MaterialApp(
      home: FirstRoute(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FirstRoute extends StatelessWidget {
  const FirstRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.black,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('First Route'),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: StadiumBorder()),
                    // color: Colors.green,
                    // borderRadius: BorderRadius.circular(25),
                    child: const Text('Firebase Button'),
                    onPressed: () {
                      // Load CSV data in CsvScreen when left button is pressed
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
                  child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: StadiumBorder()),
                    // color: Colors.cyan,
                    // borderRadius: BorderRadius.circular(25),
                    child: const Text('Open route'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => const SecondRoute()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CsvScreen extends StatefulWidget {
  @override
  _CsvScreenState createState() => _CsvScreenState();
}

class _CsvScreenState extends State<CsvScreen> {
  List<List<dynamic>> data = [];
  @override
  void initState() {
    super.initState();
    loadCsv();
  }

  Future<void> loadCsv() async {
    try {
      final storage = FirebaseStorage.instance;
      final csvDataRef = storage.ref('csv/ECG.csv');
      final dataBytes = await csvDataRef.getData();

      if (dataBytes == null) {
        // Handle the case where the data is null
        print('CSV data is null.');
        return;
      }

      final csvData = String.fromCharCodes(dataBytes);
      final decoded = CsvToListConverter().convert(csvData);
      setState(() {
        data = decoded;
      });
    } catch (error) {
      print('Error loading CSV: $error');
      // Handle error, e.g., show an error message to the user
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to load CSV data. Please try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CSV Data'),
      ),
      body: data.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: data.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    // height: 680,
                    // child: ListView.builder(
                    //   itemCount: data.length,
                    //   itemBuilder: (_, index) {
                    child: Card(
                      margin: const EdgeInsets.all(3),
                      color: index == 0 ? Colors.amber : Colors.white,
                      child: ListTile(
                        leading: Text(data[index][0].toString()),
                        title: Text(data[index][1].toString()),
                        trailing: Text(data[index][2].toString()),
                      ),
                      // );
                      // },
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            // height: 680,
            child: Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data
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
      navigationBar: CupertinoNavigationBar(
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
