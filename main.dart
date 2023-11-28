import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter/cupertino.dart';

import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const CupertinoApp(
    title: 'Navigation Basics',
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

  void _loadCSV() async {
    final _rawData = await rootBundle.loadString("assets/car-sales-joo.csv");
    List<List<dynamic>> _listData =
        const CsvToListConverter().convert(_rawData);
    setState(() {
      _data = _listData;
      button = (button == 0) ? 1 : 0; // Toggle the button state
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
            if (button == 1)
              ListView.builder(
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

            Align(
              alignment: Alignment
                  .bottomRight, // Align the "Go back" button to the bottom-right corner
              child: CupertinoButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Go back!'),
              ),
            ),
            Align(
              alignment: Alignment
                  .bottomCenter, // Align the "Read CSV" button to the bottom-left corner
              child: CupertinoButton(
                onPressed: () {
                   // Call the function to read the CSV file and toggle visibility
                },
                child: const Text('plot'),
              ),
            ),
            Align(
              alignment: Alignment
                  .bottomLeft, // Align the "Read CSV" button to the bottom-left corner
              child: CupertinoButton(
                onPressed: () {
                  _loadCSV(); // Call the function to read the CSV file and toggle visibility
                },
                child: const Text('Read CSV'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
