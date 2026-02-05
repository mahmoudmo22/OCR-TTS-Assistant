import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../providers/app_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Language',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            key: ValueKey(provider.language),
            initialValue: provider.language,
            items: AppConfig.supportedLanguages
                .map(
                  (lang) => DropdownMenuItem(
                    value: lang,
                    child: Text(lang),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                provider.updateLanguage(value);
              }
            },
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 24),
          Text(
            'Speech rate: ${provider.speechRate.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Slider(
            min: 0.2,
            max: 1.0,
            value: provider.speechRate,
            onChanged: (value) => provider.updateSpeechRate(value),
          ),
          const SizedBox(height: 16),
          Text(
            'Pitch: ${provider.pitch.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Slider(
            min: 0.5,
            max: 2.0,
            value: provider.pitch,
            onChanged: (value) => provider.updatePitch(value),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => provider.speak('This is a test of the voice.'),
            icon: const Icon(Icons.record_voice_over),
            label: const Text('Test Voice'),
          ),
        ],
      ),
    );
  }
}
