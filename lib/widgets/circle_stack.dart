import 'package:flutter/material.dart';

class CircleStack extends StatelessWidget {
  final Color color;
  final IconData icondata;
  CircleStack(this.color, this.icondata);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          buildColoredBox(color),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
            ),
            child: Icon(
              icondata,
              color: color,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildColoredBox(Color color) {
    // Color类型作为参数
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
