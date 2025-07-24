import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.deepPurple,
      textTheme: GoogleFonts.poppinsTextTheme(),
    ),
    home: const WeatherApp(),
  ));
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  final TextEditingController control = TextEditingController();
  bool isLoading = false;

  void search() async {
    FocusScope.of(context).unfocus();
    final city = control.text.trim();
    if (city.isEmpty) return;

    const apiKey = "f48487f72a3fa0cd53f97d4e694e7a8b";
    final url =
        "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=f48487f72a3fa0cd53f97d4e694e7a8b&units=metric";

    setState(() => isLoading = true);

    try {
      final response = await http.get(Uri.parse(url));
      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final temp = data['main']['temp'];
        final desc = data['weather'][0]['description'];
        final humidity = data['main']['humidity'];
        final icon = data['weather'][0]['icon'];

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: const Text("Weather Forecast"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.network(
                  'https://openweathermap.org/img/wn/$icon@2x.png',
                  height: 80,
                ),
                const SizedBox(height: 12),
                Text("🌡 Temperature: $temp °C"),
                Text("🌥 Description: ${desc.toUpperCase()}"),
                Text("💧 Humidity: $humidity%"),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } else {
        showError("City not found.");
      }
    } catch (e) {
      setState(() => isLoading = false);
      showError("Something went wrong. Check your connection.");
    }
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🌤 Weather App"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          elevation: 6,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: control,
                  decoration: InputDecoration(
                    hintText: "Enter city name",
                    prefixIcon: const Icon(Icons.location_city_outlined),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: search,
                    icon: const Icon(Icons.search),
                    label: const Text("Get Weather"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
