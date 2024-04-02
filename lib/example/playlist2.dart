// import 'dart:convert';
// import 'dart:io';
// import 'package:api_http/example/model.dart';
// import 'package:dio/dio.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
//
//
// class Playlist {
//   List<PlaylistModel> songs = [];
//   final String? roomId;
//   Set<String> addedSongIds = Set();
//   Playlist({required this.roomId});
//   bool isPlaying = false; // Thêm biến trạng thái
//
//
//
//
//   Future<void> addSongToFirebase(PlaylistModel song) async {
//     try {
//       final dio = Dio();
//       print('IDPlaylist: ${roomId}');
//       final queryParams = {
//         'roomId': '$roomId',
//         'data' : song.toJson(), // Chuyển đổi đối tượng PlaylistModel thành JSON
//       };
//       final response = await dio.post(
//         'https://us-central1-ikara-development.cloudfunctions.net/ktv1_addSong-addSong',
//         options: Options(headers: {
//           HttpHeaders.contentTypeHeader: "application/json",
//         }),
//         data: jsonEncode(queryParams),
//       );
//       if (response.statusCode == 200) {
//         print('IDPlaylist: ${roomId}');
//         print('Bài hát đã được thêm thành công!');
//       } else {
//         print('Lỗi khi thêm bài hát: ${response.data}');
//       }
//     } catch (error) {
//       print('Đã xảy ra lỗi: $error');
//     }
//   }
//
//   Future<void> removeSong(PlaylistModel song, String? videoId) async {
//     try {
//       final dio = Dio();
//       print('IDPlaylist: ${roomId}');
//       final queryParams = {
//         'roomId': '$roomId',
//         'videoId': videoId??'', // Thêm videoId vào tham số yêu cầu
//       };
//       final response = await dio.post(
//         'https://us-central1-ikara-development.cloudfunctions.net/ktv1_removeSong-removeSong',
//         options: Options(headers: {
//           HttpHeaders.contentTypeHeader: "application/json",
//         }),
//         data: jsonEncode(queryParams),
//       );
//       if (response.statusCode == 200) {
//         print('Bài hát đã được xóa thành công!');
//       } else {
//         print('Lỗi khi xóa bài hát: ${response.data}');
//       }
//     } catch (error) {
//       print('Đã xảy ra lỗi: $error');
//     }
//   }
//   Future<void> pauseAndPlaySong(PlaylistModel song) async {
//     try {
//       final dio = Dio();
//       final queryParams = {
//         'roomId': '$roomId',
//       };
//       final response = await dio.post(
//         'https://us-central1-ikara-development.cloudfunctions.net/ktv1_pauseAndPlaySong-pauseAndPlaySong',
//         options: Options(headers: {
//           HttpHeaders.contentTypeHeader: "application/json",
//         }),
//         data: jsonEncode(queryParams),
//       );
//       if (response.statusCode == 200) {
//         // Đảo ngược trạng thái isPlaying
//         isPlaying = !isPlaying;
//         // In thông báo tùy thuộc vào trạng thái mới của isPlaying
//         print(isPlaying ? 'Bài hát đã được phát!' : 'Bài hát đã được tạm dừng!');
//       } else {
//         print('Lỗi : ${response.data}');
//       }
//     } catch (error) {
//       print('Đã xảy ra lỗi: $error');
//     }
//   }
// }
//
//
// class PlaylistScreen extends StatefulWidget {
//   final Playlist playlist;
//   final Function(PlaylistModel) onRemove;
//   final String? roomId;
//   PlaylistScreen({required this.playlist, required this.onRemove, required this.roomId});
//   @override
//   _PlaylistScreenState createState() => _PlaylistScreenState();
// }
//
// class _PlaylistScreenState extends State<PlaylistScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Playlist'),
//       ),
//       body: ListView.builder(
//         itemCount: widget.playlist.songs.length,
//         itemBuilder: (context, index) {
//           final PlaylistModel song = widget.playlist.songs[index];
//           return AnimatedCrossFade(
//             duration: Duration(milliseconds: 300),
//             firstChild: SizedBox.shrink(),
//             secondChild: ListTile(
//               key: ValueKey(song.id),
//               title: Text(song.songName ?? ''),
//               leading: CircleAvatar(
//                 backgroundImage: NetworkImage(song.thumbnailUrl ?? ''),
//               ),
//               trailing: IconButton(
//                 icon: Icon(Icons.remove_circle),
//                 onPressed: () async {
//                   setState(() {
//                     widget.onRemove(song);
//                     widget.playlist.removeSong(song, song.videoId);
//                     widget.playlist.songs.remove(song);
//                   });
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text(' Đã xóa bài hát '),
//                       duration: Duration(milliseconds: 300),
//                     ),
//                   );
//                 },
//
//               ),
//             ),
//             crossFadeState: CrossFadeState.showSecond,
//           );
//         },
//       ),
//     );
//   }
// }
