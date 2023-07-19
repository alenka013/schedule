  import 'package:intl/intl.dart';
import '../DateTimtUtils/date_time_utis.dart';
import '../ui/bd.dart';


 List<Map<String, dynamic>> data = [];
  Future<void> fetchData() async {
    final fetchedData = await ApiService.fetchData();
    final now = DateTime.now();

    final filteredData = fetchedData.where((item) {
      final startDate = customDateFormat.parse(item['StartDate'] ?? '');
      return startDate.day == now.day || startDate.day == now.day + 1;
    }).toList();

    filteredData.sort((a, b) {
      final aStartDate = customDateFormat.parse(a['StartDate'] ?? '');
      final bStartDate = customDateFormat.parse(b['StartDate'] ?? '');
      return aStartDate.compareTo(bStartDate);
    });

   
  }

  Map<String, List<Map<String, dynamic>>> groupDataByDate() {
    final groupedData = <String, List<Map<String, dynamic>>>{};

    for (var item in data) {
      final date = item['StartDate'] != null ? customDateFormat.parse(item['StartDate']) : null;

      if (date != null) {
        final dateString = DateFormat('dd.MM.yyyy').format(DateTime.now());
        groupedData.putIfAbsent(dateString, () => []);
        groupedData[dateString]!.add(item);
      }
    }

    return groupedData;
  }
