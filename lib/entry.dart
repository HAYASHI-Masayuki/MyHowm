import 'package:intl/intl.dart';

class Entry {
  String _title = '';
  String _body  = '';
  DateTime _createdAt = DateTime.now();

  Entry(this._title, this._body, this._createdAt);

  getTitle() => this._title;

  getBody() => this._body;

  getCreatedAtFormatted() {
    final ymdhms = DateFormat('yyyy-MM-dd HH:mm:ss');

    return '[' + ymdhms.format(this._createdAt) + ']';
  }
}
