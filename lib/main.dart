import 'dart:convert'; // For jsonEncode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:testi/registration%202.dart';
import 'homepage.dart';
import 'login.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginScreen(),
        '/registration': (context) => const RegistrationScreen(),

        // You would typically have a '/register' route here as well
        // '/register': (context) => const RegistrationScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<String> futureData;
  String postResponse = '';
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureData = getData();
  }

  Future<String> getData() async {
    final url = Uri.http('192.168.10.129:3000','/new'); 
    final response = await http.get(url);

    if (response.statusCode == 200) {
      print('GET response: ${response.body}');
      return response.body;
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  Future<String> postData(String name) async {
    final url = Uri.http('192.168.10.129:3000', '/data'); // Change to your server IP
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name}),
    );

    if (response.statusCode == 200) {
      print('POST response: ${response.body}');
      return response.body;
    } else {
      throw Exception('Failed to post data: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Viewer')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FutureBuilder<String>(
              future: futureData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Text('GET response: ${snapshot.data ?? 'No data'}');
                }
              },
            ),
            const SizedBox(height: 30),
            TextField(
              controller:nameController,
            ),
            ElevatedButton(
              onPressed: () async {
                String response = await postData(nameController.text);
                setState(() {
                  postResponse = response;
                });
              },
              child: const Text('Send Data (POST)'),
            ),
            const SizedBox(height: 20),
            Text('POST response: $postResponse'),
          ],
        ),
      ),
    );
  }
}
