import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/translation_model.dart';
import '../services/api_service.dart';

class HomeViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isRecording = false;
  bool _isLoading = false;
  TranslationModel? _translationData;
  String _errorMessage = '';
  
  String sourceLanguage = 'English';
  String targetLanguage = 'Kannada';
  
  final List<String> languages = [
    'English', 'Hindi', 'Kannada', 'Tamil', 'Telugu', 'Malayalam'
  ];

  bool get isRecording => _isRecording;
  bool get isLoading => _isLoading;
  TranslationModel? get translationData => _translationData;
  String get errorMessage => _errorMessage;

  // === NEW: Clears old data automatically ===
  void clearData() {
    _translationData = null;
    _errorMessage = '';
    notifyListeners();
  }

  Future<void> startRecording() async {
    // 1. AUTO REFRESH: Clear previous results immediately
    clearData();

    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      _errorMessage = "Microphone permission needed";
      notifyListeners();
      return;
    }

    Directory tempDir = await getTemporaryDirectory();
    String path = '${tempDir.path}/audio_input.m4a';

    try {
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start(const RecordConfig(), path: path);
        _isRecording = true;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Could not start recording: $e";
      notifyListeners();
    }
  }

  Future<void> stopRecording() async {
    // Stop recorder
    final path = await _audioRecorder.stop();
    _isRecording = false;
    notifyListeners();

    if (path != null) {
      File audioFile = File(path);
      _uploadAndTranslate(audioFile);
    }
  }

  Future<void> _uploadAndTranslate(File audioFile) async {
    _isLoading = true;
    notifyListeners();

    _translationData = await _apiService.translateAudio(
      audioFile, 
      sourceLanguage, 
      targetLanguage
    );

    _isLoading = false;

    if (_translationData != null) {
      playTranslatedAudio();
    } else {
      _errorMessage = "Translation failed. Check settings/server.";
    }
    notifyListeners();
  }

  Future<void> playTranslatedAudio() async {
    if (_translationData != null && _translationData!.audioFileName.isNotEmpty) {
      String url = await _apiService.getAudioUrl(_translationData!.audioFileName);
      await _audioPlayer.play(UrlSource(url));
    }
  }
  
  void setSourceLanguage(String? lang) {
    if (lang != null) {
      sourceLanguage = lang;
      notifyListeners();
    }
  }

  void setTargetLanguage(String? lang) {
    if (lang != null) {
      targetLanguage = lang;
      notifyListeners();
    }
  }
  
  // Swap languages for convenience
  void swapLanguages() {
    String temp = sourceLanguage;
    sourceLanguage = targetLanguage;
    targetLanguage = temp;
    clearData(); // Clear data on swap
    notifyListeners();
  }
}