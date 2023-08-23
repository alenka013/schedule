import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:raspisanie/DateTimtUtils/date_time_utis.dart';
import 'package:raspisanie/ui/bd.dart';
import 'package:intl/intl.dart';
import 'package:raspisanie/ui/data_provider.dart';
//import 'nearest_training_page.dart';
import 'theme/conteiner_table_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';



class ConteinerTable extends StatefulWidget {
  final String id;
  final DataProvider dataProvider;

  const ConteinerTable({
    required Key key,
    required this.id,
    required this.dataProvider,
  }) : super(key: key);

  @override
  State<ConteinerTable> createState() => _ConteinerTableState();
}

class _ConteinerTableState extends State<ConteinerTable> {
  List<Map<String, dynamic>> combinedData = [];
  String objectName ='';
  List<Map<String, dynamic>> data = [];
  final ScrollController _scrollController = ScrollController();
    late DataProvider dataProvider;
  bool _dateTimeUpdated = false;
bool hasEvents = false;
  @override
  void initState() {
    super.initState();
     if (widget.id.isNotEmpty) {
     widget.dataProvider.fetchDataForId("objectSchedule", widget.id);
     }
    fetchData(widget.id);
     fetchObjectName();


    // Обновление данных
    Timer.periodic(Duration(minutes: 1), (_) {
      fetchData(widget.id);
    });



    // Обновление времени до начала или окончания мероприятия
    Timer.periodic(Duration(seconds: 30), (_) {
      _updateTimeRemaining();
    });
    dataProvider = widget.dataProvider;
  }


  void fetchObjectName() async {
    try {
      final name = await ApiService.fetchObjectName("objectSchedule", widget.id);
      setState(() {
        objectName = name;
      });
    } catch (e) {
      print('Error fetching object name: $e');
    }
  }


void _updateTimeRemaining() {
  if (mounted) {
  final now = DateTime.now();
  final List<Map<String, dynamic>> updatedData = [];

  for (var event in data) {
  final startDateString = event['StartDate'];
  final endDateString = event['EndDate'];

  if (startDateString != null && endDateString != null) {
    final startTime = customDateFormat.parse(startDateString);
    final endTime = customDateFormat.parse(endDateString);

    if (now.isBefore(endTime)) {
      // Мероприятие еще не закончилось, обновляем оставшееся время
      event['TimeRemaining'] = getTimeRemaining(startTime, endTime);
      updatedData.add(event);
    }
  }
}

  setState(() {
    data = updatedData;
  });
}}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  if (widget.id.isNotEmpty) {
      fetchData(widget.id);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchData(String id) async {
  try {
final List<Map<String, dynamic>> fetchedData =
        await ApiService.fetchDataForId("objectSchedule", id);



    final now = DateTime.now();
    final endOfNext24Hours = now.add(Duration(hours: 24));

    final currentEvents = fetchedData.where((item) {
      final startDate = customDateFormat.parse(item['StartDate'] ?? '');
      final endDate = customDateFormat.parse(item['EndDate'] ?? '');
      return startDate.isBefore(endOfNext24Hours) && endDate.isAfter(now);
    }).toList();

    final futureEvents = fetchedData.where((item) {
      final startDate = customDateFormat.parse(item['StartDate'] ?? '');
      return startDate.isAfter(now) && startDate.isBefore(endOfNext24Hours);
    }).toList();

    currentEvents.sort((a, b) {
      final aStartDate = customDateFormat.parse(a['StartDate'] ?? '');
      final bStartDate = customDateFormat.parse(b['StartDate'] ?? '');
      return aStartDate.compareTo(bStartDate);
    });

    futureEvents.sort((a, b) {
      final aStartDate = customDateFormat.parse(a['StartDate'] ?? '');
      final bStartDate = customDateFormat.parse(b['StartDate'] ?? '');
      return aStartDate.compareTo(bStartDate);
    });

    final List<Map<String, dynamic>> combinedData = [];
    combinedData.addAll(currentEvents);
combinedData.addAll(futureEvents);

if (combinedData.isEmpty) {
  combinedData.add({'NoData': true});
} else {
  hasEvents = true;
}

setState(() {
  data = combinedData;
});
  } catch (e) {
    print('Ошибка при получении данных: $e');
  }
}


  Map<String, List<Map<String, dynamic>>> _groupEventsByTime(
      List<Map<String, dynamic>> events) {
    final groupedEvents = <String, List<Map<String, dynamic>>>{};

    for (var event in events) {
      final startTime = extractTime(event['StartDate']);
      final endTime = extractTime(event['EndDate']);
      final timeString = '$startTime - $endTime';

      groupedEvents.putIfAbsent(timeString, () => []);
      groupedEvents[timeString]!.add(event);
    }

    return groupedEvents;
  }

  Map<String, List<Map<String, dynamic>>> groupDataByDate() {
    final groupedData = <String, List<Map<String, dynamic>>>{};
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month);

    for (var item in data) {
      final startDate = item['StartDate'] != null
          ? customDateFormat.parse(item['StartDate'])
          : null;
      final endDate = item['EndDate'] != null
          ? customDateFormat.parse(item['EndDate'])
          : null;
      if (startDate != null &&
          endDate != null &&
          startDate.isAfter(now) &&
          endDate.isAfter(now)) {
        if (startDate.isAfter(startOfMonth)) {
          final dateString = DateFormat('dd.MM.yyyy').format(startDate);
          groupedData.putIfAbsent(dateString, () => []);
          groupedData[dateString]!.add(item);
        }
      }
    }

    return groupedData;
  }

