import 'dart:convert';
import 'dart:io';
import 'package:api_http/example/model.dart';
import 'package:dio/dio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';


class Playlist {
  List<PlaylistModel> songs = [];
  final String? roomId;
  Set<String> addedSongIds = Set();
  Playlist({required this.roomId});
  bool isPlaying = false;

  // late final DatabaseReference _reference;

  // void listenToSongRemoved() {
  //   print('RoomId trong listenToSongRemoved(): $roomId');
  //   _reference = FirebaseDatabase.instance.ref().child('yokaratv/rooms/$roomId/songQueue');
  //   _reference.onChildRemoved.listen((event) {
  //     String videoId = event.snapshot.key!;
  //     print('Bài hát với videoId $videoId đã bị xóa.');
  //     onChildRemoved(videoId);
  //   });
  // }


  Future<void> addSongToFirebase(PlaylistModel song) async {
    try {
      final dio = Dio();
      print('IDPlaylist: ${roomId}');
      final queryParams = {
        'roomId': '$roomId',
        'data' : song.toJson(), // Chuyển đổi đối tượng PlaylistModel thành JSON
      };
      final response = await dio.post(
        'https://us-central1-ikara-development.cloudfunctions.net/ktv1_addSong-addSong',
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(queryParams),
      );
      if (response.statusCode == 200) {
        print('IDPlaylist: ${roomId}');
        print('Bài hát đã được thêm thành công!');
      } else {
        print('Lỗi khi thêm bài hát: ${response.data}');
      }
    } catch (error) {
      print('Đã xảy ra lỗi: $error');
    }
  }


  // void onChildRemoved(String videoId) {
  //   // Xóa bài hát khỏi danh sách songs của Playlist
  //   PlaylistModel? removedSong = songs.firstWhere((song) => song.videoId == videoId, orElse: () =>  PlaylistModel(id: '', videoId: '', songName: '', thumbnailUrl: ''));
  //   if (removedSong != null) {
  //     print('Bài hát với tên $videoId đã được xóa khỏi danh sách.');
  //     songs.remove(removedSong);
  //     // Cập nhật giao diện nếu cần
  //   }
  // }



  Future<void> removeSong(PlaylistModel song, String? videoId) async {
    try {
      final dio = Dio();
      print('IDPlaylist: ${roomId}');
      final queryParams = {
        'roomId': '$roomId',
        'videoId': videoId??'', // Thêm videoId vào tham số yêu cầu
      };
      final response = await dio.post(
        'https://us-central1-ikara-development.cloudfunctions.net/ktv1_removeSong-removeSong',
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(queryParams),
      );
      if (response.statusCode == 200) {
        print('Bài hát đã được xóa thành công!');
      } else {
        print('Lỗi khi xóa bài hát: ${response.data}');
      }
    } catch (error) {
      print('Đã xảy ra lỗi: $error');
    }
  }

  Future<void> pauseAndPlaySong(PlaylistModel song) async {
    try {
      final dio = Dio();
      final queryParams = {
        'roomId': '$roomId',
      };
      final response = await dio.post(
        'https://us-central1-ikara-development.cloudfunctions.net/ktv1_pauseAndPlaySong-pauseAndPlaySong',
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(queryParams),
      );
      if (response.statusCode == 200) {
        // Đảo ngược trạng thái isPlaying
        isPlaying = !isPlaying;
        // In thông báo tùy thuộc vào trạng thái mới của isPlaying
        print(isPlaying ? 'Bài hát đã được phát!' : 'Bài hát đã được tạm dừng!');
      } else {
        print('Lỗi : ${response.data}');
      }
    } catch (error) {
      print('Đã xảy ra lỗi: $error');
    }
  }
}

class PlaylistScreen extends StatefulWidget {
  final Playlist playlist;
  final Function(PlaylistModel) onRemove;
  final String? roomId;
  PlaylistScreen({required this.playlist, required this.onRemove, required this.roomId});
  @override
  _PlaylistScreenState createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  @override
  void initState() {
    super.initState();
    // Lắng nghe sự thay đổi trên toàn bộ tham chiếu của songQueue
    FirebaseDatabase.instance
        .ref()
        .child('yokaratv/rooms/${widget.roomId}/songQueue')
        .onValue
        .listen((event) {
      // Xử lý dữ liệu snapshot để cập nhật danh sách phát
      final dataSnapshot = event.snapshot;
      List<PlaylistModel> queueSongs = [];
      if (dataSnapshot.value != null) {
        (dataSnapshot.value as Map).forEach((key, value) {
          // Giả sử giá trị là dữ liệu của bài hát, bạn cần phân tích nó tương ứng
          final song = PlaylistModel.fromJson(value);
          print(value);
          queueSongs.add(song);
        });
      }

      // In giá trị của currentSongs để kiểm tra
      print('Current Songs: $queueSongs');
      // Sắp xếp danh sách phát theo trường timestamp
      queueSongs.sort((a, b) => (b.timestamp ?? 0).compareTo(a.timestamp ?? 0));
      print('Current Songs: $queueSongs');
      // Cập nhật danh sách phát với các bài hát hiện tại
       setState(() {
        widget.playlist.songs = queueSongs;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Playlist'),
      ),
      body: ListView.builder(
        itemCount: widget.playlist.songs.length,
        itemBuilder: (context, index) {
          final PlaylistModel song = widget.playlist.songs[index];
          return ListTile(
            key: ValueKey(song.id),
            title: Text(song.songName ?? ''),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(song.thumbnailUrl ?? ''),
            ),
            trailing: IconButton(
              icon: Icon(Icons.remove_circle),
              onPressed: () async {
                setState(() {
                  widget.playlist.removeSong(song, song.videoId);
                  widget.playlist.songs.remove(song);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(' Đã xóa bài hát '),
                    duration: Duration(milliseconds: 300),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}


