import 'dart:developer';  
import 'package:flutter/material.dart';
import 'package:auto_animated/auto_animated.dart';  
import 'package:flutter_swipe/flutter_swipe.dart';
import 'package:raspisanie/DateTimtUtils/date_time_utis.dart';  
import 'package:raspisanie/ui/bd.dart';  
import 'package:intl/intl.dart';  
import 'package:intl/date_symbol_data_local.dart'; 
import 'nearest_training_page.dart';

class ConteinerTable extends StatefulWidget {  
  const ConteinerTable({Key? key}) : super(key: key);  

  @override
  State<ConteinerTable> createState() => _ConteinerTableState();  
}

class _ConteinerTableState extends State<ConteinerTable> {  
  List<Map<String, dynamic>> data = []; 
  final ScrollController _scrollController = ScrollController();  

  @override
  void initState() {  
    super.initState();
    fetchData();  
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

  @override
  Widget build(BuildContext context) { 
    final groupedData = groupDataByDate();  
    final hasEventsTodayAndTomorrow = hasEventsForTodayAndTomorrow(groupedData); 
    final nearestEventDates = getNearestEventDates(groupedData); 
WidgetsBinding.instance!.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: 5), () {
        if (nearestEventDates.isNotEmpty) {
          _openNearestTrainingPage(context, nearestEventDates[0], groupedData[nearestEventDates[0]]!);
        }
      });
    });
    return Scaffold(  
      body: hasEventsTodayAndTomorrow  
          ? Swiper(  
              itemCount: groupedData.length, 
              autoplay: true, 
              autoplayDelay: 5000, 
              itemBuilder: (BuildContext context, int index) {  
                final dateString = groupedData.keys.elementAt(index);  
                final events = groupedData[dateString]!;  

                return Column(  
                //  crossAxisAlignment: CrossAxisAlignment.start,  // Выравнивание элементов столбца по левому краю.
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
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final item = events[index];
                          final trainers = item['Trainers'] ?? [];
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
                                        '${extractTime(item['StartDate'])} - ${extractTime(item['EndDate'])}',
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        sportsName,
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  item['Title'] ?? '',
                                  style: const TextStyle(fontSize: 24),
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
                  const Text(
                    'Занятий на сегодня и завтра нет',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  if (nearestEventDates.isNotEmpty) ...[
                    const Text(
                      'Ближайшая дата с занятиями:',
                      style: TextStyle(fontSize: 18),
                    ),
                    for (var date in nearestEventDates)
                      Text(
                        date,
                        style: const TextStyle(fontSize: 18),
                      ),
                  ],
                ],
              ),
            ),
    );
  }
void _openNearestTrainingPage(BuildContext context, String nearestDate, List<Map<String, dynamic>> events) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => NearestTrainingPage(nearestDate: nearestDate, events: events),
    ),
  );
}}
