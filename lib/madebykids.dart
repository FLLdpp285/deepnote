import 'package:flutter/material.dart';
import 'package:simple_shadow/simple_shadow.dart';

class MadeByKidsBadge extends StatelessWidget {
  const MadeByKidsBadge({super.key, this.width = 120});

  final double width;

  @override
  Widget build(BuildContext context) {
    return SimpleShadow(offset: const Offset(4, 4), child: Image.asset("images/made-by-kids.png", width: width));
  }
}
