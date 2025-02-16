import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';
import 'battery.dart';

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
  bool _isInfoLoaded = false;

  @override
  Widget build(BuildContext context) {
    List<SessionCard> sessions =
        List.generate(5, (int index) => SessionCard(name: "Session #$index"));
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Image.asset("images/DeepNote.png", height: 40),
          Expanded(
              child: Center(
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
              crossAxisCount: 3,
              padding: const EdgeInsets.all(20),
              children: (_isInfoLoaded
                      ? [const SessionCard(name: "16/02/25")]
                      : <SessionCard>[])
                  .followedBy(sessions)
                  .toList())),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
            context: context,
            builder: (BuildContext ctx) => Dialog.fullscreen(
                child: StreamBuilder(
                    stream: onStateChange,
                    builder: (context, batteryState) {
                      if (batteryState.data == BatteryState.charging) {
                        Future.delayed(const Duration(milliseconds: 1500), () {
                          setState(() {
                            _isInfoLoaded = true;
                          });
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        });
                        return const Center(
                            child:
                                CircularProgressIndicator(color: Colors.black));
                      }
                      return Center(
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
                          ]));
                    }))),
        tooltip: 'New Note',
        child: const Icon(Icons.note_add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class SessionCard extends StatelessWidget {
  const SessionCard({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => ViewCardPage(name: name))),
        child: Card(
            color: Theme.of(context).colorScheme.surface,
            child: Center(child: Text(name))));
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
  final double temp;
  final double depth;
  final double salinity;
  final Widget thumbnail;
  final Image? img;
  final String summary = "A concise summary.";

  const Note(
      {super.key,
      required this.time,
      required this.thumbnail,
      this.temp = 27.3,
      this.depth = 5,
      this.salinity = 3.8,
      this.img});

  @override
  Widget build(BuildContext context) {
    if (img != null) {
      return img!;
    } else {
      return Placeholder(
          child: Center(
        child: Text("Note at $time"),
      ));
    }
  }
}

class _ViewCardPageState extends State<ViewCardPage> {
  int _selected = 0;
  List<Note> _notes = List.generate(10, (int index) {
    var rng = Random();
    return Note(
      time: "10:${19 + 3 * index}",
      thumbnail: Image.asset("images/D++285logo.png", width: 13),
      temp: 27 + rng.nextInt(20) * 0.1,
    );
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
                            ListTile(
                                title: const Text("Export as PDF"),
                                leading: const Icon(Icons.picture_as_pdf),
                                onTap: () => Navigator.pop(context)),
                            const Divider(),
                            ListTile(
                                title: const Text("Export as SVG"),
                                leading: const Icon(Icons.code),
                                onTap: () => Navigator.pop(context)),
                          ],
                        ),
                      ))),
          IconButton(icon: const Icon(Icons.attach_file), onPressed: () => {}),
        ],
        actionsPadding: const EdgeInsets.all(10),
      ),
      backgroundColor: Colors.white,
      body: Row(children: [
        Expanded(
            child: ListView.separated(
                itemCount: _notes.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  Note note = _notes[index];
                  TextStyle labelMedium =
                      Theme.of(context).textTheme.labelMedium!;

                  return Card(
                    color: _selected == index
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).cardColor,
                    child: ListTile(
                      onTap: () => setState(() {
                        _selected = index;
                      }),
                      leading: Image.asset("images/D++285logo.png", width: 30),
                      title: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(note.time,
                                style: Theme.of(context).textTheme.labelLarge),
                            const SizedBox(width: 8),
                            const Icon(Icons.thermostat),
                            Text(style: labelMedium, "${note.temp}\u00b0"),
                            const SizedBox(width: 8),
                            const Icon(Icons.water),
                            Text(style: labelMedium, "${note.depth}\u006d"),
                            const SizedBox(width: 8),
                            SvgPicture.asset("images/salinity.svg",
                                height: labelMedium.fontSize),
                            Text(
                                style: labelMedium,
                                "${note.salinity / 10}\u0070\u0070\u0074"),
                          ]),
                      subtitle: Row(spacing: 5, children: [
                        const Icon(Icons.auto_awesome, size: 15),
                        Text(note.summary)
                      ]),
                    ),
                  );
                },
                padding: const EdgeInsets.all(8.0))),
        const VerticalDivider(),
        Expanded(flex: 2, child: _notes[_selected])
      ]),
    );
  }
}
