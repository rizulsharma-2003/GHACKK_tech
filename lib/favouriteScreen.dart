import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesListWidget extends StatefulWidget {
  @override
  _FavoritesListWidgetState createState() => _FavoritesListWidgetState();
}

class _FavoritesListWidgetState extends State<FavoritesListWidget> {
  List<String> favoriteMovies = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Load the list of favorite movies from SharedPreferences
      favoriteMovies = prefs.getStringList('favorite_movies') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return favoriteMovies.isEmpty
        ? Center(child: Text('No favorite movies added.'))
        : ListView.builder(
      itemCount: favoriteMovies.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            favoriteMovies[index],
            style: TextStyle(color: Colors.black), // Set text color to black
          ),
          onTap: () {
            // Add any action for the onTap event here if needed
          },
        );
      },
    );
  }

}