  List<String> getNearestEventDates(
      Map<String, List<Map<String, dynamic>>> groupedData) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month);
    final nearestDates = <DateTime>[];

    for (var item in data) {
      final startDate = item['StartDate'] != null
          ? customDateFormat.parse(item['StartDate'])
          : null;
      final endDate = item['EndDate'] != null
          ? customDateFormat.parse(item['EndDate'])
          : null;

      if (startDate != null && endDate != null && endDate.isAfter(now)) {
        if (startDate.isAfter(startOfMonth)) {
          nearestDates.add(startDate);
        }
      }
    }

    nearestDates.sort((a, b) => a.isBefore(b) ? -1 : 1);

    if (nearestDates.isNotEmpty) {
      return [DateFormat('dd.MM.yyyy').format(nearestDates.first)];
    } else {
      return [];
    }
  }

  String getTimeRemaining(DateTime startTime, DateTime endTime) {
    final now = DateTime.now();

    if (now.isAfter(endTime)) {
      return 'Мероприятие закончилось';
    } else if (now.isBefore(startTime)) {
      final remainingDuration = startTime.difference(now);
      final remainingHours = remainingDuration.inHours;
      final remainingMinutes = remainingDuration.inMinutes % 60;
      return ' $remainingHours ч $remainingMinutes мин';
    } else {
      final remainingDuration = endTime.difference(now);
      final remainingHours = remainingDuration.inHours;
      final remainingMinutes = remainingDuration.inMinutes % 60;
      return ' $remainingHours ч $remainingMinutes мин';
    }
  }

  Widget _buildTableHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.fromLTRB(
                20.0, 8.0, 8.0, 8.0), // Обновляем отступы слева и справа
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey, width: 1.0),
                left: BorderSide(color: Colors.grey, width: 1.0),
                right: BorderSide(
                    color: Colors.transparent,
                    width: 0.0), // Убираем правую границу
                bottom: BorderSide(color: Colors.grey, width: 1.0),
              ),
            ),
            child: AutoSizeText(
              'Ближайшие мероприятия',
              style: ConteinerTableTheme.cap,
               maxLines: 1, 
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.fromLTRB(
                8.0, 8.0, 8.0, 8.0), // Обновляем отступы слева и справа
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey, width: 1.0),
                right: BorderSide(color: Colors.grey, width: 1.0),
                bottom: BorderSide(color: Colors.grey, width: 1.0),
              ),
            ),
            child: Center(
              child: AutoSizeText(
                'До начала',
                style: ConteinerTableTheme.cap,
                 maxLines: 1, 
              ),
            ),
          ),
        ),
      ],
    );
  }

  final Color orangeColor = Color.fromARGB(255, 254, 217, 163);
  final Color purpleColor = Color.fromARGB(255, 199, 173, 247);
  final Color blueColor = Color.fromARGB(255, 164, 217, 244);
  bool isCurrentEvent(DateTime startTime, DateTime endTime) {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  Widget _buildTableRow(
    String timeString,
    String sportsName,
    String eventsText,
    String timeRemaining,
    bool isCurrentEvent,
    int rowIndex,
    String id,
  ) {
    final bool isNearestEvent = !isCurrentEvent && rowIndex % 2 == 0;
 if (data[rowIndex].containsKey('NoData')) {
    return Container(
      // Выводим сообщение о отсутствии данных
      child: Text('Занятий нет'),
    );
  }
else{
    final Color cellColor = isCurrentEvent
        ? orangeColor
        : (isNearestEvent ? blueColor : purpleColor);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.grey, width: 1.0),
          right: BorderSide(color: Colors.grey, width: 1.0),
          bottom: BorderSide(color: Colors.grey, width: 1.0),
        ),
        color: cellColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            // Верхняя строка (Время и Название спорта)
            color: !isCurrentEvent ? Colors.white : cellColor,

            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                            color: Colors.grey,
                            width: 1.0), // Добавляем правую границу
                        bottom: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                    ),
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: AutoSizeText(
                        timeString,
                        style: ConteinerTableTheme.timeTextStyle,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                    ),
                    padding: const EdgeInsets.only(left: 40.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: AutoSizeText(
                        sportsName,
                        style: ConteinerTableTheme.bottom,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            // Нижняя строка (Описание событий и Время до начала)
            color: cellColor,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.only(left: 20.0),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: AutoSizeText(
                        eventsText,
                        style: ConteinerTableTheme.bottom,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    child: Center(
                      child: AutoSizeText(
                        timeRemaining,
                        style: ConteinerTableTheme.bottom,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }}

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoadingAnimationWidget.flickr(
                leftDotColor: Colors.blue,
                rightDotColor: Color.fromARGB(255, 253, 64, 64),
                size: 50,
              ),
            ],
          ),
        ),
      );
    }
    if (!_dateTimeUpdated) {
      // Если дата и время еще не обновлены, обновляем их сейчас
      //DateTime now = DateTime.now();
      _dateTimeUpdated = true;
    }
    final groupedData = groupDataByDate();
    return Scaffold(
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width, // 90% экрана
          padding: EdgeInsets.all(10.0),
          child: ListView(
            children: [
              _buildCurrentEventsTable(),
              SizedBox(height: 20),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: groupedData.length,
                itemBuilder: (BuildContext context, int index) {
                  final dateString = groupedData.keys.elementAt(index);
                  final events = groupedData[dateString]!;
                  final groupedEvents = _groupEventsByTime(events);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: AutoSizeText(
                              dateString,
                              style: ConteinerTableTheme.bottom,
                            ),
                          ),
                        ),
                      ),
                     ListView.builder(
  physics: NeverScrollableScrollPhysics(),
  shrinkWrap: true,
  itemCount: groupedEvents.length + 1,
  itemBuilder: (context, index) {
    if (index == 0) {
      return _buildTableHeader();
    }

    final timeString = groupedEvents.keys.elementAt(index - 1);
    final eventsWithSameTime = groupedEvents[timeString]!;

    final sportsName = '';
    final timeRemaining = getTimeRemaining(
      customDateFormat.parse(eventsWithSameTime[0]['StartDate'] ?? ''),
      customDateFormat.parse(eventsWithSameTime[0]['EndDate'] ?? ''),
    );

    Set<String> eventsTextSet = {}; // Используем Set для хранения уникальных названий событий

    for (var event in eventsWithSameTime) {
      eventsTextSet.add(event['Title'] ?? '');
    }

    String eventsText = eventsTextSet.join(', '); // Преобразуем Set в строку

    return _buildTableRow(
      timeString,
      sportsName,
      eventsText,
      timeRemaining,
      false,
      index,
      widget.id,
    );
  },
),

                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentEventsTable() {
    // Получаем все мероприятия из данных
    List<Map<String, dynamic>> allEvents = data;
  // Если данных нет, выводим сообщение
   if (allEvents.any((event) => event.containsKey('NoData'))) {
     return Center(
       child:Column(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
     Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                 Padding(
          padding: EdgeInsets.all(10.0),
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Center(
                child: AutoSizeText(
                  objectName,
                // widget.id, // Здесь выводится значение id
                  style: TextStyle(fontSize: 40),
                ),
              ),
            ),
          ),
        ),

      
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 40),
                      child: AutoSizeText(
                        'Нет доступных мероприятий',
                        style: ConteinerTableTheme.bottom,
                      ),
                    ),
                  ),
                ),
                
              ],
            ),]));
   }
    // Получаем текущее время
    final now = DateTime.now();

    // Фильтруем мероприятия, которые уже начались, но еще не закончились
    List<Map<String, dynamic>> currentEvents = allEvents.where((event) {
      final startTime = customDateFormat.parse(event['StartDate'] ?? '');
      final endTime = customDateFormat.parse(event['EndDate'] ?? '');
      return startTime.isBefore(now) && endTime.isAfter(now);
    }).toList();

    // Группируем мероприятия по дате и времени начала
    Map<String, Map<String, List<Map<String, dynamic>>>> groupedByDateTime = {};
    for (var event in currentEvents) {
      final startDate = event['StartDate'] ?? '';
      final dateString =
          startDate.length >= 10 ? startDate.substring(0, 10) : '';
      final timeString =
          startDate.length >= 16 ? startDate.substring(11, 16) : '';

      if (!groupedByDateTime.containsKey(dateString)) {
        groupedByDateTime[dateString] = {};
      }
      if (!groupedByDateTime[dateString]!.containsKey(timeString)) {
        groupedByDateTime[dateString]![timeString] = [];
      }
      groupedByDateTime[dateString]![timeString]!.add(event);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Padding(
          padding: EdgeInsets.all(10.0),
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Center(
                child: AutoSizeText(
                  objectName,
                // widget.id, // Здесь выводится значение id
                  style: TextStyle(fontSize: 40),
                ),
              ),
            ),
          ),
        ),

        // Строим список групп с таблицами текущих мероприятий
        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: groupedByDateTime.keys.length,
          itemBuilder: (context, index) {
            final dateString = groupedByDateTime.keys.elementAt(index);
            final timeGroups = groupedByDateTime[dateString]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: AutoSizeText(
                        dateString,
                        style: ConteinerTableTheme.bottom,
                      ),
                    ),
                  ),
                ),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: timeGroups.keys.length,
                  itemBuilder: (context, index) {
                    final timeString = timeGroups.keys.elementAt(index);

                    final events = timeGroups[timeString]!;
                    final startTime =
                        customDateFormat.parse(events[0]['StartDate'] ?? '');
                    final endTime =
                        customDateFormat.parse(events[0]['EndDate'] ?? '');
                    final formattedTime =
                        '${DateFormat('HH:mm').format(startTime)} - ${DateFormat('HH:mm').format(endTime)}';
                   // final trainers = events[0]['Trainers'] ?? [];
                    final sportsName = // trainers.isNotEmpty
                        //    ? (trainers[0]['Sports']?[0]['Name'] ?? '')
                        // :
                        '';
                    final eventsText =
                        events.map((event) => event['Title'] ?? '').join(', ');
                    final timeRemaining = getTimeRemaining(startTime, endTime);

                    return Column(
                      children: [
                        _buildTableHeaderForCurrentEvents(), // Шапка таблицы
                        _buildTableRow(
                          formattedTime,
                          sportsName,
                          eventsText,
                          timeRemaining,
                          true, // Установите isCurrentEvent в true для текущих мероприятий
                          index,
                           widget.id
                        ),
                      ],
                    );
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildTableHeaderForCurrentEvents() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20.0, 8.0, 8.0, 8.0),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey, width: 1.0),
                left: BorderSide(color: Colors.grey, width: 1.0),
                right: BorderSide(color: Colors.transparent, width: 0.0),
                bottom: BorderSide(color: Colors.grey, width: 1.0),
              ),
            ),
            child: AutoSizeText(
              'Текущие мероприятия', // Измененный текст для текущих мероприятий
              style: ConteinerTableTheme.cap,
               maxLines: 1, 
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey, width: 1.0),
                //    left: BorderSide(color: Colors.grey, width: 1.0),
                right: BorderSide(color: Colors.grey, width: 1.0),
                bottom: BorderSide(color: Colors.grey, width: 1.0),
              ),
            ),
            child: Center(
              child: AutoSizeText(
                'До конца',
                style: ConteinerTableTheme.cap,
                 maxLines: 1, 
              ),
            ),
          ),
        ),
      ],
    );
  }
  
}
