import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'package:provider/provider.dart';
import 'database/moor_database.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ignore: missing_required_param
    return Provider(
      create: (_) => AppDatabase(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Biblogen Reference Manager',
        home: Home(),
      ),
    );
  }
}
