import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

Future<List<Photo>> fetchPhotos(http.Client client) async {
  final response = await client.get('https://scrapbox.io/api/pages/MECHKEYS');

  return compute(parsePhotos, response.body);
}

List<Photo> parsePhotos(String responseBody) {
  final parsed =
      json.decode(responseBody)['pages'].cast<Map<String, dynamic>>();

  return parsed.map<Photo>((json) => Photo.fromJson(json)).toList();
}

class Photo {
  final String id;
  final String title;
  final String imgUrl;

  Photo({this.id, this.title, this.imgUrl});

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'] as String,
      title: json['title'] as String,
      imgUrl: json['image'] as String,
    );
  }
}

void main() => runApp(Keyphotter());

class Keyphotter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Keyphotter';

    return MaterialApp(
      title: appTitle,
      home: KeyphotterPage(title: appTitle),
    );
  }
}

class KeyphotterPage extends StatelessWidget {
  final String title;

  KeyphotterPage({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: FutureBuilder<List<Photo>>(
        future: fetchPhotos(http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? PhotosList(photos: snapshot.data)
              : Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class PhotosList extends StatelessWidget {
  final List<Photo> photos;

  PhotosList({Key key, this.photos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        crossAxisCount: 2,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        return GridTile(
          footer: GridTileBar(
            backgroundColor: Colors.black45,
            title: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(photos[index].title),
            ),
          ),
          child: CachedNetworkImage(
            imageUrl: photos[index].imgUrl,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}
