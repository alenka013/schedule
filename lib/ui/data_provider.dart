import 'package:flutter/material.dart';
import 'bd.dart';

class DataProvider extends ChangeNotifier {
  List<Map<String, dynamic>> data = [];

  Future<void> fetchData() async {
    try {
      final List<Map<String, dynamic>> fetchedData =
          await ApiService.fetchData();

      // Обновляем данные и уведомляем слушателей об изменении
      data = fetchedData;
      notifyListeners();
    } catch (e) {
      print('Ошибка при получении данных: $e');
    }
  }
}