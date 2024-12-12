import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: EarthquakeListPage(),
    );
  }
}

class EarthquakeListPage extends StatefulWidget {
  const EarthquakeListPage({super.key});

  @override
  _EarthquakeListPageState createState() => _EarthquakeListPageState();
}

class _EarthquakeListPageState extends State<EarthquakeListPage> {
  List<dynamic> _earthquakeData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEarthquakeData();
  }

  Future<void> fetchEarthquakeData() async {
    const String apiUrl =
        'https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson&starttime=2022-03-05&endtime=2022-03-06&limit=10';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _earthquakeData = data['features'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception("Failed to load data");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('TP',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _earthquakeData.length,
              itemBuilder: (context, index) {
                final item = _earthquakeData[index];
                final properties = item['properties'];
                final place = properties['place'];
                final magnitude = properties['mag'];
                final type = properties['type'];

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'M ${magnitude.toStringAsFixed(1)}',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    '$place',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  )
                                ],
                              ),
                            ),
                            Text(type,
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[600])),
                          ],
                        ),
                      )

                      // ListTile(
                      //   contentPadding: const EdgeInsets.all(16),
                      //   title: Text(
                      //     "M ${magnitude.toStringAsFixed(1)} - $place",
                      //     style: const TextStyle(
                      //       fontSize: 16,
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //   ),
                      //   subtitle: Text(
                      //     type,
                      //     style: TextStyle(
                      //       fontSize: 14,
                      //       color: Colors.grey[600],
                      //     ),
                      //   ),
                      //   leading: Icon(
                      //     type == 'earthquake'
                      //         ? Icons.public
                      //         : Icons.construction,
                      //     color: Colors.orange,
                      //     size: 36,
                      //   ),
                      // ),
                      ),
                );
              },
            ),
    );
  }
}
