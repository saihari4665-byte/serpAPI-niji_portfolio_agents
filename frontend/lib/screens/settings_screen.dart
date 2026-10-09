import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _aiProvider = 'Ollama';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Settings', style: TextStyle(fontFamily: 'Inter', color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Provider Selection
            const Text(
              'AI Provider Selection',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Ollama [LOCAL & PRIVATE]', style: TextStyle(color: Colors.white, fontFamily: 'Inter')),
                    value: 'Ollama',
                    groupValue: _aiProvider,
                    activeColor: Colors.blue,
                    onChanged: (val) => setState(() => _aiProvider = val!),
                  ),
                  RadioListTile<String>(
                    title: const Text('Gemini [CLOUD]', style: TextStyle(color: Colors.white, fontFamily: 'Inter')),
                    value: 'Gemini',
                    groupValue: _aiProvider,
                    activeColor: Colors.blue,
                    onChanged: (val) => setState(() => _aiProvider = val!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Gemini Cloud AI Card
            if (_aiProvider == 'Gemini')
              _buildCard(
                'Gemini Cloud AI',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        border: Border.all(color: Colors.orange),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Privacy Warning: Data will be sent to Google Cloud.',
                              style: TextStyle(color: Colors.orange, fontSize: 12, fontFamily: 'Inter'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField('API Key', obscureText: true),
                    const SizedBox(height: 12),
                    _buildDropdown('Model', ['gemini-1.5-pro', 'gemini-1.5-flash']),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      onPressed: () {},
                      child: const Text('Test Connection', style: TextStyle(color: Colors.white, fontFamily: 'Inter')),
                    )
                  ],
                ),
              ),
            if (_aiProvider == 'Gemini') const SizedBox(height: 24),

            // Search Provider Card
            _buildCard(
              'Search Provider (SerpApi)',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField('SerpApi Key', obscureText: true),
                  const SizedBox(height: 12),
                  _buildDropdown('Engine', ['Google News', 'Google Search']),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () {},
                    child: const Text('Test Connection', style: TextStyle(color: Colors.white, fontFamily: 'Inter')),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField(String label, {bool obscureText = false}) {
    return TextField(
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontFamily: 'Inter'),
        filled: true,
        fillColor: const Color(0xFF121212),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontFamily: 'Inter'),
        filled: true,
        fillColor: const Color(0xFF121212),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
      ),
      dropdownColor: const Color(0xFF1E1E1E),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white, fontFamily: 'Inter')))).toList(),
      onChanged: (val) {},
    );
  }
}
