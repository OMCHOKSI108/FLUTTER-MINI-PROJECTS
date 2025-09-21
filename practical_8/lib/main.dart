import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => const MaterialApp(home: ApiPage());
}

class ApiPage extends StatelessWidget {
  const ApiPage({super.key});

  Future<List<dynamic>> fetchPosts() async {
    final res = await http.get(
      Uri.parse('https://jsonplaceholder.typicode.com/posts'),
    );
    if (res.statusCode == 200) return json.decode(res.body) as List<dynamic>;
    throw Exception('Failed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Practical 8 - API')),
      body: FutureBuilder<List<dynamic>>(
        future: fetchPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          final list = snapshot.data ?? [];
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (c, i) => ListTile(
              title: Text(list[i]['title'] ?? ''),
              subtitle: Text(list[i]['body'] ?? ''),
            ),
          );
        },
      ),
    );
  }
}
