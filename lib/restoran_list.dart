import 'package:flutter/material.dart';
import 'package:cobaflutter/restoran_model.dart';
import 'package:cobaflutter/base_network.dart';
import 'package:cobaflutter/restoran_detail.dart';
import 'package:cobaflutter/restoran_favorite.dart';

class RestoranList extends StatelessWidget {
  const RestoranList({super.key, required this.username});

  final String username;

  Future<List<Restoran>> _getAllRestoList() async {
    final rawList = await BaseNetwork.getAll("list");
    return rawList.map<Restoran>((e) => Restoran.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hai, $username'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RestoranFavorite(),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _getAllRestoList(),
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Error
          if (snapshot.hasError) {
            return Center(child: Text("Error kontol : ${snapshot.error}"));
          }
          // Data
          final restorans = snapshot.data!;
          return ListView.builder(
            itemCount: restorans.length,
            itemBuilder: (context, i) {
              final restoran = restorans[i];
              return Card(
                margin: const EdgeInsets.all(8.0),
                elevation: 4.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4.0)),
                      child: Image.network(
                        "https://restaurant-api.dicoding.dev/images/small/${restoran.pictureId}",
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restoran.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Row(
                          //   children: [
                          //     const Icon(Icons.star, color: Colors.amber, size: 20),
                          //     const SizedBox(width: 4),
                          //     Text(
                          //       restoran.rating.toString(),
                          //       style: const TextStyle(fontSize: 16),
                          //     ),
                          //   ],
                          // ),
                          // const SizedBox(height: 8),
                          // Text(
                          //   restoran.city,
                          //   style: const TextStyle(
                          //     fontSize: 14,
                          //     color: Colors.grey,
                          //   ),
                          // ),
                              IconButton(
                                icon: const Icon(Icons.arrow_forward, size: 32),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RestoranDetail(restoran: restoran),
                                    ),
                                  );
                                },
                              ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
