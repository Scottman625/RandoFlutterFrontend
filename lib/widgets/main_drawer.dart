// import 'package:flutter/material.dart';
// import '../screens/phone_login.dart';

// class MainDrawer extends StatelessWidget {
//   Widget buildListTile(String title, IconData icon, VoidCallback tapHandler) {
//     return ListTile(
//       leading: Icon(
//         icon,
//         size: 26,
//       ),
//       title: Text(
//         title,
//         style: TextStyle(
//           fontFamily: 'RobotoCondensed',
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       onTap: tapHandler,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//         backgroundColor: Colors.blueAccent,
//         child: Column(
//           children: <Widget>[
//             Container(
//               height: 120,
//               width: double.infinity,
//               padding: EdgeInsets.all(20),
//               alignment: Alignment.centerLeft,
//               color: Colors.blueGrey,
//               child: Text(
//                 'RANDO',
//                 style: TextStyle(
//                     fontWeight: FontWeight.w900,
//                     fontSize: 30,
//                     color: Colors.amber),
//               ),
//             ),
//             SizedBox(
//               height: 20,
//             ),
//             buildListTile('登出', Icons.logout, () {
//               Navigator.of(context).pushReplacementNamed('/');
//             }),
//             buildListTile('手機登入畫面', Icons.login, () {
//               Navigator.of(context)
//                   .push(MaterialPageRoute(builder: (ctx) => PhoneLogIn()));
//             })
//           ],
//         ));
//   }
// }
