import 'package:flutter/material.dart';
import '../models/user.dart';
import '../widgets/circle_stack.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileCard extends StatefulWidget {
  final User user;
  final CardSwiperController controller;

  ProfileCard(this.user, this.controller);

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard>
    with SingleTickerProviderStateMixin {
  bool isMatched = false;

  @override
  Widget build(BuildContext context) {
    var profile_name = widget.user.name;
    return Card(
      child: Stack(children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.877,
          height: MediaQuery.of(context).size.height * 0.75,
          child: CachedNetworkImage(
            imageUrl: widget.user.image,
            width: MediaQuery.of(context).size.width * 0.877,
            height: MediaQuery.of(context).size.height * 0.75,
            fit: BoxFit.cover,
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.86,
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment(0, 0.35),
                end: Alignment(0, 0.65),
                colors: [
                  Colors.transparent,
                  Color.fromARGB(230, 53, 53, 53),
                ]),
          ),
        ),
        Column(
          children: <Widget>[
            SizedBox(height: 420),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color.fromARGB(255, 93, 185, 228),
                    ),
                    width: 120,
                    height: 30,
                    child: const Center(
                      child: Text(
                        '3天前',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 40.0, top: 8, bottom: 12),
                  child: Container(
                    width: 120,
                    height: 30,
                    child: Text(
                      widget.user.name,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 25.0, bottom: 10),
                  child: Container(
                    width: 120,
                    height: 30,
                    child: Row(
                      children: [
                        Icon(
                          Icons.place,
                          color: Colors.white,
                        ),
                        Text(
                          ' 距離七公里',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: 45,
                  height: 45,
                  child: FloatingActionButton(
                    heroTag: 'undo$profile_name',
                    onPressed: widget.controller.undo,
                    backgroundColor: Colors.yellow,
                    child: CircleStack(Colors.yellow, Icons.undo),
                  ),
                ),
                Container(
                  width: 45,
                  height: 45,
                  child: FloatingActionButton(
                    heroTag: 'swipeLeft$profile_name',
                    onPressed: widget.controller.swipeLeft,
                    backgroundColor: Colors.red,
                    child: CircleStack(Colors.red, Icons.clear),
                  ),
                ),
                Container(
                  width: 45,
                  height: 45,
                  child: FloatingActionButton(
                    heroTag: 'swipeTop$profile_name',
                    onPressed: widget.controller.swipeTop,
                    backgroundColor: Color.fromARGB(255, 64, 249, 255),
                    child: CircleStack(
                        Color.fromARGB(255, 64, 249, 255), Icons.star_rate),
                  ),
                ),
                Container(
                  width: 45,
                  height: 45,
                  child: FloatingActionButton(
                    heroTag: 'swipeRight$profile_name',
                    onPressed: () {
                      widget.controller.swipeRight();

                      // WidgetsBinding.instance.addPostFrameCallback((_) {
                      //   if (widget.controller.isMatched) {
                      //     Navigator.of(context).push(MaterialPageRoute(
                      //         builder: (ctx) => MatchScreen(
                      //               userId: widget.user.id.toString(),
                      //             )));
                      //   }
                      // });
                    },
                    backgroundColor: Colors.greenAccent,
                    child: CircleStack(Colors.greenAccent, Icons.favorite),
                  ),
                ),
                Container(
                  width: 45,
                  height: 45,
                  child: FloatingActionButton(
                    heroTag: 'swipeBottom$profile_name',
                    onPressed: widget.controller.swipeBottom,
                    backgroundColor: Colors.purpleAccent,
                    child:
                        CircleStack(Colors.purpleAccent, Icons.electric_bolt),
                  ),
                ),
              ],
            ),
          ],
        ),
      ]),
    );
  }
}
