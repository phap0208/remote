// import 'package:api_http/example/homepage2.dart';
// import 'package:api_http/example/hompage.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:uuid/uuid.dart';
//
// String? roomId; // Biến roomId được khai báo là một biến toàn cục
//
// class JoinRoomPage extends StatefulWidget {
//   const JoinRoomPage({Key? key}) : super(key: key);
//
//   @override
//   _JoinRoomPageState createState() => _JoinRoomPageState();
// }
//
// class _JoinRoomPageState extends State<JoinRoomPage> {
//   final TextEditingController _roomIdController = TextEditingController();
//   final Dio _dio = Dio();
//   static String? _userId; // Biến static để lưu trữ ID người dùng
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Join Room'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             TextFormField(
//               controller: _roomIdController,
//               decoration: InputDecoration(labelText: 'Nhập mã phòng'),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 roomId = _roomIdController.text; // Gán giá trị cho biến roomId toàn cục
//                 print('JoinID: $roomId'); // In giá trị của biến roomId
//                 _joinRoom();
//               },
//               child: Text('Tham gia phòng'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> _joinRoom() async {
//     try {
//       if (_userId == null) {
//         _userId = Uuid().v4();
//       }
//       if (roomId == null || roomId!.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Vui lòng nhập mã phòng.'),
//           ),
//         );
//         return;
//       }
//       String path = 'https://us-central1-ikara-development.cloudfunctions.net/ktv1_joinRoom-joinRoom';
//       final Response response = await _dio.post(
//         path,
//         data: {
//           'roomId': '$roomId',
//           'userId': _userId,
//         },
//       );
//       if (response.statusCode == 200) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => MyHomePage2(roomId: roomId)),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Lỗi: ${response.statusCode}'),
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Lỗi: phòng không tồn tại'),
//         ),
//       );
//     }
//   }
// }