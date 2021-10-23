import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_howm/entries.dart';

class View extends StatefulWidget {
  final Entries entries;

  View({Key? key, required this.entries}) : super(key: key);

  @override
  _View createState() => _View(entries: this.entries);
}

class _View extends State<View> {
  final Entries entries;

  _View({required this.entries});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('今日・昨日')),
        body: Column(children: [
          Expanded(
              child: ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return Card(
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(entries[index].getTitle()),
                          Text(entries[index].getBody()),
                          Text(entries[index].getCreatedAtFormatted()),
                        ],
                        crossAxisAlignment: CrossAxisAlignment.start,
                      )));
            },
            itemCount: entries.length,
          ))
        ]));
  }
}
