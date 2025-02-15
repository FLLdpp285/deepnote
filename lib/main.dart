import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';

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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Image.asset("images/DeepNote.png", height: 40),
          Expanded(child: Center(
            child: Text("My Notes",
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700))))
          ]),
      ),
      backgroundColor: Colors.white,
      body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: GridView.count(
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 2,
              padding: const EdgeInsets.all(20),
              children: List.generate(
                  100,
                  (int index) => GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ViewCardPage(name: "Session #$index"))),
                      child: Card(
                          color: Theme.of(context).colorScheme.surface,
                          child: Center(child: Text("$index"))))))),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
            context: context,
            builder: (BuildContext ctx) => Dialog.fullscreen(
                    child: Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                      Text("Waiting for connection...",
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 20),
                      const Icon(Icons.usb, size: 70)
                    ])))),
        tooltip: 'New Note',
        child: const Icon(Icons.note_add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class ViewCardPage extends StatefulWidget {
  const ViewCardPage({super.key, required this.name});

  final String name;

  @override
  State<ViewCardPage> createState() => _ViewCardPageState();
}

class Note extends StatelessWidget {
  final String time;
  double temp = 27.3;
  double depth = 5;
  double salinity = 3.8;
  final Widget thumbnail;
  final String summary = "A concise summary.";

  Note({required this.time, required this.thumbnail, this.temp = 27.3, this.depth = 5, this.salinity = 3.8});

  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}

final String dpp_logo_url = "https://static.wixstatic.com/media/148775_8f1484c02eed186d1beaeeafef89f82b.png/v1/fill/w_69,h_76,al_c,q_85,usm_0.66_1.00_0.01,enc_avif,quality_auto/148775_8f1484c02eed186d1beaeeafef89f82b.png";

class _ViewCardPageState extends State<ViewCardPage> {
  int _selected = 0;
  List<Note> _notes = List.generate(10, (int index) {
    var rng = Random();
    return Note(time: "10:${19 + 3*index}", thumbnail: Image.network(dpp_logo_url, width: 13), temp: 27 + rng.nextInt(20) * 0.1);
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text("${widget.name} - Note at ${_notes[_selected].time}"),
        actions: [
          IconButton(
              icon: const Icon(Icons.upload_file),
              onPressed: () => showModalBottomSheet(
                  context: context,
                  builder: (context) => Padding(
                    padding: const EdgeInsets.all(8.0).copyWith(bottom: 20),
                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                    ListTile(title: Text("Export as PDF"), leading: Icon(Icons.picture_as_pdf), onTap: () => Navigator.pop(context)),
                    Divider(),
                    ListTile(title: Text("Export as SVG"), leading: Icon(Icons.code), onTap: () => Navigator.pop(context)),
                                        ],
                                      ),
                  ))),
          IconButton(icon: const Icon(Icons.attach_file), onPressed: () => {}),
        ],
        actionsPadding: const EdgeInsets.all(10),
      ),
      backgroundColor: Colors.white,
      body: Row(children: [
        SizedBox(width: 330, child: ListView.separated(
          itemCount: _notes.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            Note note = _notes[index];

            return ListTile(
            leading: Image.network(dpp_logo_url, width: 30),
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(note.time, style: Theme.of(context).textTheme?.labelLarge),
                SizedBox(width: 8),
                Icon(Icons.thermostat),
                Text(style: Theme.of(context).textTheme?.labelMedium, "${note.temp}\u00b0"),
                SizedBox(width: 8),
                Icon(Icons.water),
                Text(style: Theme.of(context).textTheme?.labelMedium, "${note.depth}\u006d"),
                SizedBox(width: 8),
                SvgPicture.asset("images/salinity.svg", height: Theme.of(context).textTheme?.labelMedium?.fontSize),
                Text(style: Theme.of(context).textTheme?.labelMedium, "${note.salinity / 10}\u0070\u0070\u0074"),
              ]),
            subtitle: Row(spacing: 5, children: [Icon(Icons.auto_awesome, size: 15), Text(note.summary)]),
          ); },
          padding: const EdgeInsets.all(8.0)
        )),
        const VerticalDivider(),
        const Expanded(
            child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Placeholder(),
        ))
      ]),
    );
  }
}
