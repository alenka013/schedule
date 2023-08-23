import 'dart:async';
import 'dart:html';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'advertisement/my_advertisement.dart';
import 'conteiner_screen.dart';
import 'ui/bd.dart';
import 'dart:html' as html;

class IdSelectionScreen extends StatefulWidget {
  final String? displayId;

  IdSelectionScreen({this.displayId});

  @override
  _IdSelectionScreenState createState() => _IdSelectionScreenState();
}

class _IdSelectionScreenState extends State<IdSelectionScreen> {
  final ValueNotifier<DateTime> _dateTimeNotifier = ValueNotifier<DateTime>(DateTime.now());
  String _displayId = ''; 
  final TextEditingController _inputController = TextEditingController();
  //
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startDateTimeUpdate();
    _initializeInputController();
    _fetchDisplayIdAndNavigate();
    _startDelayedNavigation();
  }

  void _startDelayedNavigation() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyAdvertisement(displayId: _displayId)),
      );
    });
  }

  void _initializeInputController() {
    final queryParams = Uri.base.queryParameters;
    final inputValue = queryParams['displayId'];
    _inputController.text = inputValue ?? '';
    _inputController.addListener(_inputControllerListener);
    final updatedValue = _inputController.text;
    link = 'https://lsport.net/Facility/Displaysettings/$updatedValue';
  }

  void _inputControllerListener() {
    final updatedValue = _inputController.text;
    link = 'https://lsport.net/Facility/Displaysettings/$updatedValue';
    _updatePageUrl(updatedValue);
  }

  Future<void> _fetchDisplayIdAndNavigate() async {
    final displayId = await ApiService.fetchDisplayId();
    setState(() {
      _displayId = displayId ?? '';
      DisplayIdHolder.displayId = _displayId; // Установите displayId
    });
    window.history.pushState({}, '', _displayId);
  }

  void _updatePageUrl(String pageName) {
    final newUrl = Uri(path: pageName).toString();
    html.window.history.pushState(null, '', newUrl);
  }

  void _startDateTimeUpdate() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _dateTimeNotifier.value = DateTime.now();
      } else {
        timer.cancel();
      }
    });

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _fetchDisplayIdAndNavigate();
    });
  }

  @override
  void dispose() {
    _dateTimeNotifier.dispose();
    _timer.cancel();
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

class DisplayIdHolder {
  static String? displayId;
}
