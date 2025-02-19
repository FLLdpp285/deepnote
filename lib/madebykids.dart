import 'dart:ui';

import 'package:flutter/material.dart';

class MadeByKidsBadge extends StatelessWidget {
  const MadeByKidsBadge({super.key, this.width = 120});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Opacity(opacity: 0.5, child: Image.asset("images/made-by-kids.png", width: width, color: Colors.black)),
      ClipRect(
          child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Transform.translate(offset: const Offset(-3, -3), child: Image.asset("images/made-by-kids.png", width: width)),
      ))
    ]);
  }
}
