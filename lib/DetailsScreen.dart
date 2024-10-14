import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:html/parser.dart';

class DetailsScreen extends StatefulWidget {
  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  bool _isExpanded = false;
  bool _isFavorite = false;
  double _currentRating = 0.0;

  String stripHtmlTags(String htmlString) {
    final document = parse(htmlString);
    return document.body?.text ?? '';
  }

  @override
  void initState() {
    super.initState();
    // Load favorite status and rating from SharedPreferences
    _loadFavoriteStatus();
    _loadMovieRating();
  }

  Future<void> _loadFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final movie = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final movieTitle = movie['name'] ?? 'Movie Title';

    setState(() {
      _isFavorite = prefs.getBool(movieTitle) ?? false;
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final movie = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final movieTitle = movie['name'] ?? 'Movie Title';

    setState(() {
      _isFavorite = !_isFavorite;
    });

    // Retrieve the list of favorite movies
    List<String> favoriteMovies = prefs.getStringList('favorite_movies') ?? [];

    if (_isFavorite) {
      await prefs.setBool(movieTitle, true);
      // Add the movie to the list of favorites if it's not already there
      if (!favoriteMovies.contains(movieTitle)) {
        favoriteMovies.add(movieTitle);
      }
    } else {
      await prefs.remove(movieTitle);
      // Remove the movie from the list of favorites
      favoriteMovies.remove(movieTitle);
    }

    // Save the updated list of favorites
    await prefs.setStringList('favorite_movies', favoriteMovies);
  }

  Future<void> _loadMovieRating() async {
    final prefs = await SharedPreferences.getInstance();
    final movie = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final movieTitle = movie['name'] ?? 'Movie Title';

    setState(() {
      _currentRating = prefs.getDouble('${movieTitle}_rating') ?? 0.0;
    });
  }

  Future<void> _saveMovieRating(double rating) async {
    final prefs = await SharedPreferences.getInstance();
    final movie = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final movieTitle = movie['name'] ?? 'Movie Title';

    setState(() {
      _currentRating = rating;
    });

    await prefs.setDouble('${movieTitle}_rating', rating);
  }

  @override
  Widget build(BuildContext context) {
    final movie = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    final cleanedSummary = stripHtmlTags(movie['summary'] ?? '');
    final imageUrl = movie['image']?['original'] ?? '';
    final imageWidth = movie['image']?['original_width'] ?? 500;
    final imageHeight = movie['image']?['original_height'] ?? 700;

    final aspectRatio = imageWidth / imageHeight;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 0.5,
              colors: [
                Colors.red.withOpacity(0.2),
                Colors.red.withOpacity(0.2),
              ],
            ),
          ),
          child: AppBar(
            title: Text(movie['name'] ?? 'Movie Details'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.bottomCenter,
            radius: 0.6,
            colors: [
              Colors.red,
              Colors.red.withOpacity(0.2),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 40.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: AspectRatio(
                            aspectRatio: aspectRatio,
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 20.0,
                              spreadRadius: 5.0,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 20,
                      right: 20,
                      child: Text(
                        movie['name'] ?? 'Movie Title',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black.withOpacity(0.7),
                              offset: Offset(3, 3),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (movie['genres'] != null && movie['genres'].isNotEmpty)
                        Text(
                          'Genres: ${movie['genres'].join(', ')}',
                          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
                        ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (movie['status'] != null)
                            Text(
                              'Status: ${movie['status']}',
                              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                            ),
                          if (movie['runtime'] != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text(
                                'Runtime: ${movie['runtime']} min',
                                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Summary',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 8),
                      AnimatedCrossFade(
                        firstChild: Text(
                          cleanedSummary.length > 150
                              ? cleanedSummary.substring(0, 150) + '...'
                              : cleanedSummary,
                          style: TextStyle(fontSize: 16),
                        ),
                        secondChild: Text(
                          cleanedSummary,
                          style: TextStyle(fontSize: 16),
                        ),
                        crossFadeState: _isExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: Duration(milliseconds: 300),
                      ),
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        child: Text(
                          _isExpanded ? 'Read Less' : 'Read More',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      if (movie['network'] != null)
                        Text(
                          'Network: ${movie['network']['name']}',
                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        width: double.infinity,
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: FloatingActionButton.extended(
          onPressed: () {},
          label: Column(
            children: [
              Text(
                'Rate this movie',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 8),
              RatingBar.builder(
                initialRating: _currentRating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  _saveMovieRating(rating);
                },
              ),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
