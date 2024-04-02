import 'package:api_http/example/homepage2.dart';
import 'package:dio/dio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

String? roomId;

class JoinRoomPage extends StatefulWidget {
  const JoinRoomPage({Key? key}) : super(key: key);

  @override
  _JoinRoomPageState createState() => _JoinRoomPageState();
}

class _JoinRoomPageState extends State<JoinRoomPage> {
  final TextEditingController _roomIdController = TextEditingController();
  final Dio _dio = Dio();
  static String? _userId;
  late DatabaseReference reference;

  // @override
  // void initState() {
  //   super.initState();
  //   // Đặt đường dẫn đến nút trong cơ sở dữ liệu Firebase
  //   String path = 'yokaratv/rooms/$roomId/songQueue';
  //   reference = FirebaseDatabase.instance.ref().child(path);
  //   // Đăng ký sự kiện lắng nghe khi child bị xóa
  //   reference.onChildRemoved.listen((event) {
  //     // Xử lý sự kiện khi child bị xóa
  //     print('Child removed: ${event.snapshot.key}');
  //     // Thực hiện các hành động phù hợp khi child bị xóa
  //   });
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NHẬP MÃ'),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logo/ykr.png',
                      width: 100,
                      height: 100,
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _roomIdController,
                      decoration: InputDecoration(labelText: 'Nhập mã phòng'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        roomId = _roomIdController.text;
                        print('JoinID: $roomId');
                        _joinRoom();
                      },
                      child: Text('Tham gia phòng'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _joinRoom() async {
    try {
      if (_userId == null) {
        _userId = Uuid().v4();
      }
      if (roomId == null || roomId!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vui lòng nhập mã phòng.'),
          ),
        );
        return;
      }
      String path = 'https://us-central1-ikara-development.cloudfunctions.net/ktv1_joinRoom-joinRoom';
      final Response response = await _dio.post(
        path,
        data: {
          'roomId': '$roomId',
          'userId': _userId,
        },
      );
      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage2(roomId: roomId)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: phòng không tồn tại'),
        ),
      );
    }
  }
}
