import 'package:flutter/material.dart';
import 'home.dart';

const colorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFFd8cc28),
  onPrimary: Color(0xFF131207),
  secondary: Color(0xFFf1ea81),
  onSecondary: Color(0xFF131207),
  tertiary: Color(0xFFffffff),
  onTertiary: Color(0xFF131207),
  surface: Color(0xFFfff000),
  onSurface: Color(0xFF131207),
  error: Brightness.light == Brightness.light
      ? Color(0xffB3261E)
      : Color(0xffF2B8B5),
  onError: Brightness.light == Brightness.light
      ? Color(0xffFFFFFF)
      : Color(0xff601410),
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeepNote',
      theme: ThemeData(
          colorScheme: colorScheme, useMaterial3: true, fontFamily: 'Circular'),
      home: const HomePage(),
    );
  }
}
