class VoiceParserService {
  // Parse voice input like "200 for books", "groceries 500", "rent 8000"
  static ParsedExpense? parseVoiceInput(String input, List<String> availableCategories) {
    if (input.trim().isEmpty) return null;

    // Convert to lowercase for easier parsing
    final text = input.toLowerCase().trim();

    // Extract amount (look for numbers)
    final RegExp numberRegex = RegExp(r'\d+(?:\.\d+)?');
    final numberMatch = numberRegex.firstMatch(text);

    if (numberMatch == null) return null;

    final amount = double.tryParse(numberMatch.group(0)!);
    if (amount == null || amount <= 0) return null;

    // Try to extract category
    String? category = _extractCategory(text, availableCategories);

    // Extract optional note
    String note = _extractNote(text, numberMatch.group(0)!, category);

    return ParsedExpense(
      amount: amount,
      category: category,
      note: note,
    );
  }

  static String? _extractCategory(String text, List<String> availableCategories) {
    // Remove common filler words
    final cleanText = text
        .replaceAll(RegExp(r'\d+(?:\.\d+)?'), '') // Remove numbers
        .replaceAll(RegExp(r'\b(for|to|on|of|taka|tk|৳)\b'), '') // Remove common words
        .trim();

    // Check if any available category matches (case-insensitive)
    for (var category in availableCategories) {
      if (cleanText.contains(category.toLowerCase())) {
        return category;
      }
    }

    // Try to match common keywords to categories
    final categoryKeywords = {
      'Food': ['food', 'lunch', 'dinner', 'breakfast', 'meal', 'restaurant', 'groceries', 'grocery', 'snack', 'coffee', 'tea', 'khawa', 'khabar'],
      'Transport': ['transport', 'taxi', 'uber', 'bus', 'rickshaw', 'cng', 'fuel', 'petrol', 'ride', 'travel'],
      'Shopping': ['shopping', 'shop', 'clothes', 'dress', 'shirt', 'shoes', 'buy', 'purchase', 'market'],
      'Bills': ['bill', 'bills', 'electricity', 'water', 'gas', 'internet', 'phone', 'rent', 'utility'],
      'Entertainment': ['movie', 'cinema', 'game', 'entertainment', 'concert', 'party', 'fun'],
      'Health': ['medicine', 'doctor', 'hospital', 'health', 'pharmacy', 'medical', 'clinic'],
      'Other': ['other', 'misc', 'miscellaneous'],
    };

    for (var entry in categoryKeywords.entries) {
      for (var keyword in entry.value) {
        if (cleanText.contains(keyword)) {
          // Check if this category exists in available categories
          if (availableCategories.contains(entry.key)) {
            return entry.key;
          }
        }
      }
    }

    return null;
  }

  static String _extractNote(String text, String amount, String? category) {
    String note = text;

    // Remove the amount
    note = note.replaceAll(amount, '').trim();

    // Remove category if found
    if (category != null) {
      note = note.replaceAll(category.toLowerCase(), '').trim();
    }

    // Remove common filler words
    note = note
        .replaceAll(RegExp(r'\b(for|to|on|of|taka|tk|৳)\b'), '')
        .trim();

    // If note is too short or empty, return empty string
    if (note.length < 3) return '';

    return note;
  }
}

class ParsedExpense {
  final double amount;
  final String? category;
  final String note;

  ParsedExpense({
    required this.amount,
    this.category,
    this.note = '',
  });
}
