import 'dart:convert';

import 'package:api_http/example/code.dart';
import 'package:api_http/example/model.dart';
import 'package:api_http/example/playlist.dart';
import 'package:api_http/example/playlist2.dart';

import 'package:api_http/example/song_search_delegate.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class MyHomePage2 extends StatefulWidget {
  final String? roomId;
  const MyHomePage2({Key? key, this.roomId}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage2> {
  late final Playlist playlist;
  List<PlaylistModel>? songs;
  bool isPlaying = false;

  Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://ikara-development.appspot.com',
    headers: {
      "authorization": 'Bearer ${""}',
      'content-Type': 'application/x-www-form-urlencoded',
    },
  ));
  Set<PlaylistModel> addedSongs = Set();

  @override
  void initState() {
    super.initState();
    playlist = Playlist(roomId: widget.roomId);
    // playlist.listenToSongRemoved(); // Sử dụng thể hiện playlist để gọi phương thức
    print('IDHome: ${widget.roomId}');
    fetchAPI();

  }

  Future<void> fetchAPI() async {
    try {
      Map<String, dynamic> parameter = {
        "userId": 123456789,
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
        List<dynamic> jsonList = data['songs'];
        setState(() {
          songs = jsonList.map((json) => PlaylistModel.fromJson(json)).toList();
        });
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Image.asset(
                'assets/logo/ykr.png',
                width: 40,
                height: 40,
              ),
            ),
            Text(
              "Phòng số : $roomId",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.05,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              await showSearch(
                context: context,
                delegate: SongSearchDelegate(songs, (_) async {
                  if (!playlist.songs.contains(_)) {
                    await playlist.addSongToFirebase(_);
                    playlist.addSongToFirebase(_);
                    setState(() {
                      songs!.add(_);
                      playlist.songs.add(_);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added song "${_
                            .songName}" successfully.'),
                      ),
                    );
                  }
                }),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.queue_music),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PlaylistScreen(
                        playlist: playlist,
                        onRemove: (song) {
                          setState(() {
                            playlist.removeSong(song, song.videoId);
                            addedSongs.remove(song);
                          });
                        },
                        roomId: widget.roomId, // Pass roomId to PlaylistScreen
                      ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () { // Call the logout function
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => JoinRoomPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(isPlaying ? Icons.play_arrow: Icons.pause),
                    onPressed: () async {
                      if (playlist.songs.isNotEmpty) {
                        final pauseAndPlaySong = playlist.songs.first;
                        await playlist.pauseAndPlaySong(pauseAndPlaySong);
                        setState(() {
                          isPlaying = !isPlaying;
                        });
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.skip_next),
                    onPressed: () async {
                      if (playlist.songs.isNotEmpty) {
                        final removedSong = playlist.songs.removeAt(0);
                        await playlist.removeSong(
                            removedSong, removedSong.videoId);
                        setState(() {});
                      }
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.whatshot,
                  color: Colors.red, // Màu của biểu tượng lửa
                  size: 24, // Kích thước của biểu tượng lửa
                ),
                Text(
                  'Top 10 Bài Hát Thịnh Hành',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 300, // Adjust the height as needed
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  final song = songs![index];
                  return Card(
                    child: SizedBox(
                      width: 200, // Adjust the width as needed
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 150, // Fixed height for the image
                            child: Image.network(
                              song.thumbnailUrl ?? '',
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  song.songName ?? '',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Spacer(), // Add Spacer to push IconButton to the right
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () async {
                              if (!playlist.songs.contains(song)) {
                                await playlist.addSongToFirebase(song);
                                setState(() {
                                  songs!.add(song);
                                  playlist.songs.add(song);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Bài hát đã thêm'),
                                    duration: Duration(milliseconds: 100),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
                itemCount: 10,
              ),
            ),
            SizedBox(height: 30),
            ExpansionTile(
              title: Text(
                'Danh sách bài hát',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4, // Adjust the height as needed
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      final song = songs?[index];
                      if (song == null) {
                        return SizedBox.shrink();
                      }
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(song.thumbnailUrl ?? ''),
                          ),
                          title: Text(song.songName ?? ''),
                          trailing: IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () async {
                              if (!playlist.songs.contains(song)) {
                                await playlist.addSongToFirebase(song);
                                setState(() {
                                  songs!.add(song);
                                  playlist.songs.add(song);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Bài hát đã thêm'),
                                    duration: Duration(milliseconds: 100),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      );
                    },
                    itemCount: songs?.length ?? 0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
