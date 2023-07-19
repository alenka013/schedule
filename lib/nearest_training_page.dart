import 'dart:async';
import 'package:flutter/material.dart';
import 'package:raspisanie/DateTimtUtils/date_time_utis.dart';


class NearestTrainingPage extends StatefulWidget {
  final String nearestDate; // Дата ближайшей тренировки
  final List<Map<String, dynamic>> events; // Список событий на ближайшую дату

  NearestTrainingPage({required this.nearestDate, required this.events});

  @override
  _NearestTrainingPageState createState() => _NearestTrainingPageState();
}

class _NearestTrainingPageState extends State<NearestTrainingPage> {
  final ScrollController _scrollController = ScrollController();
  late Timer _scrollTimer;
  bool _scrollingForward = true;
  late List<Map<String, dynamic>> sortedEvents;

  @override
  void initState() {
    super.initState();
    sortedEvents = List<Map<String, dynamic>>.from(widget.events);
    _sortEvents();
    _scrollTimer = Timer.periodic(Duration(seconds: 5), (_) => _scrollContent());
  }

  @override
  void dispose() {
    _scrollTimer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _sortEvents() {
    sortedEvents.sort((a, b) {
      final aStartTime = extractTime(a['StartDate']);
      final bStartTime = extractTime(b['StartDate']);
      return aStartTime.compareTo(bStartTime);
    });
  }

  void _scrollContent() {
    setState(() {
      if (_scrollingForward && _scrollController.position.extentAfter == 0) {
        _scrollingForward = false;
        if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent) {
          // Если достигли конца списка, возвращаемся на предыдущую страницу
          Navigator.pop(context);
          return;
        }
        _sortEvents(); // Пересортировываем перед обратной прокруткой
      }
      // Если список прокручивается назад и достиг начала, меняем направление прокрутки на вперед
      if (!_scrollingForward && _scrollController.position.extentBefore == 0) {
        _scrollingForward = true;
        _sortEvents(); 
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
    });
  }

  Map<String, List<String>> groupedEvents = {};

  @override
  Widget build(BuildContext context) {
    _groupEventsByTimeAndSport();

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                widget.nearestDate,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: groupedEvents.length,
              itemBuilder: (context, index) {
                final timeAndSport = groupedEvents.keys.toList()[index];
                final titles = groupedEvents[timeAndSport]!;
                final timeAndSportParts = timeAndSport.split('-');
                final startTime = timeAndSportParts[0];
                final endTime = timeAndSportParts[1];
                final sportsName = timeAndSportParts[2];
                final titleString = titles.join(', '); // Объединяем титлы через запятую

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
                              '$startTime - $endTime',
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
                        titleString, 
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
      ),
    );
  }

  void _groupEventsByTimeAndSport() {
    groupedEvents.clear();

    for (var event in sortedEvents) {
      final startTime = extractTime(event['StartDate']);
      final endTime = extractTime(event['EndDate']);
      final sportsName = _getSportsName(event);
      final timeAndSport = '$startTime-$endTime-$sportsName';

      if (!groupedEvents.containsKey(timeAndSport)) {
        groupedEvents[timeAndSport] = [];
      }

      final title = event['Title'] ?? '';
      if (!groupedEvents[timeAndSport]!.contains(title)) {
        groupedEvents[timeAndSport]!.add(title);
      }
    }
  }

  // Вспомогательная функция для получения названия спорта из события
  String _getSportsName(Map<String, dynamic> event) {
    final trainers = event['Trainers'] ?? [];
    return trainers.isNotEmpty ? (trainers[0]['Sports']?[0]['Name'] ?? '') : '';
  }
}
