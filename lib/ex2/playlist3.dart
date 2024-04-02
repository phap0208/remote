import 'package:flutter/material.dart';

class Playlist {
  List<dynamic> songs = [];

  // Thêm một bài hát vào playlist
  void addSong(dynamic song) {
    songs.add(song);
  }

  // Thêm một bài hát vào đầu playlist
  void addSongToTop(dynamic song) {
    songs.insert(0, song);
  }

  // Xóa một bài hát khỏi playlist
  void removeSong(dynamic song) {
    songs.remove(song);
  }

  // Xóa tất cả các bài hát khỏi playlist
  void clearPlaylist() {
    songs.clear();
  }
}

class PlaylistScreen extends StatefulWidget {
  final Playlist playlist;
  final Function(dynamic) onRemove;

  PlaylistScreen({required this.playlist, required this.onRemove});

  @override
  _PlaylistScreenState createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Playlist'),
      ),
      body: ListView.builder(
        itemCount: widget.playlist.songs.length,
        itemBuilder: (context, index) {
          final song = widget.playlist.songs[index];

          return AnimatedCrossFade(
            duration: Duration(milliseconds: 300), // Thời gian hoạt động của hiệu ứng chuyển đổi
            firstChild: SizedBox.shrink(), // Widget rỗng
            secondChild: ListTile(
              key: ValueKey(song), // Đảm bảo mỗi bài hát có một key duy nhất
              title: Text(song['songName']),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(song['thumbnailUrl']),
              ),
              trailing: IconButton(
                icon: Icon(Icons.remove_circle),
                onPressed: () {
                  setState(() {
                    // Gọi hàm onRemove để xóa bài hát khỏi playlist
                    widget.onRemove(song);
                    // Xóa bài hát khỏi danh sách hiển thị
                    widget.playlist.songs.remove(song);
                  });

                  // Hiển thị snackbar thông báo đã xóa thành công trong 1 giây
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã xóa bài hát "${song['songName']}" thành công.'),
                      duration: Duration(milliseconds: 500),
                    ),
                  );
                },
              ),
            ),
            crossFadeState: CrossFadeState.showSecond, // Hiển thị widget thứ hai (ListTile)
          );
        },
      ),
    );
  }
}




