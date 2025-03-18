import 'dart:io';

import 'package:deepnote/dialogs.dart';
import 'package:exif/exif.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class Note {
  final DateTime time;
  final double temp, depth, salinity;
  final Widget? thumbnail;
  final Image? img;
  final String summary;
  final String? fullText;
  final bool isExternal;

  const Note(
      {required this.time,
      this.temp = 28.0,
      this.depth = 5.0,
      this.salinity = 38.5,
      this.thumbnail,
      this.img,
      this.summary = "A concise summary.",
      this.fullText,
      this.isExternal = false});

  String daytime() {
    return DateFormat("HH:mm").format(time);
  }

  NoteDisplay display() {
    return NoteDisplay(note: this);
  }

  int searchPriority(String search) {
    // if search is empty, order by time
    if (search.trim().isEmpty) {
      return DateTime.now().millisecondsSinceEpoch - time.millisecondsSinceEpoch;
    }

    // split search into keywords
    final Iterable<String> keywords =
        search.split(" ").map((s) => s.toLowerCase().trim());

    // order by how many times keywords appear in summary and fullText. summary is more important than fullText
    int summaryPriority = 0;
    int fullTextPriority = 0;
    for (String keyword in keywords) {
      if (keyword.isEmpty) {
        continue;
      }

      if (summary.toLowerCase().contains(keyword)) {
        summaryPriority++;
      }
      if (fullText != null && fullText!.toLowerCase().contains(keyword)) {
        fullTextPriority++;
      }
    }

    return summaryPriority * 2 + fullTextPriority;
  }
}

class NoteDisplay extends StatelessWidget {
  final Note note;
  final TransformationController _tc = TransformationController();

  NoteDisplay({
    super.key,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
      InteractiveViewer(
        transformationController: _tc,
        clipBehavior: Clip.hardEdge,
        maxScale: 10,
        child: note.img == null
            ? Placeholder(
                child: Center(
                child: Text("Note at ${note.daytime()}"),
              ))
            : note.img!,
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
                  label: SizedBox(width: 40, child: Text(note.daytime())),
                ),
                ButtonSegment(
                  value: "Temp",
                  icon: const Icon(Icons.thermostat, color: Colors.black),
                  label: SizedBox(width: 40, child: Text("${note.temp}")),
                ),
                ButtonSegment(
                    value: "Depth",
                    icon: const Icon(Icons.water, color: Colors.black),
                    label: SizedBox(width: 40, child: Text("${note.depth}"))),
                ButtonSegment(
                    value: "Salinity",
                    icon: SvgPicture.asset("images/salinity.svg",
                        height: IconTheme.of(context).size),
                    label:
                        SizedBox(width: 40, child: Text("${note.salinity}"))),
              ]),
        ),
      )
    ]);
  }
}

class SidebarCard extends StatelessWidget {
  const SidebarCard(
      {super.key,
      required this.note,
      required this.isSelected,
      this.onTap,
      this.onLongPress});

  final Note note;
  final bool isSelected;

  final Function()? onTap;
  final Function()? onLongPress;

  @override
  Widget build(BuildContext context) {
    TextStyle labelMedium = Theme.of(context).textTheme.labelMedium!;

    Color color = isSelected
        ? Theme.of(context).primaryColor
        : Theme.of(context).cardColor;
    InkWell child = InkWell(
      borderRadius: BorderRadius.circular(12.0),
      onTap: onTap,
      onLongPress: onLongPress,
      child: ListTile(
        leading: note.thumbnail ?? CircleAvatar(backgroundImage: note.img?.image),
        title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(note.daytime(),
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
              Text(style: labelMedium, "${note.salinity}\u0025"),
            ]),
        subtitle: Row(spacing: 5, children: [
          const Icon(Icons.auto_awesome, size: 15),
          Text(note.summary)
        ]),
      ),
    );

    return note.isExternal
        ? Card.outlined(color: color, child: child)
        : Card(color: color, child: child);
  }
}

class ViewNotePage extends StatefulWidget {
  const ViewNotePage({super.key, required this.notebook});

