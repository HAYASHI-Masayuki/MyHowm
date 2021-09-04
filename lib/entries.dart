import 'dart:collection';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:my_howm/entry.dart';
import 'package:path_provider/path_provider.dart';

class Entries extends ListBase {
  final _entries = <Entry>[];

  @override
  get length => _entries.length;

  @override
  set length(int length) {
    _entries.length = length;
  }

  @override
  operator [](int index) => _entries[index];

  @override
  void operator []=(int index, value) {
    _entries[index] = value;
  }

  @override
  void add(value) => _entries.add(value);

  load() async {
    final _datePattern = RegExp(r'^\[(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})\]'); // \z?

    final _docDir = (await getApplicationDocumentsDirectory()).path;
    final _howmDir = '$_docDir/howm';

    _entries.clear();

    await Directory(_howmDir).create(recursive: true);

    final lines = File('$_howmDir/test.howm').readAsLinesSync();
print(lines);
    var _title = '';
    var _body  = '';
    DateTime? _createdAt = null;

    for (final line in lines) {
      if (line.startsWith('= ')) {
        if (_title != '') {
          _entries.add(Entry(_title, _body, _createdAt));
        }

        _title = line.replaceFirst('= ', '');
        _body  = '';
        _createdAt = null;
      } else if (_datePattern.hasMatch(line)) {
        final match = _datePattern.firstMatch(line);

        _createdAt = DateFormat('yyyy-MM-dd HH:mm:ss').parse(match!.group(1)!);
      } else {
        _body += line + "\n";
      }
    }

    if (_title != '') {
      _entries.add(Entry(_title, _body, _createdAt));
    }
  }

  save() async {
    final _docDir = (await getApplicationDocumentsDirectory()).path;
    final _howmDir = '$_docDir/howm';

    await Directory(_howmDir).create(recursive: true);

    var contents = '';

    this._entries.forEach((entry) {
      contents += entry.getTitle()
          + "\n"
          + entry.getBody()
          + "\n"
          + entry.getCreatedAtFormatted()
          + "\n\n";
    });
    
    await File('$_howmDir/test.howm').writeAsString(contents);

    print('saved!');
  }
}
