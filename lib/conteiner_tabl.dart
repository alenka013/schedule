 import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_swipe/flutter_swipe.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:raspisanie/DateTimtUtils/date_time_utis.dart';  
import 'package:raspisanie/ui/bd.dart';  
import 'package:intl/intl.dart';  
import 'nearest_training_page.dart';
import 'theme/conteiner_table_theme.dart';

class ConteinerTable extends StatefulWidget {  
  const ConteinerTable({Key? key}) : super(key: key);  

  @override
  State<ConteinerTable> createState() => _ConteinerTableState();  
}

class _ConteinerTableState extends State<ConteinerTable> {  
  List<Map<String, dynamic>> data = [];  
 late Timer _scrollTimer;
  final ScrollController _scrollController = ScrollController();
  bool _scrollingForward = true;
 Timer? _openTrainingPageTimer;
 late SwiperController _swiperController;

  @override
  void initState() {  
    super.initState();
    fetchData();  
        _scrollTimer = Timer.periodic(Duration(seconds: 5), (_) {
          _scrollContent();

    });
    _startTrainingPageTimer();
     _swiperController = SwiperController();
}


@override
void didChangeDependencies() {
  super.didChangeDependencies();

  // При изменении зависимостей (включая возврат на страницу) перезапускаем таймер
  _startTrainingPageTimer();
}

void _startTrainingPageTimer() {
   // _openTrainingPageTimer?.cancel();
  // Запускаем таймер, который будет вызывать _openNearestTrainingPage каждые 5 секунд,
  // только если НЕТ занятий на сегодня или завтра
  _openTrainingPageTimer = Timer.periodic(Duration(seconds: 10), (_) {
    final groupedData = groupDataByDate();
    final nearestEventDates = getNearestEventDates(groupedData);
   final isCurrentPage = ModalRoute.of(context)?.isCurrent;
    if (isCurrentPage == true && !hasEventsForTodayAndTomorrow(groupDataByDate())) {
      _openNearestTrainingPage(context, nearestEventDates[0], groupedData[nearestEventDates[0]]!);
      _openTrainingPageTimer?.cancel(); // Отменяем таймер после перехода на страницу
      
    }
  });
}

  @override
  void dispose() {
  
    _scrollTimer.cancel();
    _scrollController.dispose();
    super.dispose();
    _openTrainingPageTimer?.cancel();
  }


  Future<void> fetchData() async {  
    final fetchedData = await ApiService.fetchData();  
    final now = DateTime.now();  // Получение текущей даты и времени.
    final today = DateTime(now.year, now.month, now.day);  
    final tomorrow = today.add(Duration(days: 1));  
    final filteredData = fetchedData.where((item) {  // Фильтрация данных, оставляющая только сегодняшние и завтрашние события.
      final startDate = customDateFormat.parse(item['StartDate'] ?? '');  
      final startDateOnly = DateTime(startDate.year, startDate.month, startDate.day);  // Получение даты начала события без времени.
      return startDateOnly == today || startDateOnly == tomorrow; 
    }).toList();

    filteredData.sort((a, b) {  // Сортировка данных по дате начала события.
      final aStartDate = customDateFormat.parse(a['StartDate'] ?? '');
      final bStartDate = customDateFormat.parse(b['StartDate'] ?? '');
      return aStartDate.compareTo(bStartDate);
    });

    setState(() { 
      data = filteredData.isEmpty ? fetchedData : filteredData;
    });
  }
  
Map<String, List<Map<String, dynamic>>> _groupEventsByTime(List<Map<String, dynamic>> events) {
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
      final startDate = item['StartDate'] != null ? customDateFormat.parse(item['StartDate']) : null;  
      final endDate = item['EndDate'] != null ? customDateFormat.parse(item['EndDate']) : null;

      if (startDate != null && endDate != null && endDate.isAfter(now)) {  
        if (startDate.isAfter(startOfMonth)) {  
          final dateString = DateFormat('dd.MM.yyyy').format(startDate);  
          groupedData.putIfAbsent(dateString, () => []);  
          groupedData[dateString]!.add(item);  
        }
      }
    }

