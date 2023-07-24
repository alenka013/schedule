import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String apiUrl = 'https://lsport.net/api/read'; 

  static const Map<String, String> headers = {
    'user': 'OTgyNjE0OTQyMw==',
    'password': 'MTIzNDU2',
    'Content-Type': 'application/json',
    'Cookie': 'ASP.NET_SessionId=ktmnnbp21gpfpihstua0t2g3; ASP.NET_SessionId=0usqght14rslvdkfbjqy4lb5; locationCity=; locationCity='
  };

  static Future<List<Map<String, dynamic>>> fetchData() async {
    final Map<String, dynamic> requestBody = {
//  "type": [ "objectSchedule" ],
//     "id": "501a7928-fc5a-494c-b820-7d8d28f10f35",
//     "start": "01.05.2023",
//     "end": "20.08.2023"
      "type": ["objectSchedule"],
      "id": "794785bb-87d0-4199-8f54-02c4c1a412ed",
      "start": "27.07.2023",
      "end": "20.08.2023"
    };

     try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData.containsKey('response') &&
          responseData['response'].containsKey('objectSchedule')) {
        return List<Map<String, dynamic>>.from(
          responseData['response']['objectSchedule'],
        );
      } else {
        // Обработка случая, когда данные не найдены
        print('Data not found in the response.');
      }
    } else {
      
      print('Request failed with status: ${response.statusCode}.');
    }
  } catch (e) {
    
    print('Error: $e');
  }

  return []; // Возвращаем пустой список, если данные не были успешно получены
}}