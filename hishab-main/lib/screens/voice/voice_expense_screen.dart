import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import '../../providers/finance_provider.dart';
import '../../models/expense.dart';
import '../../services/voice_parser_service.dart';
import '../../localization/app_localizations.dart';

class VoiceExpenseScreen extends StatefulWidget {
  const VoiceExpenseScreen({super.key});

  @override
  State<VoiceExpenseScreen> createState() => _VoiceExpenseScreenState();
}

class _VoiceExpenseScreenState extends State<VoiceExpenseScreen> with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _transcribedText = '';
  ParsedExpense? _parsedExpense;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _initSpeech();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    // Request microphone permission
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      await _speech.initialize(
        onError: (error) => setState(() => _isListening = false),
        onStatus: (status) {
          if (status == 'done') {
            setState(() => _isListening = false);
          }
        },
      );
    }
  }

  void _startListening() async {
    if (!_speech.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate('microphoneNotAvailable')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isListening = true;
      _transcribedText = '';
      _parsedExpense = null;
    });

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _transcribedText = result.recognizedWords;
          _parseInput();
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
    );
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  void _parseInput() {
    if (_transcribedText.isEmpty) {
      setState(() => _parsedExpense = null);
      return;
    }

    final provider = context.read<FinanceProvider>();
    final categories = provider.categories.map((c) => c.name).toList();

    setState(() {
      _parsedExpense = VoiceParserService.parseVoiceInput(_transcribedText, categories);
    });
  }

  Future<void> _saveExpense() async {
    if (_parsedExpense == null) return;

    final loc = AppLocalizations.of(context);

    if (_parsedExpense!.category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate('pleaseSelectCategory')),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final expense = Expense(
      amount: _parsedExpense!.amount,
      category: _parsedExpense!.category!,
      note: _parsedExpense!.note,
      date: DateTime.now(),
      timestamp: DateTime.now(),
    );

    await context.read<FinanceProvider>().addExpense(expense);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate('expenseSaved')),
          backgroundColor: const Color(0xFF4ECDC4),
        ),
      );

      // Reset
      setState(() {
        _transcribedText = '';
        _parsedExpense = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = Provider.of<FinanceProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          loc.translate('voiceExpense'),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Microphone button
                    GestureDetector(
                      onTap: _isListening ? _stopListening : _startListening,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _isListening
                                ? [const Color(0xFFF16725), const Color(0xFFFF8C42)]
                                : [const Color(0xFF4ECDC4), const Color(0xFF45B7D1)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (_isListening ? const Color(0xFFF16725) : const Color(0xFF4ECDC4)).withOpacity(0.4),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: _isListening
                            ? AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3 + (_animationController.value * 0.3)),
                                        width: 3,
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.mic,
                                        size: 80,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : const Center(
                                child: Icon(Icons.mic, size: 80, color: Colors.white),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _isListening
                          ? loc.translate('listening')
                          : loc.translate('tapToSpeak'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.translate('voiceInstructions'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Transcribed text
                    if (_transcribedText.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF4ECDC4).withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.hearing, color: Color(0xFF4ECDC4), size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  loc.translate('heard'),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF4ECDC4),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _transcribedText,
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Parsed expense details
                    if (_parsedExpense != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFFF16725).withOpacity(0.1),
                              const Color(0xFFF16725).withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFF16725).withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.check_circle, color: Color(0xFFF16725), size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  loc.translate('understood'),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFF16725),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow(loc.translate('amount'), '৳${NumberFormat('#,##0.00').format(_parsedExpense!.amount)}'),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              loc.translate('category'),
                              _parsedExpense!.category != null
                                  ? loc.translateCategory(_parsedExpense!.category!)
                                  : loc.translate('notDetected'),
                            ),
                            if (_parsedExpense!.note.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _buildDetailRow(loc.translate('note'), _parsedExpense!.note),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Category selector if not detected
                      if (_parsedExpense!.category == null) ...[
                        Text(
                          loc.translate('selectCategory'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: provider.categories.map((category) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _parsedExpense = ParsedExpense(
                                    amount: _parsedExpense!.amount,
                                    category: category.name,
                                    note: _parsedExpense!.note,
                                  );
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: category.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: category.color, width: 1),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(category.icon, color: category.color, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      loc.translateCategory(category.name),
                                      style: TextStyle(
                                        color: category.color,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),

            // Save button
            if (_parsedExpense != null && _parsedExpense!.category != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: ElevatedButton(
                  onPressed: _saveExpense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF16725),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    loc.translate('saveExpense'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
