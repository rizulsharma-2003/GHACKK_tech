import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'favouriteScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List movies = [];
  List<String> _favoriteMovies =[];
  PageController _pageController = PageController(viewportFraction: 0.85);

  @override
  void initState() {
    super.initState();
    fetchMovies();
    _loadFavorites();
    Timer.periodic(Duration(seconds: 2), (timer) {
      _animateToNextPage();
    });
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Get the keys where the value is true (favorite movies)
      _favoriteMovies = prefs.getKeys().where((key) => prefs.getBool(key) == true).toList();
    });
  }



  Future<void> fetchMovies() async {
    final response = await http.get(Uri.parse('https://api.tvmaze.com/search/shows?q=all'));
    if (response.statusCode == 200) {
      setState(() {
        movies = json.decode(response.body);
      });
      print(movies);
    } else {
      throw Exception('Failed to load movies');
    }
  }

  void _animateToNextPage() {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        (_pageController.page!.toInt() + 1) % movies.length,
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  String stripHtmlTags(String htmlString) {
    final document = parse(htmlString);
    return document.body?.text ?? '';
  }

  String getImageUrl(Map<String, dynamic>? image) {
    return image?["medium"] ?? 'https://via.placeholder.com/150';
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      Navigator.pushReplacementNamed(context, '/search');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/search');
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2.0),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: TextField(
                enabled: false,
                decoration: InputDecoration(
                  hintText: 'Search Movies...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text('Menu', style: TextStyle(fontSize: 24)),
              decoration: BoxDecoration(
                color: Colors.black87,
              ),
            ),
            ListTile(
              title: Text('Favorites'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 400, // Set the desired height for the container
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: FavoritesListWidget(), // Embedding the favorites list inside the container
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (movies.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    height: 250,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: null,
                      itemBuilder: (context, index) {
                        final movieIndex = index % movies.length;
                        final movie = movies[movieIndex];
                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/details', arguments: movie);
                          },
                          child: Container(
                            margin: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              image: DecorationImage(
                                image: NetworkImage(getImageUrl(movie['show']['image'])),
                                fit: BoxFit.cover,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.redAccent.withOpacity(0.3),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                    gradient: LinearGradient(
                                      colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 10,
                                  left: 10,
                                  child: Text(
                                    movie['show']['name'],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
              if (movies.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Continue Watching',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: movies.length > 4 ? 4 : movies.length,
                    itemBuilder: (context, index) {
                      final movie = movies[index]['show'];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/details', arguments: movie);
                        },
                        child: Container(
                          width: 120,
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Column(
                            children: [
                              Image.network(
                                getImageUrl(movie['image']),
                                height: 150,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(child: Icon(Icons.error));
                                },
                              ),
                              Text(movie['name'], style: TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              if (movies.length > 4) ...[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Recent Searches',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: movies.length > 8 ? 4 : movies.length - 4,
                    itemBuilder: (context, index) {
                      final movie = movies[index + 4]['show'];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/details', arguments: movie);
                        },
                        child: Container(
                          width: 120,
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Column(
                            children: [
                              Image.network(
                                getImageUrl(movie['image']),
                                height: 150,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(child: Icon(Icons.error));
                                },
                              ),
                              Text(movie['name'], style: TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'All Movies',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: movies.length > 8 ? movies.length - 8 : 0,
                itemBuilder: (context, index) {
                  final movie = movies[index + 8]['show'];
                  String summary = stripHtmlTags(movie['summary'] ?? '');
                  String imageUrl = getImageUrl(movie['image']);

                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/details', arguments: movie);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        image: DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(child: Icon(Icons.error));
                              },
                            ),
                          ),
                          Container(
                            color: Colors.black54,
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  movie['name'],
                                  style: TextStyle(color: Colors.white, fontSize: 14),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  summary,
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
