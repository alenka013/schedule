import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'conteiner_screen.dart';
import 'ui/bd.dart';

class IdSelectionScreen extends StatefulWidget {
  @override
  _IdSelectionScreenState createState() => _IdSelectionScreenState();
}

class _IdSelectionScreenState extends State<IdSelectionScreen> {
  final ValueNotifier<DateTime> _dateTimeNotifier = ValueNotifier<DateTime>(DateTime.now());

  @override
  void initState() {
    super.initState();
    _startDateTimeUpdate();
  }

  void _startDateTimeUpdate() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _dateTimeNotifier.value = DateTime.now();
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _dateTimeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        backgroundColor: Colors.white10,
        elevation: 0,
        flexibleSpace: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ValueListenableBuilder<DateTime>(
              valueListenable: _dateTimeNotifier,
              builder: (context, value, child) {
                final formattedDate = DateFormat('dd MMMM y года', 'ru_RU').format(value);
                final formattedTime = DateFormat('HH:mm:ss', 'ru_RU').format(value);

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 40.0),
                      child: Text(
                        formattedDate,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 40,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 40.0),
                      child: Text(
                        formattedTime,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 40,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: FutureBuilder<List<String>>(
          future: ApiService.fetchScheduleGuidObjectList(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Ошибка: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text('Список идентификаторов пуст');
            } else {
              return ContainerTableScreenList(idList: snapshot.data!);
            }
          },
        ),
      ),
    );
  }
}









