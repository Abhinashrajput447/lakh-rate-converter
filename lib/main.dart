import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const LakhRateConverterApp());
}

/// Lakh Rate Converter (Android-first)
///
/// Elder-friendly UI:
/// - Very large text
/// - Big buttons
/// - High contrast
/// - Simple layout (no clutter)
///
/// Logic:
/// rupees = (coins * rate) / 100000
class LakhRateConverterApp extends StatelessWidget {
  const LakhRateConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Clean, high-contrast theme.
    final theme = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.green,
        brightness: Brightness.light,
      ).copyWith(
        surface: Colors.white,
        onSurface: Colors.black,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: Colors.black,
        ),
        bodyLarge: TextStyle(fontSize: 22, color: Colors.black),
        bodyMedium: TextStyle(fontSize: 20, color: Colors.black),
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        labelStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        hintStyle: const TextStyle(fontSize: 20),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lakh Rate Converter',
      theme: theme,
      home: const ConverterScreen(),
    );
  }
}

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  // Controllers as requested.
  final TextEditingController _coinsController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();

  String? _errorMessage;
  double? _exactValue;
  int? _roundedValue;

  @override
  void dispose() {
    _coinsController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _clear() {
    HapticFeedback.lightImpact();
    setState(() {
      _coinsController.clear();
      _rateController.clear();
      _errorMessage = null;
      _exactValue = null;
      _roundedValue = null;
    });
  }

  void _calculate() {
    HapticFeedback.mediumImpact();
    FocusScope.of(context).unfocus(); // Hide keyboard for simplicity.

    final coinsText = _coinsController.text.trim();
    final rateText = _rateController.text.trim();

    // Basic safe validation.
    if (coinsText.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter coins (कृपया coins डालें)';
        _exactValue = null;
        _roundedValue = null;
      });
      return;
    }

    if (rateText.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter rate per 1 lakh (कृपया rate डालें)';
        _exactValue = null;
        _roundedValue = null;
      });
      return;
    }

    final coins = int.tryParse(coinsText);
    final rate = double.tryParse(rateText);

    if (coins == null || coins < 0) {
      setState(() {
        _errorMessage = 'Coins must be a valid number';
        _exactValue = null;
        _roundedValue = null;
      });
      return;
    }

    if (rate == null || rate < 0) {
      setState(() {
        _errorMessage = 'Rate must be a valid number';
        _exactValue = null;
        _roundedValue = null;
      });
      return;
    }

    // Core logic: rupees = (coins * rate) / 100000
    final exact = (coins * rate) / 100000.0;
    final rounded = exact.round();

    setState(() {
      _errorMessage = null;
      _exactValue = exact;
      _roundedValue = rounded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Lakh Rate Converter',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInputField(
                    controller: _coinsController,
                    label: 'Enter Coins',
                    hint: 'Example: 101000',
                    // Coins should be integers only.
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),
                  _buildInputField(
                    controller: _rateController,
                    label: 'Rate per 1 Lakh',
                    hint: 'Example: 975',
                    // Rate can be decimal.
                    inputFormatters: const [DecimalTextInputFormatter()],
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 14),

                  if (_errorMessage != null) ...[
                    _buildErrorBox(_errorMessage!),
                    const SizedBox(height: 14),
                  ],

                  _buildBigButton(
                    text: 'Calculate',
                    background: Colors.green,
                    foreground: Colors.white,
                    onPressed: _calculate,
                  ),
                  const SizedBox(height: 12),
                  _buildBigButton(
                    text: 'Clear',
                    background: Colors.red,
                    foreground: Colors.white,
                    onPressed: _clear,
                  ),

                  const SizedBox(height: 18),
                  _buildResultSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required List<TextInputFormatter> inputFormatters,
    required TextInputType keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
    );
  }

  Widget _buildBigButton({
    required String text,
    required Color background,
    required Color foreground,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 72,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          textStyle: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(text),
      ),
    );
  }

  Widget _buildResultSection() {
    // Show placeholders when nothing is calculated yet.
    final exactText = _exactValue == null ? '—' : '₹${_exactValue!.toStringAsFixed(2)}';
    final roundedText = _roundedValue == null ? '—' : '≈ ₹${_roundedValue!.toString()}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Result',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Text(
            exactText,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            roundedText,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBox(String message) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.red),
      ),
    );
  }
}

/// Allows only digits and a single dot for decimals.
///
/// This prevents input like "12..3" or "..".
class DecimalTextInputFormatter extends TextInputFormatter {
  const DecimalTextInputFormatter();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;

    // Allow empty.
    if (text.isEmpty) return newValue;

    // Only digits and dot.
    if (!RegExp(r'^[0-9.]+$').hasMatch(text)) {
      return oldValue;
    }

    // Only one dot.
    final dotCount = '.'.allMatches(text).length;
    if (dotCount > 1) {
      return oldValue;
    }

    // Avoid just a dot.
    if (text == '.') {
      return oldValue;
    }

    return newValue;
  }
}
