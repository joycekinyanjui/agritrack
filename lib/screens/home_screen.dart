import 'dart:convert';
import 'package:bwoken/auth/auth_service.dart';
import 'package:bwoken/screens/Forecast_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void logout() {
    //get auth service
    final auth = AuthService();

    auth.signOut();
  }

  Map<String, dynamic>? weatherData;
  bool isLoading = false;
  String? errorMessage;
  LatLng? _userLocation;
  final TextEditingController _cityController = TextEditingController();

  final String apiKey =
      "8a118f1d475b1a46701351b862ebddb9"; // Replace with your actual API Key

  /// ✅ GETS USER LOCATION USING GPS
  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        errorMessage = "Location services are disabled!";
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          errorMessage = "Location permission denied!";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        errorMessage = "Location permissions are permanently denied!";
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
    });

    _fetchWeatherData(position.latitude, position.longitude);
  }

  /// ✅ FETCHES WEATHER DATA BASED ON GPS COORDINATES OR CITY NAME
  Future<void> _fetchWeatherData(
      [double? latitude, double? longitude, String? city]) async {
    String url;
    if (city != null) {
      url =
          "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric";
    } else {
      url =
          "https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric";
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          weatherData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Weather data not found!";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load data. Check your internet.";
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/soil_health_screen');
              },
              child: Text('Check Soil Health')),
          IconButton(onPressed: logout, icon: Icon(Icons.logout)),
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/profile_page_screen');
              },
              icon: Icon(Icons.settings))
        ],
        title: const Text("AgriTrack Dashboard",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.lightGreen,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /// ✅ SEARCH BAR
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: "Enter City Name",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    if (_cityController.text.isNotEmpty) {
                      _fetchWeatherData(null, null, _cityController.text);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),

            if (isLoading) const CircularProgressIndicator(),
            if (errorMessage != null)
              Text(errorMessage!,
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),

            if (weatherData != null)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                color: Colors.green[100],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        "${weatherData!['name']}",
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                      Image.network(
                        "https://openweathermap.org/img/wn/${weatherData!['weather'][0]['icon']}@2x.png",
                        scale: 1.5,
                      ),
                      Text("${weatherData!['main']['temp']}°C",
                          style: const TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold)),
                      Text("Humidity: ${weatherData!['main']['humidity']}%"),
                      Text(
                          "Condition: ${weatherData!['weather'][0]['description']}"),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ForecastScreen(city: weatherData!['name']),
                            ),
                          );
                        },
                        child: const Text("View 7-Day Forecast"),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),

            /// ✅ MAP WITH USER LOCATION
            Expanded(
              child: _userLocation == null
                  ? const Center(child: Text("Fetching location..."))
                  : FlutterMap(
                      options: MapOptions(
                        initialCenter: _userLocation!,
                        initialZoom: 12,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: ['a', 'b', 'c'],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _userLocation!,
                              width: 80,
                              height: 80,
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
