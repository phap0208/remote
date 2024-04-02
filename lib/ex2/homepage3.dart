import 'dart:convert';
import 'package:api_http/ex2/playlist3.dart';
import 'package:dio/dio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';


class MyHomePage3 extends StatefulWidget {
  const MyHomePage3({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage3> {
  List<dynamic>? jsonList;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final TextEditingController _searchController = TextEditingController();
  Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://ikara-development.appspot.com',
    headers: {
      "authorization": 'Bearer ${""}',
      'content-Type': 'application/x-www-form-urlencoded',
    },
  ));

  Playlist playlist = Playlist(); // Define a playlist instance
  Set<dynamic> addedSongs = Set(); // Set to track added songs
  Set<dynamic> prioritizedSongs = Set(); // Set to track prioritized songs

  @override
  void initState() {
    super.initState();
    fetchAPI();
  }

  Future<void> fetchAPI() async {
    try {
      Map<String, dynamic> parameter = {
        "userId": "7B30D808-BE36-492B-A002-1F9BCB1755E6-893-0000005832A0B5F1",
        "platform": "IOS",
        "language": "vi",
        "properties": {
          "cursor":
          "ClMKEQoLdmlld0NvdW50ZXISAggEEjpqCXN-aWthcmE0bXItCxIQRGFpbHlWaWV3Q291bnRlciIXNDk4NiMxNjk1ODIzMjAwMDAwI3ZpIzIMGAAgAQ:::AAAAAQ=="
        },
      };

      String param64 =
          'eyJ1c2VySWQiOiIyQ0JERTZFRS00M0JBLTQ0NEItOUZENy1EREM3ODZBRDhGMzEtMzc1NTctMDAwMDEwMEREODlDNDU0MiIsInBsYXRmb3JtIjoiSU9TIiwibGFuZ3VhZ2UiOiJlbi55b2thcmEiLCJwYWNrYWdlTmFtZSI6ImNvbS5kZXYueW9rYXJhIiwicHJvcGVydGllcyI6eyJjdXJzb3IiOm51bGx9fQ==-915376685910417';
      Map<String, dynamic> params = {'parameters': param64};
      String path = 'https://ikara-development.appspot.com/v32.TopSongs';
      final Response response = await _dio.post(path, data: params);
      // log("datatataatat ${response.data}");
      final data = json.decode(response.data);
      if (response.statusCode == 200) {
        setState(() {
          jsonList = data['songs'] as List<dynamic>;
        });
        await uploadDataToFirebase(jsonList!);
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> uploadDataToFirebase(List<dynamic> data) async {
    try {
      await _database.child('yokaratv').set(data);
      print('Data uploaded successfully');
    } catch (e) {
      print('Error uploading data: $e');
    }
  }
  //     final data = json.decode(response.data);
  //     if (response.statusCode == 200) {
  //       setState(() {
  //         jsonList = data['songs'] as List<dynamic>; // Update key to 'songs'
  //       });
  //     } else {
  //       print(response.statusCode);
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Music'),
        actions: [
          // IconButton(
          //   icon: Icon(Icons.search),
          //   onPressed: () {
          //     SongSearchDelegate songSearchDelegate = SongSearchDelegate(jsonList!, (song) {
          //       if (!addedSongs.contains(song)) {
          //         setState(() {
          //           playlist.addSong(song);
          //           addedSongs.add(song);
          //         });
          //       }
          //     }, (song) {
          //       if (!prioritizedSongs.contains(song)) {
          //         setState(() {
          //           playlist.addSongToTop(song);
          //           prioritizedSongs.add(song);
          //         });
          //       }
          //     });
          //     showSearch(context: context, delegate: songSearchDelegate);
          //   },
          // ),
          // Navigate to PlaylistScreen when the playlist icon is tapped
          IconButton(
            icon: Icon(Icons.queue_music),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaylistScreen(
                    playlist: playlist,
                    // Define the onRemove callback function to remove a song from the playlist
                    onRemove: (song) {
                      setState(() {
                        playlist.removeSong(song);
                        addedSongs.remove(song);
                        prioritizedSongs.remove(song);
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.skip_previous),
                  onPressed: () {
                    // Xử lý khi người dùng nhấn vào nút chuyển bài trước đó
                  },
                ),
                IconButton(
                  icon: Icon(Icons.pause), // or Icon(Icons.play_arrow) based on the current playback state
                  onPressed: () {
                    // Xử lý khi người dùng nhấn vào nút pause/play
                  },
                ),
                IconButton(
                  icon: Icon(Icons.skip_next),
                  onPressed: () {
                    // Xử lý khi người dùng nhấn vào nút chuyển bài kế tiếp
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                final song = jsonList![index];
                return Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  song['thumbnailUrl'],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              song['songName'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: () {
                                        if (!addedSongs.contains(song) && !prioritizedSongs.contains(song)) {
                                          setState(() {
                                            playlist.addSong(song);
                                            addedSongs.add(song);
                                          });
                                        }
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Bài hát "${song['songName']}" đã được thêm thành công.'),
                                            duration: Duration(milliseconds: 500),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.arrow_upward),
                                      onPressed: () {
                                        if (!addedSongs.contains(song) && !prioritizedSongs.contains(song)) {
                                          setState(() {
                                            playlist.addSongToTop(song);
                                            prioritizedSongs.add(song);
                                          });
                                        }
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Bài hát "${song['songName']}" đã được thêm ưu tiên thành công.'),
                                            duration: Duration(milliseconds: 500),
                                          ),
                                        );
                                      },
                                    ),

                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              itemCount: jsonList == null ? 0 : jsonList!.length,
            ),
          ),
        ],
      ),
    );
  }
}


