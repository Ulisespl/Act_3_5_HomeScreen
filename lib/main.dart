import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mi Aplicación',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.dark(),
        ),
        home: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            './images/background.jpg',
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.7),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Bienvenido a Mi Aplicación',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MoviesPage()),
                    );
                  },
                  child: Text('Entrar a la App'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var favorites = <String>[];

  void toggleFavorite(String movie) {
    if (favorites.contains(movie)) {
      favorites.remove(movie);
    } else {
      favorites.add(movie);
    }
    notifyListeners();
  }
}

class MoviesPage extends StatefulWidget {
  @override
  _MoviesPageState createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> {
  List<dynamic> movies = [];
  final String defaultImage = "./images/default.jpg";

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    final String apiKey = "d9f99d6182bf6d96b0838b0eaaf60fe2";
    final String hash = "e36b33494b3ab370c2e7c31a9152ec1b";
    final String ts = "1";
    final String url = "http://gateway.marvel.com/v1/public/characters?apikey=$apiKey&hash=$hash&ts=$ts";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        movies = data['data']['results'];
      });
    } else {
      throw Exception('Error al cargar los datos de la API');
    }
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Listado de Personajes'),
        backgroundColor: Colors.black,
      ),
      body: movies.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                final isFavorite = appState.favorites.contains(movie['name']);
                final imageUrl = movie['thumbnail'] != null
                    ? "${movie['thumbnail']['path']}.${movie['thumbnail']['extension']}"
                    : defaultImage;
                final releaseDate = movie.containsKey('modified') ? movie['modified'].split('T')[0] : 'Desconocida';
                
                return Card(
                  color: Colors.grey[900],
                  child: ListTile(
                    leading: imageUrl.startsWith('http')
                        ? Image.network(imageUrl, width: 50, height: 75, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) {
                            return Image.asset(defaultImage, width: 50, height: 75, fit: BoxFit.cover);
                          })
                        : Image.asset(defaultImage, width: 50, height: 75, fit: BoxFit.cover),
                    title: Text(movie['name'], style: TextStyle(color: Colors.white)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Descripción: ${movie['description'].isNotEmpty ? movie['description'] : 'No disponible'}", 
                          style: TextStyle(color: Colors.white70)),
                        Text("Fecha de lanzamiento: $releaseDate", style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: () {
                        appState.toggleFavorite(movie['name']);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
