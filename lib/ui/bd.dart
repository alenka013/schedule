

// class ApiService {
//   static const String apiUrl = 'https://lsport.net/api/read';

//   static const Map<String, String> headers = {
//     'user': 'OTgyNjE0OTQyMw==',
//     'password': 'MTIzNDU2',
//     'Content-Type': 'application/json',
//     'Cookie':
//         'ASP.NET_SessionId=ktmnnbp21gpfpihstua0t2g3; ASP.NET_SessionId=0usqght14rslvdkfbjqy4lb5; locationCity=; locationCity='
//   };

//   static Future<List<Map<String, dynamic>>> fetchData() async {
//     final List<Map<String, dynamic>> requestBodies = [
//       {
//         "type": ["objectSchedule"],
//         "id": "794785bb-87d0-4199-8f54-02c4c1a412ed",
//         "start": "01.05.2023",
//         "end": "20.08.2023"
//       },
//       {
//         "type": ["objectSchedule"],
//         "id": "1b1a304f-e8cf-453d-b40a-ae5b823f850f",
//         "start": "01.05.2023",
//         "end": "20.08.2023"
//       },
//       {
//         "type": ["objectSchedule"],
//         "id": "1af75cba-f80b-4571-9879-59674083ae61",
//         "start": "01.05.2023",
//         "end": "20.08.2023"
//       },
//       {
//         "type": ["objectSchedule"],
//         "id": "32355bc0-e781-4f3d-b348-a56be22172ea",
//         "start": "01.05.2023",
//         "end": "20.08.2023"
//       },
//     ];
//     List<Map<String, dynamic>> results = [];
//     try {
//       for (var requestBody in requestBodies) {
//         final response = await http.post(
//           Uri.parse(apiUrl),
//           headers: headers,
//           body: jsonEncode(requestBody),
//         );

//         if (response.statusCode == 200) {
//           final Map<String, dynamic> responseData = jsonDecode(response.body);
//           if (responseData.containsKey('response') &&
//               responseData['response'].containsKey('objectSchedule')) {
//             results.addAll(
//               List<Map<String, dynamic>>.from(
//                 responseData['response']['objectSchedule'],
//               ),
//             );
//           } else {
//             // Обработка случая, когда данные не найдены
//             print('Data not found in the response.');
//           }
//         } else {
//           print('Request failed with status: ${response.statusCode}.');
//         }
//       }
//     } catch (e) {
//       print('Error: $e');
//     }

//     return results;
//   }
// }
import 'package:dio/dio.dart';


class ApiService {
  static const String apiUrl = 'https://lsport.net/api/read';

  static const Map<String, String> headers = {
    'user': 'OTgyNjE0OTQyMw==',
    'password': 'MTIzNDU2',
    'Content-Type': 'application/json',
    'Cookie':
        'ASP.NET_SessionId=ktmnnbp21gpfpihstua0t2g3; ASP.NET_SessionId=0usqght14rslvdkfbjqy4lb5; locationCity=; locationCity='
  };

  static Future<List<String>> fetchScheduleGuidObjectList() async {
    try {
      final response = await Dio().post(
        'https://lsport.net/Facility/Displaysettings/1e4ccab0-bb68-48ea-a0b2-315488713f41',
        options: Options(headers: headers),
        data: {},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData.containsKey('scheduleGuidObjectList')) {
          final List<dynamic> scheduleGuidList =
              responseData['scheduleGuidObjectList'];
          final List<String> scheduleGuidObjectList =
              scheduleGuidList.map((item) => item.toString()).toList();
          return scheduleGuidObjectList;
        } else {
          print('scheduleGuidObjectList not found in the response.');
          return [];
        }
      } else {
        print('Request failed with status: ${response.statusCode}.');
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> fetchData() async {
    final List<String> scheduleGuidObjectList =
        await fetchScheduleGuidObjectList();

    List<Map<String, dynamic>> results = [];
    try {
      for (var scheduleGuid in scheduleGuidObjectList) {
        final Map<String, dynamic> requestBody = {
          "type": ["objectSchedule"],
          "id": scheduleGuid,
          "start": "01.05.2023",
          "end": "20.08.2023",
        };

        final response = await Dio().post(
          apiUrl,
          options: Options(headers: headers),
          data: requestBody,
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = response.data;
          if (responseData.containsKey('response') &&
              responseData['response'].containsKey('objectSchedule')) {
            results.addAll(
              List<Map<String, dynamic>>.from(
                responseData['response']['objectSchedule'],
              ),
            );
          } else {
            // Обработка случая, когда данные не найдены
            print('Data not found in the response.');
          }
        } else {
          print('Request failed with status: ${response.statusCode}.');
        }
      }
    } catch (e) {
      print('Error: $e');
    }

    return results;
  }
  static Future<List<Map<String, dynamic>>> fetchDataForId(String type, String id) async {
    final Map<String, dynamic> requestBody = {
      "type": [type],
      "id": id,
      "start": "01.05.2023",
      "end": "20.08.2023",
    };

    try {
      final response = await Dio().post(
        apiUrl,
        options: Options(headers: headers),
        data: requestBody,
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData.containsKey('response') &&
            responseData['response'].containsKey('objectSchedule')) {
          return List<Map<String, dynamic>>.from(
            responseData['response']['objectSchedule'],
          );
        } 
        
        
        
        else {
          print('Data not found in the response for id $id.');
        }
      } else {
        print('Request failed with status: ${response.statusCode} for id $id.');
      }
    } catch (e) {
      print('Error: $e for id $id');
    }

    return [];
  }
  

  static Future<String> fetchObjectName(String type, String id) async {
      final Map<String, dynamic> requestBody = {
      "type": [type],
      "id": id,
      "start": "01.05.2023",
      "end": "20.08.2023",
    };

    try {
      final response = await Dio().post(
        apiUrl,
        options: Options(headers: headers),
        data: requestBody,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData.containsKey('response') &&
            responseData['response'].containsKey('object')) {
          final Map<String, dynamic> objectData = responseData['response']['object'];
          final String name = objectData['Name'];
          return name;
        } else {
          print('Object data not found in the response.');
          return '';
        }
      } else {
        print('Request failed with status: ${response.statusCode}.');
        return '';
      }
    } catch (e) {
      print('Error: $e');
      return '';
    }
  }


}
