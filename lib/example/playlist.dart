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

  Future<void> prioritizeSong(PlaylistModel song, String? videoId) async {
    try {
      final dio = Dio();
      print('IDPlay1: ${roomId}');
      final queryParams = {
        'roomId': '$roomId',
        'videoId': videoId??'',
      };
      final response = await dio.post(
        "https://us-central1-ikara-development.cloudfunctions.net/ktv1_prioritizeSong-prioritizeSong",
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(queryParams),
      );
      if (response.statusCode == 200) {
        print('IDPlay2: ${roomId}');
        print('Bài hát đã được ưu tiên !');
      } else {
        print('Lỗi khi ưu tiên bài hát: ${response.data}');
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
  bool isThirdSongAdded = false;
  int currentlyPlayingIndex = 0;

  @override
  void initState() {
    super.initState();
    print(
        'Widget Room ID: ${widget.roomId}'); // In ra giá trị của widget.roomId
    // Lắng nghe sự thay đổi trên toàn bộ tham chiếu của songQueue
    FirebaseDatabase.instance
        .ref()
        .child('yokaratv/rooms/${widget.roomId}/songQueue')
        .onValue
        .listen((event) {
      // Xử lý dữ liệu snapshot để cập nhật danh sách phát
      final dataSnapshot = event.snapshot;
      print("hhhhb: ${dataSnapshot.value}");
      List<PlaylistModel> newqueueSongs = [];
      if (dataSnapshot.value != null) {
        (dataSnapshot.value as Map).forEach((key, value) {
          // Giả sử giá trị là dữ liệu của bài hát, bạn cần phân tích nó tương ứng
          final song = PlaylistModel.fromJson(value);
          newqueueSongs.add(song);
        });
      }
      for (var song in newqueueSongs) {
        print('Timestamp: ${song.timestamp}, VideoId: ${song.videoId}');
      }
      // Sắp xếp danh sách phát theo trường timestamp
      newqueueSongs.sort((a, b) =>
          (a.timestamp ?? 0).compareTo(b.timestamp ?? 0));
      print('After sorting:');
      for (var song in newqueueSongs) {
        print('Timestamp: ${song.timestamp}, VideoId: ${song.videoId}');
      }
      print(" hr: $newqueueSongs");
      print('Current Songs: $newqueueSongs');
      // Cập nhật danh sách phát với các bài hát hiện tại
      setState(() {
        widget.playlist.songs = newqueueSongs;
        // Kiểm tra xem đã thêm bài hát từ thứ ba trở đi chưa
        if (newqueueSongs.length >= 3) {
          isThirdSongAdded = true;
        }
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
          final bool isFirstSong = index ==
              0; // Kiểm tra xem đây có phải là bài hát đầu tiên không
          final bool isCurrentlyPlaying = isFirstSong && widget.playlist
              .isPlaying; // Kiểm tra xem bài hát hiện tại có đang phát không
          return ListTile(
            key: ValueKey(song.id),
            title: Text(
              song.songName ?? '',
              style: TextStyle(
                fontWeight: index == currentlyPlayingIndex ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            leading: Container(
              width: 60, // Điều chỉnh kích thước của thumbnailUrl
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(song.thumbnailUrl ?? ''),
                ),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (index > 0 &&
                    isThirdSongAdded) // Chỉ hiển thị nút khi thỏa mãn điều kiện
                  IconButton(
                    icon: Icon(Icons.arrow_upward),
                    onPressed: () async {
                      // Gọi hàm prioritizeSong khi nút được nhấn
                      await widget.playlist.prioritizeSong(song, song.videoId);
                      setState(() {
                        // Tìm vị trí của bài hát trong danh sách
                        int currentIndex = widget.playlist.songs.indexOf(song);
                        // Nếu bài hát không nằm ở đầu danh sách
                        if (currentIndex > 0) {
                          // Hoán đổi vị trí của bài hát với bài hát trước đó
                          PlaylistModel temp = widget.playlist
                              .songs[currentIndex - 1];
                          widget.playlist.songs[currentIndex - 1] = song;
                          widget.playlist.songs[currentIndex] = temp;
                        }
                      });
                    },
                  ),
                IconButton(
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
              ],
            ),
          );
        },
      ),
    );
  }
}



