import 'package:api_http/example/model.dart';
import 'package:flutter/material.dart';

class SongSearchDelegate extends SearchDelegate<String> {
  final List<
      PlaylistModel>? playlistModels; // Danh sách các PlaylistModel để tìm kiếm
  final Function(PlaylistModel) onAddSong; // Hàm gọi lại để thêm bài hát vào danh sách phát
  List<PlaylistModel>? searchResults = []; // Kết quả tìm kiếm

  Set<String> addedSongs = Set(); // Set để theo dõi các bài hát đã được thêm
  bool isSnackBarDisplayed = false; // Cờ để theo dõi xem có hiển thị SnackBar không
  SongSearchDelegate(this.playlistModels, this.onAddSong); // Chấp nhận cả hai tham số

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          searchResults = [];
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Hiển thị kết quả tìm kiếm
    return ListView.builder(
      itemCount: searchResults!.length,
      itemBuilder: (BuildContext context, int index) {
        final song = searchResults![index];
        return _buildListItem(context, song);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Hiển thị gợi ý khi người dùng nhập trong thanh tìm kiếm
    searchResults = playlistModels!.where((song) {
      return song.songName!.toLowerCase().contains(query.toLowerCase()) &&
          !addedSongs.contains(song.id);
    }).toList();

    return ListView.builder(
      itemCount: searchResults!.length,
      itemBuilder: (BuildContext context, int index) {
        final song = searchResults![index];
        return _buildListItem(context, song);
      },
    );
  }



  Widget _buildListItem(BuildContext context, PlaylistModel song) {
    return ListTile(
      title: Text(song.songName!), // Tiêu đề của mục
      leading: CircleAvatar(
        backgroundImage: NetworkImage(song.thumbnailUrl!), // Hình đại diện
      ),
      trailing: IconButton(
        icon: Icon(Icons.add),
        onPressed: () async {
          // Kiểm tra xem bài hát đã được thêm vào danh sách chưa
          if (!addedSongs.contains(song.id)) {
            // Thực hiện việc thêm bài hát vào danh sách
            try {
              await onAddSong(
                  song); // Gọi phương thức addSongToFirebase thông qua onAddSong
              addedSongs.add(song.id!);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added song "${song.songName}" successfully.'),
                ),
              );
            } catch (error) {
              print('Đã xảy ra lỗi khi thêm bài hát: $error');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to add song "${song
                      .songName}". Please try again later.'),
                ),
              );
            }
          } else {
            // Hiển thị thông báo nếu bài hát đã tồn tại trong danh sách
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Song "${song.songName}" is already in the playlist.'),
              ),
            );
          }
        },
      ),
      onTap: () {
        // Xử lý khi người dùng chọn một gợi ý
      },
    );
  }
}