  final Notebook notebook;

  @override
  State<ViewNotePage> createState() => _ViewNotePageState();
}

class Notebook {
  Notebook(
      {required this.notes, this.name = "New Notebook", required this.created});

  static Notebook placeholder(DateTime created,
      {String name = "New Notebook"}) {
    Random rng = Random();
    List<Note> notes = List.generate(
        10,
        (index) => Note(
              time: DateTime.now().add(Duration(minutes: index * 3)),
              thumbnail: Image.asset("images/D++285logo.png", height: 30),
              depth: 4.5 + rng.nextInt(10) * 0.1,
              salinity: 38 + rng.nextInt(50) * 0.1,
              temp: 27 + rng.nextInt(30) * 0.1,
            ));
    return Notebook(notes: notes, name: name, created: created);
  }

  String name;
  List<Note> notes;
  final DateTime created;

  void addNote(Note note) {
    notes.add(note);
    notes.sort((a, b) => a.time.compareTo(b.time));
  }

  void removeNote(int index) {
    notes.removeAt(index);
  }

  void rename(String name) {
    this.name = name;
  }
}

class _ViewNotePageState extends State<ViewNotePage> {
  int _selected = 0;

  String _search = "";

  @override
  Widget build(BuildContext context) {
    Notebook nb = widget.notebook;
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text("${nb.name} - Note at ${nb.notes[_selected].daytime()}"),
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
          IconButton(
              icon: const Icon(Icons.attach_file), onPressed: _pickFiles),
        ],
        actionsPadding: const EdgeInsets.all(10),
      ),
      backgroundColor: Colors.white,
      body: Row(children: [
        Expanded(
            child: Column(
          spacing: 8,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SearchBar(
                  hintText: "Search notes...",
                  onChanged: (String val) {
                    setState(() {
                      _search = val;
                    });
                  },
                  onSubmitted: (String val) {
                    setState(() {
                      _search = val;
                    });
                  }),
            ),
            Expanded(
              child: ListView(
                children: (nb.notes
                      ..sort((Note a, Note b) => -a
                          .searchPriority(_search)
                          .compareTo(b.searchPriority(_search))))
                    .where((note) => note.searchPriority(_search) > 0)
                    .map((note) => SidebarCard(
                        note: note,
                        isSelected: _selected == nb.notes.indexOf(note),
                        onTap: () => setState(() {
                              if (_selected != nb.notes.indexOf(note)) {
                                nb.notes[nb.notes.indexOf(note)]
                                    .display()
                                    ._tc
                                    .value = Matrix4.identity();
                              }
                              _selected = nb.notes.indexOf(note);
                            }),
                        onLongPress: () => showMenu))
                    .toList(),
              ),
            ),
          ],
        )),
        const VerticalDivider(),
        Expanded(flex: 2, child: nb.notes[_selected].display())
      ]),
    );
  }

  Future<void> _pickFiles() async {
    FilePickerResult? files = await FilePicker.platform
        .pickFiles(type: FileType.media, allowMultiple: true);

    if (files == null) {
      return;
    }

    try {
      for (PlatformFile f in files.files) {
        File file = File(f.path!);
        Image img = Image.file(file);
        Map<String, IfdTag> data = await readExifFromFile(file);
        DateFormat fmt = DateFormat("yyyy:MM:dd HH:mm:ss");
        IfdTag? dateTimeOriginal = data["EXIF DateTimeOriginal"];
        DateTime imageTime;
        if (dateTimeOriginal != null) {
          imageTime = fmt.parse(dateTimeOriginal.printable);
        } else {
          imageTime = await file.lastModified();
        }
        Note note = Note(
          img: img,
          thumbnail: CircleAvatar(backgroundImage: img.image),
          time: imageTime,
          isExternal: true,
        );
        setState(() {
          widget.notebook.addNote(note);
        });
      }
    } catch (err) {
      if (context.mounted) {
        showDialog(
            context: context,
            builder: (context) => ErrorDialog(description: err.toString()));
      }
    }
  }
}
