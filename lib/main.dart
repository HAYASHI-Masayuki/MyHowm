import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_howm/entries.dart';
import 'package:my_howm/entry.dart';
import 'package:my_howm/view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const locale = Locale('ja', 'JP');

    return MaterialApp(
      title: 'MyHowm',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'MyHowm'),
      // https://qiita.com/najeira/items/dbf5663d1ed845fb1f51
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        locale,
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  final _entries = Entries();

  var _selected = '';

  _MyHomePageState() {
    _entries.load(DateTime.now());
  }

  void _createEntry(BuildContext context) {
    setState(() {
      _entries.toString();
    });

    var bodyFocusNode = FocusNode();

    var titleField = FocusScope(
        child: TextField(
          autofocus: true,
          decoration: InputDecoration(labelText: 'タイトル'),
          controller: _title,
          textInputAction: TextInputAction.none,
        ),
        onKey: (data, event) {
          if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
            bodyFocusNode.requestFocus();

            return true;
          }

          return false;
        });

    var bodyField = RawKeyboardListener(
        focusNode: FocusNode(),
        child: TextField(
          focusNode: bodyFocusNode,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          decoration: InputDecoration(labelText: '本文'),
          controller: _body,
        ),
        onKey: (event) {
        });

    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('新規メモ'),
            content: Column(children: [
              titleField,
              bodyField,
            ]),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('キャンセル')),
              TextButton(
                  onPressed: () {
                    if (_title.text == '') {
                      return;
                    }

                    setState(() {
                      _entries.insert(
                          0, Entry(_title.text, _body.text, DateTime.now()));
                      _entries.save();
                    });
                    Navigator.pop(context);
                  },
                  child: Text('追加')),
            ],
          );
        }).then((val) {
      _title.clear();
      _body.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return Card(
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(_entries[index].getTitle()),
                          Text(_entries[index].getBody()),
                          Text(_entries[index].getCreatedAtFormatted()),
                        ],
                        crossAxisAlignment: CrossAxisAlignment.start,
                      )));
            },
            itemCount: _entries.length,
          ),
        ),
        DropdownButton(
          items: [
            DropdownMenuItem<String>(value: '', child: Text('')),
            DropdownMenuItem<String>(
                value: 'yesterday_today', child: Text('今日・昨日')),
          ],
          value: _selected,
          onChanged: (String? newValue) {
            if (newValue == null) {
              return;
            }

            setState(() {
              _selected = newValue;
            });

            if (_selected == 'yesterday_today') {
              final entries = Entries();
              //entries.load(DateTime.now().subtract(const Duration(days: 1)));

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => View(entries: entries)));
            }

            setState(() {
              _selected = '';
            });
          },
        )
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _createEntry(context);
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
