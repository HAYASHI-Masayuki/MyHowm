import 'dart:collection';
import 'dart:io';
import 'package:ext_storage/ext_storage.dart';
import 'package:intl/intl.dart';
import 'package:my_howm/entry.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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

    //File('$_howmDir/test.howm').deleteSync();

    var lines = <String>[];

    if (File('$_howmDir/test.howm').existsSync()) {
      print('file exists');
      lines = File('$_howmDir/test.howm').readAsLinesSync();
    }

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

    if (! await Permission.manageExternalStorage.request().isGranted) {
      return;
    }

    var _backupDir = (await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_DOCUMENTS))!
      + '/howm';

    Directory(_backupDir).create(recursive: true);

    var ymd = DateFormat('yyyy-MM-DD-hh-mm-ss').format(DateTime.now());

    File('$_howmDir/test.howm').copySync('$_backupDir/$ymd.howm');

    print('saved!');
  }
}
