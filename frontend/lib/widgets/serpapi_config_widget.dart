import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SerpApiConfigWidget extends StatefulWidget {
  final ApiService apiService;
  
  const SerpApiConfigWidget({super.key, required this.apiService});

  @override
  State<SerpApiConfigWidget> createState() => _SerpApiConfigWidgetState();
}

class _SerpApiConfigWidgetState extends State<SerpApiConfigWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = true;
  bool _isObscure = true;
  String _status = "Not Configured";
  String _errorMsg = "";

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  Future<void> _checkStatus() async {
    try {
      final res = await widget.apiService.getSerpApiStatus();
      if (mounted) {
        setState(() {
          _status = res['status'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = "Error";
          _errorMsg = "Failed to connect to backend.";
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _saveKey() async {
    final key = _controller.text.trim();
    if (key.isEmpty) return;
    
    setState(() {
      _status = "Connecting";
      _errorMsg = "";
    });
    
    try {
      await widget.apiService.saveSerpApiKey(key);
      if (mounted) {
        setState(() {
          _status = "Connected";
          _controller.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = "Error";
          _errorMsg = e.toString().replaceAll("Exception: ", "");
        });
      }
    }
  }
  
  Future<void> _clearKey() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await widget.apiService.clearSerpApiKey();
      if (mounted) {
        setState(() {
          _status = "Not Configured";
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        width: 100,
        height: 36,
        child: Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4F46E5)))),
      );
    }
    
    if (_status == "Connected") {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8)
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 14),
                SizedBox(width: 6),
                Text("SerpApi Connected", style: TextStyle(color: Color(0xFF22C55E), fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            )
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: _clearKey,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
            ),
            child: const Text("Clear", style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 12)),
          )
        ],
      );
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_status == "Error" && _errorMsg.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Tooltip(
              message: _errorMsg,
              child: const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
            ),
          ),
        SizedBox(
          width: 180,
          height: 36,
          child: TextField(
            controller: _controller,
            obscureText: _isObscure,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Enter SerpApi Key',
              hintStyle: const TextStyle(color: Color(0xFFA1A1AA)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF4F46E5)),
              ),
              suffixIcon: IconButton(
                icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility, color: const Color(0xFFA1A1AA), size: 16),
                onPressed: () => setState(() => _isObscure = !_isObscure),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _status == "Connecting" ? null : _saveKey,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2A2A2A),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _status == "Connecting"
              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text("Connect", style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
}
