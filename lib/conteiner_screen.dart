import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raspisanie/ui/data_provider.dart';

import 'advertisement/my_advertisement.dart';
import 'conteiner_tabl.dart';

class ContainerTableScreenList extends StatefulWidget {
  final List<String> idList;

  const ContainerTableScreenList({required this.idList});

  @override
  _ContainerTableScreenListState createState() =>
      _ContainerTableScreenListState();
}

class _ContainerTableScreenListState extends State<ContainerTableScreenList> {
  late ScrollController _scrollController;
  late Timer _timer;
  double _scrollOffset = 0;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _startAutoScroll();

  }

  
  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {

      _currentIndex++;
  
      if (_currentIndex >= widget.idList.length) {
        _currentIndex = 0;
      }
      _scrollOffset =
          _currentIndex * (MediaQuery.of(context).size.width * 0.95);
      _scrollController.animateTo(
        _scrollOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int itemCount = widget.idList.length;
    int itemsPerRow = itemCount >= 3 ? 3 : itemCount >= 2 ? 2 : 1;

    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        child: Row(
          children: List.generate(itemCount, (index) {
            final id = widget.idList[index];
            final dataProvider = DataProvider();
            return Container(
              width: MediaQuery.of(context).size.width * 0.95 / itemsPerRow,
              margin: EdgeInsets.all(8.0),
              child: Center(
                child: ConteinerTable(
                  key: Key(id),
                  id: id,
                  dataProvider: dataProvider,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}