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
      backgroundColor: Colors.grey[100], // Cleaner background
      body: Column(
        children: [
          // ==============================
          // 1. MODERN HEADER & LANGUAGES
          // ==============================
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // Blue Curved Background
              Container(
                height: 220,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3949AB), Color(0xFF5C6BC0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Voice to voice Translator",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SettingsScreen()),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
              
              // Floating Language Selectors
              Positioned(
                bottom: -30,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLangSelector(context, viewModel.sourceLanguage, viewModel.languages, viewModel.setSourceLanguage),
                      
                      // Swap Button
                      IconButton(
                        icon: const Icon(Icons.swap_horiz, color: Color(0xFF3949AB)),
                        onPressed: viewModel.swapLanguages,
                      ),
                      
                      _buildLangSelector(context, viewModel.targetLanguage, viewModel.languages, viewModel.setTargetLanguage),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 50), // Spacing for floating card

          // ==============================
          // 2. DYNAMIC CONTENT AREA
          // ==============================
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildMainContent(viewModel),
              ),
            ),
          ),

          // ==============================
          // 3. MIC BUTTON AREA
          // ==============================
          Container(
            padding: const EdgeInsets.only(bottom: 30, top: 20),
            child: Column(
              children: [
                Text(
                  viewModel.isRecording ? "Listening..." : "Hold to Speak",
                  style: TextStyle(
                    color: viewModel.isRecording ? Colors.redAccent : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 15),
                RippleAnimation(
                  isRecording: viewModel.isRecording,
                  color: Colors.redAccent.withOpacity(0.5),
                  child: GestureDetector(
                    onLongPressStart: (_) => viewModel.startRecording(),
                    onLongPressEnd: (_) => viewModel.stopRecording(),
                    child: Container(
                      height: 75,
                      width: 75,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: viewModel.isRecording 
                            ? [Colors.redAccent, Colors.red] 
                            : [const Color(0xFF3949AB), const Color(0xFF5C6BC0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (viewModel.isRecording ? Colors.red : const Color(0xFF3949AB)).withOpacity(0.4),
                            blurRadius: 15,
                            spreadRadius: 5,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Icon(
                        viewModel.isRecording ? Icons.mic : Icons.mic_none,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildMainContent(HomeViewModel viewModel) {
    if (viewModel.errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.redAccent),
            const SizedBox(height: 10),
            Text(
              viewModel.errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (viewModel.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFF3949AB)),
            const SizedBox(height: 20),
            Text(
              "Translating...",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (viewModel.translationData != null) {
      return ListView(
        children: [
          // User Bubble
          _buildChatBubble(
            text: viewModel.translationData!.originalText,
            lang: viewModel.sourceLanguage,
            isMe: true,
          ),
          const SizedBox(height: 20),
          // Translation Bubble
          _buildChatBubble(
            text: viewModel.translationData!.translatedText,
            lang: viewModel.targetLanguage,
            isMe: false,
            onPlay: viewModel.playTranslatedAudio,
          ),
        ],
      );
    }

    // Default Empty State
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: 0.2,
            child: Image.asset('assets/voice_icon.png', height: 100, errorBuilder: (_,__,___) => const Icon(Icons.graphic_eq, size: 100, color: Colors.grey)),
          ),
          const SizedBox(height: 20),
          Text(
            "Select languages and\nhold the mic to start",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble({required String text, required String lang, required bool isMe, VoidCallback? onPlay}) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(lang, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 5),
          Container(
            constraints: const BoxConstraints(maxWidth: 280),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFFE8EAF6) : Colors.white, // Grey for user, White for result
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(0),
                bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
              ],
              border: isMe ? null : Border.all(color: const Color(0xFF3949AB).withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    fontWeight: isMe ? FontWeight.normal : FontWeight.w500,
                  ),
                ),
                if (!isMe && onPlay != null) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: InkWell(
                      onTap: onPlay,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3949AB).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.volume_up, color: Color(0xFF3949AB), size: 20),
                      ),
                    ),
                  )
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLangSelector(BuildContext context, String current, List<String> items, Function(String?) onChange) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: current,
        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF3949AB)),
        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 15),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChange,
      ),
    );
  }
}