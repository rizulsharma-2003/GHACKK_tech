import 'package:flutter/material.dart';
import 'APIservices.dart';
import 'package:html/parser.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List searchResults = [];
  TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 1;

  Future<void> performSearch(String searchTerm) async {
    try {
      final data = await searchMovies(searchTerm);
      setState(() {
        searchResults = data;
      });
    } catch (e) {
      print(e);
    }
  }

  String stripHtmlTags(String htmlString) {
    final document = parse(htmlString);
    return document.body?.text ?? '';
  }

  String shortenText(String text, int limit) {
    return text.length > limit ? '${text.substring(0, limit)}...' : text;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (index == 1) {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2.0),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search for a movie...',
              prefixIcon: Icon(Icons.search),
              border: InputBorder.none,
            ),
            onSubmitted: (value) {
              performSearch(value);
              FocusScope.of(context).unfocus();
            },
          ),
        ),
      ),
      body: Column(
        children: [
          if (_searchController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Showing results for "${_searchController.text}"',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          SizedBox(height: 2.0),
          Expanded(
            child: searchResults.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.white, width: 2.0),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Image.asset(
                      'assets/images/GHACKK.jpg',
                      height: 150,
                      width: 150,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'No results found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
                : GridView.builder(
              padding: EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 0.2,
                childAspectRatio: 0.65,
              ),
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final movie = searchResults[index]['show'];
                final movieImage = movie['image']?['medium'] ??
                    'https://via.placeholder.com/128x192?text=No+Image';
                final movieName = movie['name'] ?? 'No title available';
                final movieSummary = movie['summary'] != null
                    ? stripHtmlTags(movie['summary'])
                    : 'No summary available';
                final shortenedSummary = shortenText(movieSummary, 100);

                return Card(
                  elevation: 0,
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/details', arguments: movie);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Image.network(
                                movieImage,
                                fit: BoxFit.cover,
                                height: 120,
                                width: 90,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  movieName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 2.0),
                                SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: Container(
                                    height: 40,
                                    child: Text(
                                      shortenedSummary,
                                      style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
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
        selectedItemColor: Colors.red,
        onTap: _onItemTapped,
      ),
    );
  }
}
