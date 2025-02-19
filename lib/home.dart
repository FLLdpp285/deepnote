import 'package:deepnote/madebykids.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'battery.dart';
import 'dialogs.dart';
import 'note.dart';

String today() {
  DateTime dateTime = DateTime.now();
  DateFormat fmt = DateFormat("dd/MM/yy");
  return fmt.format(dateTime);
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
    return Stack(alignment: AlignmentDirectional.topEnd, children: [
      Scaffold(
        appBar: AppBar(
          leadingWidth: 200,
          leading: Padding(
            padding: const EdgeInsets.all(8.0).copyWith(left: 20),
            child: Image.asset("images/DeepNote.png"),
          ),
          centerTitle: true,
          title: Text("My Notes",
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
        ),
        backgroundColor: Colors.white,
        body: Center(
            child: GridView.count(
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                crossAxisCount: 3,
                padding: const EdgeInsets.all(20),
                children: (_isInfoLoaded
                        ? [SessionCard(name: today())]
                        : <SessionCard>[])
                    .followedBy(sessions)
                    .toList())),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showDialog(
              context: context,
              builder: (context) =>
                  ConnectDialog(onStateChange: onStateChange, onCharging: () {
                    setState(() {
                      _isInfoLoaded = true;
                    });
                    if (context.mounted) {
                      Navigator.pop(context);
                      openSession(context, today());
                    }
                  })),
          tooltip: 'New Note',
          child: const Icon(Icons.note_add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
      const MadeByKidsBadge(),
    ]);
  }
}

class SessionCard extends StatelessWidget {
  const SessionCard({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => openSession(context, name),
        child: Card(
            color: Theme.of(context).colorScheme.surface,
            child: Center(child: Text(name))));
  }
}

void openSession(BuildContext context, String name) {
  Navigator.push(context,
      MaterialPageRoute(builder: (context) => ViewNotePage(name: name)));
}
