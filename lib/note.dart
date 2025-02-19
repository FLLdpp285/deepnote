import 'dart:io';

import 'package:deepnote/dialogs.dart';
import 'package:exif/exif.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class Note extends StatelessWidget {
  final DateTime time;
  final double temp;
  final double depth;
  final double salinity;
  final Widget thumbnail;
  final Image? img;
  final String summary = "A concise summary.";
  final bool isExternal;

  const Note({
    super.key,
    required this.time,
    required this.thumbnail,
    this.temp = 27.3,
    this.depth = 5,
    this.salinity = 3.8,
    this.img,
    this.isExternal = false,
  });

  String daytime() {
    return DateFormat("HH:mm").format(time);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
      InteractiveViewer(
        maxScale: 10,
        child: img == null
            ? Placeholder(
            child: Center(
              child: Text("Note at ${daytime()}"),
            ))
            : img!,
      ),
      Align(
        alignment: AlignmentDirectional.topStart,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SegmentedButton(
              style: ButtonStyle(
                  backgroundColor:
                  WidgetStateProperty.all(Colors.white.withAlpha(128))),
              emptySelectionAllowed: true,
              multiSelectionEnabled: true,
              selected: const {},
              onSelectionChanged: (sel) => {},
              segments: [
                ButtonSegment(
                  value: "Time",
                  icon: const Icon(Icons.access_time, color: Colors.black),
                  label: Text(daytime()),
                ),
                ButtonSegment(
                  value: "Temp",
                  icon: const Icon(Icons.thermostat, color: Colors.black),
                  label: Text("$temp"),
                ),
                ButtonSegment(
                    value: "Depth",
                    icon: const Icon(Icons.water, color: Colors.black),
                    label: Text("$depth")),
                ButtonSegment(
                    value: "Salinity",
                    icon: SvgPicture.asset("images/salinity.svg",
                        height: IconTheme
                            .of(context)
                            .size),
                    label: Text("$salinity")),
              ]),
        ),
      )
    ]);
  }
}

class SidebarCard extends StatelessWidget {
  const SidebarCard(
      {super.key, required this.note, required this.isSelected, this.onTap, this.onLongPress});

  final Note note;
  final bool isSelected;

  final Function()? onTap;
  final Function()? onLongPress;

  @override
  Widget build(BuildContext context) {
    TextStyle labelMedium = Theme
        .of(context)
        .textTheme
        .labelMedium!;

    Color color = isSelected ? Theme
        .of(context)
        .primaryColor : Theme
        .of(context)
        .cardColor;
    InkWell child = InkWell(
      borderRadius: BorderRadius.circular(12.0),
      onTap: onTap,
      onLongPress: onLongPress,
      child: ListTile(
        leading: note.thumbnail,
        title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(note.daytime(),
                  style: Theme
                      .of(context)
                      .textTheme
                      .labelLarge),
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
                  "${note.salinity}\u0025"),
            ]),
        subtitle: Row(spacing: 5, children: [
          const Icon(Icons.auto_awesome, size: 15),
          Text(note.summary)
        ]),
      ),
    );

    return note.isExternal ? Card.outlined(color: color, child: child) : Card(color: color, child: child);
  }
}

class ViewNotePage extends StatefulWidget {
  const ViewNotePage({super.key, required this.name});

  final String name;

  @override
  State<ViewNotePage> createState() => _ViewNotePageState();
}

class _ViewNotePageState extends State<ViewNotePage> {
  int _selected = 0;
  List<Note> _notes = List.generate(10, (int index) {
    var rng = Random();
    return Note(
      time: DateTime.now().copyWith(hour: 1, minute: 5 + 3 * index),
      thumbnail: Image.asset("images/D++285logo.png", width: 30),
      temp: 27 + rng.nextInt(20) * 0.1,
      depth: 4 + rng.nextInt(20) * 0.1,
      salinity: 35.0 + rng.nextInt(10),
    );
  });

  void addNote(Note note) {
    setState(() {
      _notes.add(note);
      _notes.sort((a, b) => a.time.compareTo(b.time));
    });
  }

  void removeNote(int index) {
    setState(() {
      _notes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text("${widget.name} - Note at ${_notes[_selected].daytime()}"),
        actions: [
          IconButton(
              icon: const Icon(Icons.upload_file),
              onPressed: () =>
                  showModalBottomSheet(
                      context: context,
                      builder: (context) =>
                          Padding(
                            padding: const EdgeInsets.all(8.0).copyWith(
                                bottom: 20),
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
          IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: () async {
                FilePickerResult? files = await FilePicker.platform
                    .pickFiles(type: FileType.media, allowMultiple: true);

                try {
                  for (PlatformFile f in files!.files) {
                    File file = File(f.path!);
                    Image img = Image.file(file);
                    Map<String, IfdTag> data = await readExifFromFile(file);
                    DateFormat fmt = DateFormat("yyyy:MM:dd HH:mm:ss");
                    DateTime imageTime =
                    fmt.parse(data["EXIF DateTimeOriginal"]!.printable);
                    Note note = Note(
                      img: img,
                      thumbnail: CircleAvatar(backgroundImage: img.image),
                      time: imageTime,
                      isExternal: true,
                    );
                    addNote(note);
                  }
                } catch (err) {
                  if (context.mounted) {
                    showDialog(
                        context: context,
                        builder: (context) =>
                            ErrorDialog(description: err.toString()));
                  }
                }
              }),
        ],
        actionsPadding: const EdgeInsets.all(10),
      ),
      backgroundColor: Colors.white,
      body: Row(children: [
        Expanded(
            child: ListView.builder(
                itemCount: _notes.length,
                itemBuilder: (context, index) =>
                    SidebarCard(
                        note: _notes[index],
                        isSelected: _selected == index,
                        onTap: () =>
                            setState(() {
                              _selected = index;
                            }),
                      onLongPress: () => showMenu
                    ),
                padding: const EdgeInsets.all(8.0))),
        const VerticalDivider(),
        Expanded(flex: 2, child: _notes[_selected])
      ]),
    );
  }
}
