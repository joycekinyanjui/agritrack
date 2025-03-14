import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForecastScreen extends StatefulWidget {
  final String city;
  const ForecastScreen({super.key, required this.city});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  List<dynamic>? forecastData;
  final String apiKey = "8a118f1d475b1a46701351b862ebddb9";

  Future<void> _fetchForecast() async {
    final url =
        "https://api.openweathermap.org/data/2.5/forecast?q=${widget.city}&appid=$apiKey&units=metric";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          forecastData = jsonDecode(response.body)['list'];
        });
      }
    } catch (e) {
      print("Error fetching forecast: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchForecast();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.city} - 7 Day Forecast")),
      body: forecastData == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: 7,
              itemBuilder: (context, index) {
                var day = forecastData![index * 8];
                return ListTile(
                  title: Text(
                      "${day['main']['temp']}°C - ${day['weather'][0]['description']}"),
                );
              },
            ),
    );
  }
}
