import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/translation_model.dart';

class ApiService {
  // Default fallback values
  static const String _defaultIp = "192.168.1.5";
  static const String _defaultPort = "5000";

  /// Reads IP and Port from storage and constructs the URL
  Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString('api_ip') ?? _defaultIp;
    final port = prefs.getString('api_port') ?? _defaultPort;
    return "http://$ip:$port";
  }

  /// Saves new IP and Port to storage
  Future<void> saveSettings(String ip, String port) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_ip', ip);
    await prefs.setString('api_port', port);
  }

  Future<TranslationModel?> translateAudio(
    File audioFile,
    String sourceLang,
    String targetLang,
  ) async {
    try {
      // 1. Get the dynamic URL
      String baseUrl = await getBaseUrl();
      var uri = Uri.parse('$baseUrl/translate_voice');

      print("Connecting to: $uri"); // Debugging

      var request = http.MultipartRequest('POST', uri);
      request.fields['source_lang'] = sourceLang;
      request.fields['target_lang'] = targetLang;

      request.files.add(
        await http.MultipartFile.fromPath('audio', audioFile.path),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        return TranslationModel.fromJson(jsonResponse);
      } else {
        print("Server Error: ${response.body}");
        return null;
      }
    } catch (e) {
      print("API Exception: $e");
      return null;
    }
  }

  // Now returns a Future because it needs to read preferences
  Future<String> getAudioUrl(String filename) async {
    String baseUrl = await getBaseUrl();
    return "$baseUrl/get_audio/$filename";
  }
}
