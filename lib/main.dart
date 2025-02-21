import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
                      MaterialPageRoute(builder: (context) => MyHomePage()),
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

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = MoviesPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: MediaQuery.of(context).size.width >= 600,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.movie),
                  label: Text('Películas'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite),
                  label: Text('Favoritos'),
                ),
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ),
          ),
        ],
      ),
    );
  }
}

class MoviesPage extends StatelessWidget {
  final List<Map<String, String>> movies = [
    {
      'title': 'Inception',
      'image': './images/inception.jpg',
      'genre': 'Sci-Fi',
      'duration': '148 min',
      'year': '2010'
    },
    {
      'title': 'Interstellar',
      'image': './images/interstellar.jpg',
      'genre': 'Sci-Fi',
      'duration': '169 min',
      'year': '2014'
    },
    {
      'title': 'The Dark Knight',
      'image': './images/dark_knight.jpg',
      'genre': 'Action',
      'duration': '152 min',
      'year': '2008'
    }
  ];

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Listado de Películas'),
        backgroundColor: Colors.black,
      ),
      body: ListView.builder(
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          final isFavorite = appState.favorites.contains(movie['title']);
          return Card(
            color: Colors.grey[900],
            child: ListTile(
              leading: Image.asset(movie['image']!, width: 50, height: 75, fit: BoxFit.cover),
              title: Text(movie['title']!, style: TextStyle(color: Colors.white)),
              subtitle: Text("${movie['genre']} | ${movie['duration']} | ${movie['year']}", style: TextStyle(color: Colors.white70)),
              trailing: IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: () {
                  appState.toggleFavorite(movie['title']!);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No tienes favoritos aún.', style: TextStyle(color: Colors.white)),
      );
    }

    return ListView(
      children: appState.favorites.map((movie) => ListTile(
            leading: Icon(Icons.favorite, color: Colors.red),
            title: Text(movie, style: TextStyle(color: Colors.white)),
          )).toList(),
    );
  }
}
