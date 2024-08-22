import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
        title: 'Hola Mundo',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 115, 176, 62)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];
  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void deleteWord(word) {
    if (favorites.contains(word)) {
      favorites.remove(word);
    } else {
      print("no hay nada pa $word");
    }
    notifyListeners();
  }

  void showConfirmationDialog(BuildContext context, word) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text.rich(
            TextSpan(
              text: '¿Estás seguro de que deseas eliminar la palabra: ',
              children: <TextSpan>[
                TextSpan(
                  text: word.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: '?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
            ),
            TextButton(
              child: Text('Eliminar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                deleteWord(
                    word); // Llama a la función que realiza la acción de eliminación
              },
            ),
          ],
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  bool isRailVisible = false; // Booleano para controlar la visibilidad

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();

        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(isRailVisible
                    ? Icons.close
                    : Icons.menu), // Ícono cambia según el estado
                onPressed: () {
                  setState(() {
                    isRailVisible = !isRailVisible; // Cambiar la visibilidad
                  });
                },
              ),
              Text.rich(TextSpan(
                  text: "Mi Primer Flutter App 😊",
                  style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
        ),
        body: Row(
          children: [
            if (isRailVisible)
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                        icon: Icon(Icons.home), label: Text("Inicio")),
                    NavigationRailDestination(
                        icon: Icon(Icons.favorite), label: Text("Favoritos")),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    isRailVisible = false;
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
            Expanded(
                child: Container(
              // color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            )),
          ],
        ),
      );
    });
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text('Tu tienes '
                '${appState.favorites.length} elementos favoritos:'),
          ),
        ),
        for (var pair in appState.favorites)
          ListTile(
            title: Text(pair.asString),
            trailing: ElevatedButton.icon(
              onPressed: () {
                appState.showConfirmationDialog(context, pair);
              },
              icon: Icon(Icons.delete),
              label: Text("Eliminar"),
            ),
          ),
      ],
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BigCard(pair: pair),
            SizedBox(
              height: 25,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    appState.toggleFavorite();
                  },
                  icon: Icon(icon),
                  label: Text("Me Gusta"),
                ),
                SizedBox(
                  width: 10,
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.skip_next),
                  onPressed: () {
                    appState.getNext();
                  },
                  label: Text('Siguiente'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displaySmall!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      color: theme.colorScheme.primary,
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}
