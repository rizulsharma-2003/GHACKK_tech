import 'package:flutter/material.dart';
import 'package:html/parser.dart';

class DetailsScreen extends StatefulWidget {
  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  bool _isExpanded = false;

  String stripHtmlTags(String htmlString) {
    final document = parse(htmlString);
    return document.body?.text ?? '';
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
                      // Genres (optional)
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
    );
  }
}
