import 'dart:collection';
import 'dart:io';
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
    
    print('$_howmDir/test.howm');

    await File('$_howmDir/test.howm').writeAsString(contents);
  }
}
