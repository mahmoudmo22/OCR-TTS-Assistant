import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../providers/app_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _serverController;
  String? _serverError;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AppProvider>();
    _serverController = TextEditingController(text: provider.easyOcrBaseUrl);
  }

  @override
  void dispose() {
    _serverController.dispose();
    super.dispose();
  }

  Future<void> _saveServerUrl(AppProvider provider) async {
    final value = _serverController.text.trim();
    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      setState(() {
        _serverError = 'Server URL must start with http:// or https://';
      });
      return;
    }

    setState(() {
      _serverError = null;
    });
    await provider.updateEasyOcrBaseUrl(value);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'EasyOCR Server URL',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _serverController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: 'http://192.168.1.25:8000',
              errorText: _serverError,
            ),
            keyboardType: TextInputType.url,
            onSubmitted: (_) => _saveServerUrl(provider),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _saveServerUrl(provider),
            icon: const Icon(Icons.save),
            label: const Text('Save Server URL'),
          ),
          const SizedBox(height: 24),
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
            onPressed: provider.isTtsReady
                ? () => provider.speak('This is a test of the voice.')
                : null,
            icon: const Icon(Icons.record_voice_over),
            label: const Text('Test Voice'),
          ),
        ],
      ),
    );
  }
}
