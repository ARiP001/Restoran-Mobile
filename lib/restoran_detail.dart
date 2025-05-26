import 'package:flutter/material.dart';
import 'package:cobaflutter/restoran_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RestoranDetail extends StatefulWidget {
  final Restoran restoran;
  const RestoranDetail({super.key, required this.restoran});

  @override
  State<RestoranDetail> createState() => _RestoranDetailState();
}

class _RestoranDetailState extends State<RestoranDetail> {
  bool isFavorite = false;
  String? _username;

  @override
  void initState() {
    super.initState();
    _loadUsernameAndFavorite();
  }

  Future<void> _loadUsernameAndFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    setState(() {
      _username = username;
    });
    if (username != null) {
      final key = 'favorite_${username}_${widget.restoran.id}';
      setState(() {
        isFavorite = prefs.getBool(key) ?? false;
      });
    }
  }

  Future<void> toggleFavorite() async {
    if (_username == null) return;
    final prefs = await SharedPreferences.getInstance();
    final key = 'favorite_${_username}_${widget.restoran.id}';
    final dataKey = 'favorite_data_${_username}_${widget.restoran.id}';
    setState(() {
      isFavorite = !isFavorite;
    });
    await prefs.setBool(key, isFavorite);
    if (isFavorite) {
      // Save restaurant data as JSON string
      final restoData = {
        'id': widget.restoran.id,
        'name': widget.restoran.name,
        'pictureId': widget.restoran.pictureId,
        'city': widget.restoran.city,
        'rating': widget.restoran.rating,
      };
      await prefs.setString(dataKey, restoData.toString());
    } else {
      await prefs.remove(dataKey);
    }
    // Debug: print all favorite keys and their values
    print('--- SharedPreferences favorite keys ---');
    for (var k in prefs.getKeys()) {
      if (k.startsWith('favorite_')) {
        print('$k: ${prefs.get(k)}');
      }
    }
    print('--------------------------------------');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Restaurant Detail"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              "https://restaurant-api.dicoding.dev/images/medium/${widget.restoran.pictureId}",
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          widget.restoran.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                      ),
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : null,
                        ),
                        onPressed: toggleFavorite,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 4),
                      Text(
                        widget.restoran.city,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        widget.restoran.rating.toString(),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.restoran.description,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}