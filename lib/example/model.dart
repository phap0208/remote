class PlaylistModel {
  PlaylistModel({
    this.dateTime,
    this.id,
    this.songName,
    this.songUrl,
    this.videoId,
    this.thumbnailUrl,
    this.viewCounter,
  });

  PlaylistModel.fromJson(dynamic json) {
    dateTime = json['dateTime'];
    id = json['id'];
    songName = json['songName'];
    songUrl = json['songUrl'];
    videoId = json['videoId'];
    thumbnailUrl = json['thumbnailUrl'];
    viewCounter = json['viewCounter'];
  }

  String? dateTime;
  String? id;
  String? songName;
  String? songUrl;
  String? videoId;
  String? thumbnailUrl;
  int? viewCounter;

  PlaylistModel copyWith({
    String? dateTime,
    String? id,
    String? songName,
    String? songUrl,
    String? videoId,
    String? thumbnailUrl,
    int? viewCounter,
  }) =>
      PlaylistModel(
        dateTime: dateTime ?? this.dateTime,
        id: id ?? this.id,
        videoId: videoId ?? this.videoId,
        songName: songName ?? this.songName,
        songUrl: songUrl ?? this.songUrl,
        thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
        viewCounter: viewCounter ?? this.viewCounter,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['dateTime'] = dateTime;
    map['_id'] = id;
    map['songName'] = songName;
    map['songUrl'] = songUrl;
    map['videoId'] = videoId;
    map['thumbnailUrl'] = thumbnailUrl;
    map['viewCounter'] = viewCounter;
    return map;
  }
}
