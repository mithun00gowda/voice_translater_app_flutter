class TranslationModel {
  final String originalText;
  final String translatedText;
  final String audioFileName;

  TranslationModel({
    required this.originalText,
    required this.translatedText,
    required this.audioFileName,
  });

  factory TranslationModel.fromJson(Map<String, dynamic> json) {
    return TranslationModel(
      originalText: json['original_text'] ?? '',
      translatedText: json['translated_text'] ?? '',
      audioFileName: json['audio_file'] ?? '',
    );
  }
}