    return groupedData; 
  }

  bool hasEventsForTodayAndTomorrow(Map<String, List<Map<String, dynamic>>> groupedData) {  
    final now = DateTime.now(); 
    final dateStringToday = DateFormat('dd.MM.yyyy').format(now); 
    final dateStringTomorrow = DateFormat('dd.MM.yyyy').format(now.add(Duration(days: 1)));  
    return groupedData.containsKey(dateStringToday)|| groupedData.containsKey(dateStringTomorrow);  
  }

  List<String> getNearestEventDates(Map<String, List<Map<String, dynamic>>> groupedData) {  
    final now = DateTime.now();  
    final startOfMonth = DateTime(now.year, now.month);
    final nearestDates = <DateTime>[];  

    for (var item in data) { 
      final startDate = item['StartDate'] != null ? customDateFormat.parse(item['StartDate']) : null;  
      final endDate = item['EndDate'] != null ? customDateFormat.parse(item['EndDate']) : null;  

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



void _scrollContent() {
  if (!_scrollController.hasClients) {
    return;
  }
final groupedData = groupDataByDate();
  bool hasEventsTodayAndTomorrow = hasEventsForTodayAndTomorrow(groupedData);

  if (_scrollingForward && _scrollController.position.extentAfter == 0) {
    _scrollingForward = false;
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent) {
      // Если достигли конца списка и есть 2 дата занятий, свайпаем (сегодня и завтра)
      if (hasEventsTodayAndTomorrow && groupedData.length >= 2 ) {
      _swiperController.next();
    } 
      return;
    }
  }

  // Если список прокручивается назад и достиг начала, меняем направление прокрутки на вперед
  if (!_scrollingForward && _scrollController.position.extentBefore == 0) {
    _scrollingForward = true;
  }

  if (_scrollingForward) {
    _scrollController.animateTo(
      _scrollController.offset + _scrollController.position.viewportDimension,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  } else {
    _scrollController.animateTo(
      _scrollController.offset - _scrollController.position.viewportDimension,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}




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

    final groupedData = groupDataByDate();  
    final hasEventsTodayAndTomorrow = hasEventsForTodayAndTomorrow(groupedData); 
    final nearestEventDates = getNearestEventDates(groupedData); 
    
    return Scaffold(  
      body: 
  //    Container(
  //  color: tableBackgroundColor, // цвет фона
   // child:
     hasEventsTodayAndTomorrow  
          ? Swiper(  
            controller: _swiperController,
              itemCount: groupedData.length, 
           //  autoplay: true, 
              autoplayDelay: 5000, 
              itemBuilder: (BuildContext context, int index) {
  final dateString = groupedData.keys.elementAt(index);
  final events = groupedData[dateString]!;
  final groupedEvents = _groupEventsByTime(events);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Text(
            dateString,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      Expanded(
        child: ListView.builder(
            controller: _scrollController,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: groupedEvents.length,
          itemBuilder: (context, index) {
            final timeString = groupedEvents.keys.elementAt(index);
            final eventsWithSameTime = groupedEvents[timeString]!;
            final trainers = eventsWithSameTime[0]['Trainers'] ?? [];
            final sportsName = trainers.isNotEmpty ? (trainers[0]['Sports']?[0]['Name'] ?? '') : '';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                    timeString,
                                style: ConteinerTableTheme.timeTextStyle,
                            ),
                          ),
                        ),
                        Expanded(
                          
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              sportsName,
                           
                            style: ConteinerTableTheme.sportsNameTextStyle,
                            ),
                          ),
                        ),
                      ],
                    ),
      //               Padding(
      //                 padding: const EdgeInsets.all(8.0),
      //                 child:Text(
      //               eventsWithSameTime
      //                   .map<String>((event) => event['Title'] ?? '')
      //                   .toList()
      //                   .join(', '),  
      //                    style: ConteinerTableTheme.titleTextStyle,
                    
      //                 ),
      //               ),
      //             ],
      //           );
      //     },
      //   ),
      // ),
      // const SizedBox(height: 16),

      Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: eventsWithSameTime.length,
                    itemBuilder: (context, index) {
                      final event = eventsWithSameTime[index];
                      return buildBlueCell(event['Title'] ?? '');
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      const SizedBox(height: 16),
    ],
  );
              },
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  if (nearestEventDates.isNotEmpty) ...[
                    const Text(
                    'Занятий на сегодня и завтра нет',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                    const Text(
                      'Ближайшая дата с занятиями:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    for (var date in nearestEventDates)
                      Text(
                        date,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                  ],
               ],
            ),
          ),
 // ),
);
  }
void _openNearestTrainingPage(BuildContext context, String nearestDate, List<Map<String, dynamic>> events) {
  if (!hasEventsForTodayAndTomorrow(groupDataByDate())) {
      Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => NearestTrainingPage(nearestDate: nearestDate, events: events),
    ),
  );}
}}