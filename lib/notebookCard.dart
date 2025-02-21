import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'home.dart';
import 'note.dart';

class NotebookCard extends StatelessWidget {
  const NotebookCard({super.key, required this.notebook});

  final Notebook notebook;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Transform.translate(
          offset: const Offset(14, 14),
          child: const Card(child: SizedBox.expand())),
      Transform.translate(
          offset: const Offset(7, 7),
          child: const Card(child: SizedBox.expand())),
      Card(
          child: SizedBox.expand(
              child: InkWell(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                  onTap: () => openNotebook(context, notebook),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                        spacing: 5,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(notebook.name,
                              style: TextTheme.of(context)
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w500)),
                          const Divider(),
                          Row(spacing: 8, children: [
                            const Icon(Icons.notes),
                            Text("${notebook.notes.length} notes")
                          ]),
                          Row(spacing: 8, children: [
                            const Icon(Icons.access_time),
                            Text("Created ${DateFormat("dd/MM/yy").format(notebook.created)}")
                          ])
                        ]),
                  )))),
    ]);
  }
}
