import 'dart:collection';
import 'dart:io';
import 'package:ext_storage/ext_storage.dart';
import 'package:intl/intl.dart';
import 'package:my_howm/entry.dart';
import 'package:permission_handler/permission_handler.dart';

class Entries extends ListBase {
  final _entries = <Entry>[];

  String? _dirpath;
  String? _filepath;

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

  Future<Entries> load(DateTime dateTime) async {
    final _createdAtPattern = RegExp(r'^\[(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})\]'); // \z?

    final _docDir = (await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_DOCUMENTS))!;
    final _dirFormat = "yyyy/MM";

    _dirpath = '$_docDir/howm/' + DateFormat(_dirFormat).format(dateTime);

    final _fileFormat = "yyyy-MM-dd'.howm'";
    final _howmFile = DateFormat(_fileFormat).format(dateTime);

    _filepath = '$_dirpath/$_howmFile';

    _entries.clear();

    if (! await Permission.manageExternalStorage.request().isGranted) {
      // TODO: エラー出さないと
      return this;
    }

    await Directory(_dirpath!).create(recursive: true);

    if (! File(_filepath!).existsSync()) {
      return this;
    }

    print('Open: ' + _filepath!);

    var lines = File(_filepath!).readAsLinesSync();

    var _title = '';
    var _body  = '';
    DateTime? _createdAt;

    for (final line in lines) {
      if (line.startsWith('= ')) {
        if (_title != '') {
          _entries.add(Entry(_title, _body, _createdAt));
        }

        _title = line.replaceFirst('= ', '');
        _body  = '';
        _createdAt = null;
      } else if (_createdAtPattern.hasMatch(line)) {
        final match = _createdAtPattern.firstMatch(line);

        _createdAt = DateFormat('yyyy-MM-dd HH:mm:ss').parse(match!.group(1)!);
      } else {
        _body += line + "\n";
      }
    }

    if (_title != '') {
      _entries.add(Entry(_title, _body, _createdAt));
    }

    return this;
  }

  save() async {
    await Directory(_dirpath!).create(recursive: true);

    var contents = '';

    this._entries.forEach((entry) {
      contents += entry.getTitle()
          + "\n"
          + entry.getBody()
          + "\n"
          + entry.getCreatedAtFormatted()
          + "\n\n";
    });

    if (! await Permission.manageExternalStorage.request().isGranted) {
      // TODO: エラー出さないと
      return;
    }

    await File(_filepath!).writeAsString(contents);
  }
}
