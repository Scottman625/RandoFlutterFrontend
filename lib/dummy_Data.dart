import 'models/user.dart';
import 'models/userMate.dart';
import 'models/chatMessage.dart';
import 'dart:math';

List<User> profiles = [
  User(
    name: 'Amy',
    image: 'assets/images/Amy.png',
    gender: 'Female',
    phone: '0000000000',
    age: 22,
    career: '護理師',
  ),
  User(
    name: 'IU',
    image: 'assets/images/IU.png',
    gender: 'Female',
    phone: '0000000001',
    age: 22,
    career: '護理師',
  ),
  User(
    name: 'CU',
    image: 'assets/images/CU.png',
    gender: 'Female',
    phone: '0000000001',
    age: 22,
    career: '護理師',
  ),
  User(
    name: 'YU',
    image: 'assets/images/YU.png',
    gender: 'Female',
    phone: '0000000001',
    age: 22,
    career: '護理師',
  ),
  User(
    name: 'Alice',
    image: 'assets/images/Alice.png',
    gender: 'Female',
    phone: '0000000001',
    age: 22,
    career: '護理師',
  ),
  User(
    name: 'Jane',
    image: 'assets/images/Jane.png',
    gender: 'Female',
    phone: '0000000001',
    age: 22,
    career: '護理師',
  ),
  User(
    name: 'Scott',
    image: 'assets/images/Scott.png',
    gender: 'Male',
    phone: '0000000001',
    age: 22,
    career: '護理師',
  ),
  // Add more Users here.
];

List<UserMate> userMates = [
  UserMate(
      id: '01',
      maleUser: profiles.firstWhere((user) => user.name == 'Scott'),
      femaleUser: profiles.firstWhere((user) => user.name == 'Amy')),
  UserMate(
      id: '02',
      maleUser: profiles.firstWhere((user) => user.name == 'Scott'),
      femaleUser: profiles.firstWhere((user) => user.name == 'IU')),
  UserMate(
      id: '03',
      maleUser: profiles.firstWhere((user) => user.name == 'Scott'),
      femaleUser: profiles.firstWhere((user) => user.name == 'CU')),
  UserMate(
      id: '04',
      maleUser: profiles.firstWhere((user) => user.name == 'Scott'),
      femaleUser: profiles.firstWhere((user) => user.name == 'YU')),
  UserMate(
      id: '05',
      maleUser: profiles.firstWhere((user) => user.name == 'Scott'),
      femaleUser: profiles.firstWhere((user) => user.name == 'Alice')),
  UserMate(
      id: '06',
      maleUser: profiles.firstWhere((user) => user.name == 'Scott'),
      femaleUser: profiles.firstWhere((user) => user.name == 'Jane')),
];
final random = Random();

// List<ChatMessage> messages = [
//   ChatMessage(
//     other_side_image_url: userMates.firstWhere((mate) => mate.id == '01'),
//     sender: profiles.firstWhere((user) => user.name == 'Amy'),
//     message: 'Hi',
//     timestamp: DateTime.fromMillisecondsSinceEpoch(1688337740150),
//   ),
//   ChatMessage(
//     other_side_image_url: userMates.firstWhere((mate) => mate.id == '02'),
//     sender: profiles.firstWhere((user) => user.name == 'IU'),
//     message: 'Hello',
//     timestamp: DateTime.fromMillisecondsSinceEpoch(1688334540150),
//   ),
//   ChatMessage(
//     other_side_image_url: userMates.firstWhere((mate) => mate.id == '03'),
//     sender: profiles.firstWhere((user) => user.name == 'CU'),
//     message: '你是臺南人嗎？',
//     timestamp: DateTime.fromMillisecondsSinceEpoch(1688467740150),
//   ),
//   ChatMessage(
//     other_side_image_url: userMates.firstWhere((mate) => mate.id == '04'),
//     sender: profiles.firstWhere((user) => user.name == 'YU'),
//     message: '哈囉!',
//     timestamp: DateTime.fromMillisecondsSinceEpoch(1688337798150),
//   ),
//   ChatMessage(
//     other_side_image_url: userMates.firstWhere((mate) => mate.id == '05'),
//     sender: profiles.firstWhere((user) => user.name == 'Alice'),
//     message: '狗狗好可愛喔！',
//     timestamp: DateTime.fromMillisecondsSinceEpoch(1688330840150),
//   ),
//   ChatMessage(
//     other_side_image_url: userMates.firstWhere((mate) => mate.id == '06'),
//     sender: profiles.firstWhere((user) => user.name == 'Jane'),
//     message: '早喔',
//     timestamp: DateTime.fromMillisecondsSinceEpoch(1684537740150),
//   ),
//   ChatMessage(
//     other_side_image_url: userMates.firstWhere((mate) => mate.id == '06'),
//     sender: profiles.firstWhere((user) => user.name == 'Jane'),
//     message: '早安阿！',
//     timestamp: DateTime.fromMillisecondsSinceEpoch(1238337740150),
//   )
// ];