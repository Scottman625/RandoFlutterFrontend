import 'models/user.dart';
import 'models/userMate.dart';
import 'models/chatMessage.dart';
import 'dart:math';

List<User> profiles = [
  User(
      id: '001', name: 'Amy', image: 'assets/images/Amy.png', gender: 'Female'),
  User(id: '002', name: 'IU', image: 'assets/images/IU.png', gender: 'Female'),
  User(id: '003', name: 'CU', image: 'assets/images/CU.png', gender: 'Female'),
  User(id: '004', name: 'YU', image: 'assets/images/YU.png', gender: 'Female'),
  User(
      id: '005',
      name: 'Alice',
      image: 'assets/images/Alice.png',
      gender: 'Female'),
  User(
      id: '006',
      name: 'Jane',
      image: 'assets/images/Jane.png',
      gender: 'Female'),
  User(
      id: '007',
      name: 'Scott',
      image: 'assets/images/Scott.png',
      gender: 'Male'),
  // Add more Users here.
];

List<UserMate> userMates = [
  UserMate(
      id: '01',
      maleUser: profiles.firstWhere((user) => user.id == '007'),
      femaleUser: profiles.firstWhere((user) => user.id == '001')),
  UserMate(
      id: '02',
      maleUser: profiles.firstWhere((user) => user.id == '007'),
      femaleUser: profiles.firstWhere((user) => user.id == '002')),
  UserMate(
      id: '03',
      maleUser: profiles.firstWhere((user) => user.id == '007'),
      femaleUser: profiles.firstWhere((user) => user.id == '003')),
  UserMate(
      id: '04',
      maleUser: profiles.firstWhere((user) => user.id == '007'),
      femaleUser: profiles.firstWhere((user) => user.id == '004')),
  UserMate(
      id: '05',
      maleUser: profiles.firstWhere((user) => user.id == '007'),
      femaleUser: profiles.firstWhere((user) => user.id == '005')),
  UserMate(
      id: '06',
      maleUser: profiles.firstWhere((user) => user.id == '007'),
      femaleUser: profiles.firstWhere((user) => user.id == '006')),
];
final random = Random();

List<ChatMessage> messages = [
  ChatMessage(
    userMate: userMates.firstWhere((mate) => mate.id == '01'),
    sender: profiles.firstWhere((user) => user.id == '001'),
    message: 'Hi',
    timestamp: DateTime.fromMillisecondsSinceEpoch(1688337740150),
  ),
  ChatMessage(
    userMate: userMates.firstWhere((mate) => mate.id == '02'),
    sender: profiles.firstWhere((user) => user.id == '002'),
    message: 'Hello',
    timestamp: DateTime.fromMillisecondsSinceEpoch(1688334540150),
  ),
  ChatMessage(
    userMate: userMates.firstWhere((mate) => mate.id == '03'),
    sender: profiles.firstWhere((user) => user.id == '003'),
    message: '你是臺南人嗎？',
    timestamp: DateTime.fromMillisecondsSinceEpoch(1688467740150),
  ),
  ChatMessage(
    userMate: userMates.firstWhere((mate) => mate.id == '04'),
    sender: profiles.firstWhere((user) => user.id == '004'),
    message: '哈囉!',
    timestamp: DateTime.fromMillisecondsSinceEpoch(1688337798150),
  ),
  ChatMessage(
    userMate: userMates.firstWhere((mate) => mate.id == '05'),
    sender: profiles.firstWhere((user) => user.id == '005'),
    message: '狗狗好可愛喔！',
    timestamp: DateTime.fromMillisecondsSinceEpoch(1688330840150),
  ),
  ChatMessage(
    userMate: userMates.firstWhere((mate) => mate.id == '06'),
    sender: profiles.firstWhere((user) => user.id == '006'),
    message: '早喔',
    timestamp: DateTime.fromMillisecondsSinceEpoch(1684537740150),
  ),
  ChatMessage(
    userMate: userMates.firstWhere((mate) => mate.id == '06'),
    sender: profiles.firstWhere((user) => user.id == '006'),
    message: '早安阿！',
    timestamp: DateTime.fromMillisecondsSinceEpoch(1238337740150),
  )
];
