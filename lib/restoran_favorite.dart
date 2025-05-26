import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latihan_responsi/restoran_detail.dart';
import 'package:latihan_responsi/restoran_model.dart';

class RestoranFavorite extends StatefulWidget {
  const RestoranFavorite({super.key});

  @override
  State<RestoranFavorite> createState() => _RestoranFavoriteState();
}

class _RestoranFavoriteState extends State<RestoranFavorite> {
  List<Map<String, dynamic>> favoriteRestos = [];
  bool isLoading = true;
  String? _username;

  @override
  void initState() {
    super.initState();
    _loadUsernameAndFavorites();
  }

  Future<void> _loadUsernameAndFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    setState(() {
      _username = username;
    });
    if (username == null) {
      setState(() {
        favoriteRestos = [];
        isLoading = false;
      });
      return;
    }
    final keys = prefs.getKeys();
    final restos = <Map<String, dynamic>>[];
    for (var key in keys) {
      if (key.startsWith('favorite_${username}_')) {
        final value = prefs.get(key);
        if (value is bool && value == true) {
          final id = key.replaceFirst('favorite_${username}_', '');
          final dataKey = 'favorite_data_${username}_$id';
          final dataString = prefs.getString(dataKey);
          if (dataString != null) {
            try {
              final map = _parseMap(dataString);
              if (map != null) restos.add(map);
            } catch (e) {
              print('Gagal parsing data favorite: $dataString');
            }
          } else {
            restos.add({'id': id, 'name': 'Restoran ID: $id'});
          }
        }
      }
    }
    setState(() {
      favoriteRestos = restos;
      isLoading = false;
    });
  }

  Map<String, dynamic>? _parseMap(String s) {
    try {
      final map = <String, dynamic>{};
      if (!s.startsWith('{') || !s.endsWith('}')) return null;
      s = s.substring(1, s.length - 1);
      final parts = s.split(', ');
      for (var part in parts) {
        final idx = part.indexOf(':');
        if (idx == -1) continue;
        final key = part.substring(0, idx);
        var value = part.substring(idx + 1).trim();
        if (value.startsWith(':')) value = value.substring(1).trim();
        map[key] = value;
      }
      return map;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Restoran'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (favoriteRestos.isEmpty) {
      return const Center(child: Text('Belum ada restoran favorit'));
    }
    
    return ListView.builder(
      itemCount: favoriteRestos.length,
      itemBuilder: (context, i) {
        final resto = favoriteRestos[i];
        return Card(
          color: const Color(0xFFF3EFFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: () {
              if (resto['pictureId'] != null) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    'https://restaurant-api.dicoding.dev/images/small/${resto['pictureId']}',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                );
              }
              return const Icon(Icons.favorite, color: Colors.red);
            }(),
            title: Text(
              resto['name'] ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: () {
              if (resto['city'] != null && resto['rating'] != null) {
                return Text(
                  '${resto['city']} • Rating: ${resto['rating']}',
                  style: const TextStyle(fontSize: 15),
                );
              }
              return null;
            }(),
            onTap: () {
              if (resto['id'] != null &&
                  resto['name'] != null &&
                  resto['pictureId'] != null &&
                  resto['city'] != null &&
                  resto['rating'] != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RestoranDetail(
                      restoran: Restoran(
                        id: resto['id'],
                        name: resto['name'],
                        description: '',
                        pictureId: resto['pictureId'],
                        city: resto['city'],
                        rating: double.tryParse(resto['rating'].toString()) ?? 0.0,
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}