import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_viewmodel.dart';
import 'settings_screen.dart';
import '../widgets/ripple_animation.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Translator"),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // --- Language Selectors ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDropdown(
                  value: viewModel.sourceLanguage,
                  items: viewModel.languages,
                  onChanged: viewModel.setSourceLanguage,
                  label: "From",
                ),
                const Icon(Icons.arrow_forward, color: Colors.grey),
                _buildDropdown(
                  value: viewModel.targetLanguage,
                  items: viewModel.languages,
                  onChanged: viewModel.setTargetLanguage,
                  label: "To",
                ),
              ],
            ),

            const SizedBox(height: 30),

            // --- Results Area ---
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (viewModel.errorMessage.isNotEmpty)
                      Text(
                        viewModel.errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),

                    if (viewModel.isLoading)
                      const Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 10),
                          Text(
                            "Translating...",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      )
                    else if (viewModel.translationData != null) ...[
                      _buildResultCard(
                        title: "You said (${viewModel.sourceLanguage})",
                        content: viewModel.translationData!.originalText,
                        color: Colors.grey.shade200,
                      ),
                      const SizedBox(height: 10),
                      _buildResultCard(
                        title: "Translation (${viewModel.targetLanguage})",
                        content: viewModel.translationData!.translatedText,
                        color: Colors.indigo.shade50,
                        isTarget: true,
                        onPlay: viewModel.playTranslatedAudio,
                      ),
                    ] else
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.mic_external_on,
                              size: 60,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Hold the mic to speak",
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // --- Animated Mic Button ---
            const SizedBox(height: 20),

            // 1. Wrap the button in the Animation Widget
            RippleAnimation(
              isRecording: viewModel.isRecording,
              color: Colors.red.withOpacity(0.5), // Color of the waves
              child: GestureDetector(
                onLongPressStart: (_) => viewModel.startRecording(),
                onLongPressEnd: (_) => viewModel.stopRecording(),
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: viewModel.isRecording ? Colors.red : Colors.indigo,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (viewModel.isRecording ? Colors.red : Colors.indigo)
                                .withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    viewModel.isRecording ? Icons.mic : Icons.mic_none,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),
            Text(
              viewModel.isRecording ? "Listening..." : "Hold to Record",
              style: TextStyle(
                color: viewModel.isRecording ? Colors.red : Colors.grey,
                fontWeight: viewModel.isRecording
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.arrow_drop_down),
          underline: Container(height: 2, color: Colors.indigo),
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildResultCard({
    required String title,
    required String content,
    required Color color,
    bool isTarget = false,
    VoidCallback? onPlay,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              if (isTarget)
                IconButton(
                  icon: const Icon(Icons.volume_up, color: Colors.indigo),
                  onPressed: onPlay,
                ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            content,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
