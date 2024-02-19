import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class Dog {
  final String name;
  final String breed;
  final String age;

  Dog({
    required this.name,
    required this.breed,
    required this.age,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dog API Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DogScreen(),
    );
  }
}

class DogScreen extends StatefulWidget {
  const DogScreen({super.key});

  @override
  _DogScreenState createState() => _DogScreenState();
}

class _DogScreenState extends State<DogScreen> {
  String _searchQuery = '';
  String _dogImageUrl = '';
  String _dogName = '';
  String _dogBreed = '';
  String _dogAge = '';
  final String _apiKey = 'live_PheHxmaHZtT6ZyWgkFRoIAuaiKUjKO6hv3BtZtio5clIoQAOKPZzE8hw5vcAqUFm';

  Future<void> _fetchDogImage(String breedName) async {
    final response = await http.get(
      Uri.parse('https://api.thedogapi.com/v1/breeds/search?q=$breedName'),
      headers: {'x-api-key': _apiKey},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        final breedId = data[0]['id'];
        final breedResponse = await http.get(
          Uri.parse('https://api.thedogapi.com/v1/images/search?breed_id=$breedId'),
          headers: {'x-api-key': _apiKey},
        );
        if (breedResponse.statusCode == 200) {
          final List<dynamic> breedData = jsonDecode(breedResponse.body);
          if (breedData.isNotEmpty) {
            setState(() {
              _dogImageUrl = breedData[0]['url'];
              _dogName = data[0]['name'];
              _dogBreed = data[0]['breed_group'];
              _dogAge = data[0]['life_span'];
            });
            return;
          }
        }
      } else {
        setState(() {
          _dogImageUrl = '';
          _dogName = '';
          _dogBreed = '';
          _dogAge = '';
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('No results'),
              content: const Text('No information found for the entered dog breed.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } else {
      throw Exception('Failed to load dog image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dog caracteristic'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Enter a dog breed'),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _fetchDogImage(_searchQuery);
              },
              child: const Text('Search'),
            ),
            const SizedBox(height: 16),
            _dogImageUrl.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 150, // Adjust the height as needed
                        child: Image.network(
                          _dogImageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Name: $_dogName'),
                      Text('Breed: $_dogBreed'),
                      Text('Age: $_dogAge'),
                    ],
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}