import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Anime and Pokémon Search',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _searchQuery = '';
  String _searchType = 'anime'; // Default search type is anime
  Map<String, dynamic>? _resultData;

  // Función para buscar anime
  Future<void> _search() async {
    if (_searchQuery.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingrese un nombre de anime o Pokémon.')),
      );
      return;
    }

    try {
      Map<String, dynamic>? data;
      if (_searchType == 'anime') {
        data = await fetchAnime(_searchQuery);
      } else {
        data = await fetchPokemon(_searchQuery.toLowerCase());
      }

      setState(() {
        _resultData = data;
      });
    } catch (e) {
      setState(() {
        _resultData = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró el dato.')),
      );
    }
  }

  // Función para cambiar entre Anime y Pokémon y limpiar la búsqueda
  void _changeSearchType(String type) {
    setState(() {
      _searchType = type;
      _searchQuery = '';  // Limpiar la barra de búsqueda al cambiar de tipo de búsqueda
      _resultData = null;  // Limpiar los resultados
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anime & Pokémon Search'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _searchType == 'anime'
                ? [Colors.blueAccent, Colors.white]
                : [Colors.orange, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Menú para seleccionar anime o Pokémon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('Anime'),
                  selected: _searchType == 'anime',
                  onSelected: (selected) {
                    if (selected) {
                      _changeSearchType('anime');
                    }
                  },
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text('Pokémon'),
                  selected: _searchType == 'pokemon',
                  onSelected: (selected) {
                    if (selected) {
                      _changeSearchType('pokemon');
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo de texto para ingresar la búsqueda
            TextField(
              decoration: InputDecoration(
                labelText: _searchType == 'anime' ? 'Buscar Anime' : 'Buscar Pokémon',
                labelStyle: const TextStyle(color: Colors.black),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) => _searchQuery = value,
            ),
            const SizedBox(height: 10),

            // Botón de búsqueda
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _search,
              child: const Text('Buscar', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 20),

            // Mostrar resultados de búsqueda
            if (_resultData != null) ...[
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Mostrar imagen del anime o Pokémon
                      if (_searchType == 'anime') ...[
                        Image.network(
                          _resultData!['image_url'] ?? 'https://via.placeholder.com/150',
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _resultData!['title']?.toString().toUpperCase() ?? 'Título no disponible',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _resultData!['synopsis'] ?? 'Sinopsis no disponible',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Estado: ${_resultData!['status'] ?? 'Desconocido'}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ] else ...[
                        Image.network(
                          _resultData!['sprites']['front_default'],
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _resultData!['name'].toString().toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                const Text(
                                  'Altura',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text('${_resultData!['height']}'),
                              ],
                            ),
                            Column(
                              children: [
                                const Text(
                                  'Peso',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text('${_resultData!['weight']}'),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          children: (_resultData!['types'] as List)
                              .map((type) => Chip(
                                    label: Text(
                                      type['type']['name'],
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.red,
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Habilidades: ' +
                              (_resultData!['abilities'] as List)
                                  .map((ability) => ability['ability']['name'])
                                  .join(', '),
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Estadísticas: ' +
                              (_resultData!['stats'] as List)
                                  .map((stat) => '${stat['stat']['name']}: ${stat['base_stat']}')
                                  .join(', '),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

// Función para obtener información del anime
Future<Map<String, dynamic>> fetchAnime(String name) async {
  final url = 'https://api.jikan.moe/v4/anime?q=$name&limit=1';
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['data'] != null && data['data'].isNotEmpty) {
      return data['data'][0];
    } else {
      throw Exception('Anime no encontrado');
    }
  } else {
    throw Exception('Failed to load anime');
  }
}

// Función para obtener información del Pokémon
Future<Map<String, dynamic>> fetchPokemon(String name) async {
  final url = 'https://pokeapi.co/api/v2/pokemon/$name';
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load Pokémon');
  }
}
