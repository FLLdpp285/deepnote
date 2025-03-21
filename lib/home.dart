import 'package:deepnote/madebykids.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'battery.dart';
import 'dialogs.dart';
import 'note.dart';
import 'notebookCard.dart';

String today() {
  DateTime dateTime = DateTime.now();
  DateFormat fmt = DateFormat("dd/MM/yy");
  return fmt.format(dateTime);
}

List<Note> notes = [
  Note(
      time: DateTime.now().subtract(const Duration(hours: 1)),
      img: Image.asset("images/notes/1.PNG"),
      depth: 2.85,
      temp: 28.5,
      summary: "Unknown Species",
      fullText: "Unknown Species Photo"),
  Note(
      time: DateTime.now().subtract(const Duration(hours: 1, minutes: 3)),
      img: Image.asset("images/notes/2.PNG"),
      depth: 2.85,
      temp: 28.5,
      summary: "Blue Goby Fish",
      fullText: "32 neon blue goby, good"),
  Note(
      time: DateTime.now().subtract(const Duration(hours: 1, minutes: 6)),
      img: Image.asset("images/notes/3.PNG"),
      depth: 2.85,
      temp: 28.5,
      summary: "Turtle Resting",
      fullText: "Turtle resting not moving"),
  Note(
      time: DateTime.now().subtract(const Duration(hours: 1, minutes: 9)),
      img: Image.asset("images/notes/4.PNG"),
      depth: 2.85,
      temp: 28.5,
      summary: "Fungi",
      fullText: "61 Fungiidae"),
  Note(
      time: DateTime.now().subtract(const Duration(hours: 1, minutes: 12)),
      img: Image.asset("images/notes/5.PNG"),
      depth: 2.85,
      temp: 28.5,
      summary: "Invasive Species",
      fullText: "Invasive Species"),
  Note(
      time: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
      img: Image.asset("images/notes/6.PNG"),
      depth: 2.85,
      temp: 28.5,
      summary: "Staghorn Coral",
      fullText: "43 Staghorn Coral"),
  Note(
      time: DateTime.now().subtract(const Duration(hours: 1, minutes: 18)),
      img: Image.asset("images/notes/7.PNG"),
      depth: 2.85,
      temp: 28.5,
      summary: "Bubble Coral",
    fullText: "7 Bubble Coral",
  ),
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Notebook> _notebooks = List.generate(
      5,
      (int index) =>
          Notebook.placeholder(DateTime.now(), name: "New Notebook"));

  int _page = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: AlignmentDirectional.topEnd, children: [
      Scaffold(
        appBar: AppBar(
          leadingWidth: 200,
          leading: Padding(
            padding: const EdgeInsets.all(8.0).copyWith(left: 20),
            child: Image.asset("images/DeepNote.png"),
          ),
          centerTitle: true,
          title: Text("My Notebooks",
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
        ),
        backgroundColor: Colors.white,
        body: Row(
          children: [
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    spacing: 8,
                    children: [
                      NavigationListTile(
                        leading: const Icon(Icons.event_note),
                        title: "My Notebooks",
                        onTap: () => setState(() {
                          _page = 0;
                        }),
                        selected: _page == 0,
                      ),
                      NavigationListTile(
                        leading: const Icon(Icons.settings),
                        title: "App Settings",
                        onTap: () => setState(() {
                          _page = 1;
                        }),
                        selected: _page == 1,
                      ),
                      const Expanded(child: SizedBox()),
                      NavigationListTile(
                          leading: const Icon(Icons.account_circle),
                          title: "My Account",
                          onTap: () => setState(() {
                                _page = 2;
                              }),
                          selected: _page == 2,
                          tileColor: Colors.grey.shade300),
                    ]),
              ),
            ),
            const VerticalDivider(),
            Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    spacing: 10,
                    children: [
                      const SearchBar(
                        leading: Icon(Icons.search),
                        hintText: "Search all notebooks...",
                      ),
                      Expanded(
                        child: GridView.count(
                          crossAxisSpacing: 30,
                          mainAxisSpacing: 30,
                          crossAxisCount: 3,
                          padding: const EdgeInsets.all(20),
                          children: _notebooks
                              .map((nb) => NotebookCard(notebook: nb))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
        floatingActionButton: FloatingActionButton.large(
          onPressed: () => showDialog(
              context: context,
              builder: (context) => ConnectDialog(
                  onStateChange: onStateChange,
                  onCharging: () {
                    setState(() {
                      _notebooks.add(Notebook(
                          created: DateTime.now(),
                          name: "25/03/2025",
                          notes: notes));
                    });
                    if (context.mounted) {
                      Navigator.pop(context);
                      openNotebook(context, _notebooks.last);
                    }
                  })),
          tooltip: 'New Note',
          backgroundColor: Theme.of(context).cardColor,
          child: const Icon(Icons.note_add),
        ),
      ),
      const MadeByKidsBadge(),
    ]);
  }
}

class NavigationListTile extends StatelessWidget {
  const NavigationListTile({
    super.key,
    required this.title,
    required this.leading,
    this.onTap,
    this.selected = false,
    this.tileColor,
  });

  final String title;
  final Widget leading;

  final Function()? onTap;

  final bool selected;

  final Color? tileColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: leading,
        title: Text(title),
        onTap: onTap,
        selected: selected,
        selectedTileColor: Theme.of(context).cardColor,
        selectedColor: Theme.of(context).colorScheme.onSurface,
        tileColor: tileColor,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12))));
  }
}

void openNotebook(BuildContext context, Notebook nb) {
  Navigator.push(context,
      MaterialPageRoute(builder: (context) => ViewNotePage(notebook: nb)));
}
