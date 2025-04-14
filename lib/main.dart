import 'package:contacts/pages/contact_list.dart';

import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  final box = await Hive.openBox('contacts');

  runApp(const CupertinoApp(
    debugShowCheckedModeBanner: false,
    theme: CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: CupertinoColors.systemBlue,
    ),
    home: ContactList(),
  ));
}
