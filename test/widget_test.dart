// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rando/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}


// SizedBox(
//                           child: Row(
//                             children: [
//                               SizedBox(
//                                 width: MediaQuery.of(context).size.width * 0.25,
//                                 height:
//                                     MediaQuery.of(context).size.height * 0.12,
//                                 child: Align(
//                                   alignment: const Alignment(-1, 0),
//                                   child: ClipOval(
//                                     child: Image.asset(
//                                       current_user.gender == 'Male'
//                                           ? userMateChatList[i]
//                                               .userMate
//                                               .femaleUser
//                                               .image
//                                           : userMateChatList[i]
//                                               .userMate
//                                               .maleUser
//                                               .image,
//                                       height: 70,
//                                       width: 70,
//                                       fit: BoxFit.cover,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );