import 'package:flutter/material.dart';

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
        title: Center(
            child: Text("My Notes",
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700))),
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
                                  ViewCardPage(name: "Note #$index"))),
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

class _ViewCardPageState extends State<ViewCardPage> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(widget.name),
        actions: [
          IconButton(
              icon: const Icon(Icons.upload_file),
              onPressed: () => showModalBottomSheet(
                  context: context,
                  builder: (context) => Padding(
                    padding: const EdgeInsets.all(8.0).copyWith(bottom: 20),
                    child: const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                    ListTile(title: Text("Export as PDF"), leading: Icon(Icons.picture_as_pdf)),
                    Divider(),
                    ListTile(title: Text("Export as SVG"), leading: Icon(Icons.code)),
                                        ],
                                      ),
                  ))),
          IconButton(icon: const Icon(Icons.camera), onPressed: () => {})
        ],
        actionsPadding: const EdgeInsets.all(10),
      ),
      backgroundColor: Colors.white,
      body: Row(children: [
        LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: NavigationRail(
                  selectedIndex: _selected,
                  onDestinationSelected: (int dest) {
                    setState(() {
                      _selected = dest;
                    });
                  },
                  selectedLabelTextStyle: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                  destinations: List.generate(
                      10,
                      (int index) => NavigationRailDestination(
                          icon: const Icon(Icons.note_alt_outlined),
                          selectedIcon: const Icon(Icons.note_alt),
                          label: Text("10:${19 + index * 3}"))),
                  labelType: NavigationRailLabelType.all,
                ),
              ),
            ),
          ),
        ),
        const Expanded(
            child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Placeholder(),
        ))
      ]),
    );
  }
}
