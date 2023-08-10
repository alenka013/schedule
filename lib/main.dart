import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:raspisanie/ui/data_provider.dart';
import 'id_selection_screen .dart'; 

void main() {
  initializeDateFormatting('ru_RU');
  runApp(
    ChangeNotifierProvider(
      create: (context) => DataProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: //ConteinerTable(id:'1af75cba-f80b-4571-9879-59674083ae61'),
       IdSelectionScreen(),
    );
  }}

