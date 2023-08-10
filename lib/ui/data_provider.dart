import 'package:flutter/material.dart';
import 'bd.dart';

class DataProvider extends ChangeNotifier {
  Map<String, List<Map<String, dynamic>>> dataMap = {};

  // Метод для получения данных для конкретного типа и идентификатора
  Future<void> fetchDataForId(String type, String id) async {
    try {
      final List<Map<String, dynamic>> fetchedData =
          await ApiService.fetchDataForId(type, id);

      // Обновляем данные для указанного типа и идентификатора, и уведомляем слушателей об изменении
      final key = '$type-$id';
      dataMap[key] = fetchedData;
      notifyListeners();
      
    } catch (e) {
      print('Ошибка при получении данных для типа $type и идентификатора $id: $e');
    }
  }
  
}


