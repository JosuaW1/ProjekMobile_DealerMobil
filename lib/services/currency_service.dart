class CurrencyService {
  // Fixed exchange rates (dalam praktik nyata, ini harus dari API)
  static const Map<String, double> exchangeRates = {
    'IDR': 1.0,
    'USD': 0.000067, // 1 IDR = 0.000067 USD
    'EUR': 0.000061, // 1 IDR = 0.000061 EUR
  };

  static double parseIndonesianPrice(String priceString) {
    // Parse harga dalam format Indonesia (misal: "800 juta", "1.2 miliar")
    String cleanPrice = priceString.toLowerCase().replaceAll('.', '').trim();

    double multiplier = 1;
    double baseValue = 0;

    if (cleanPrice.contains('miliar')) {
      multiplier = 1000000000; // 1 miliar
      String numberPart = cleanPrice.replaceAll('miliar', '').trim();
      baseValue = double.tryParse(numberPart) ?? 0;
    } else if (cleanPrice.contains('juta')) {
      multiplier = 1000000; // 1 juta
      String numberPart = cleanPrice.replaceAll('juta', '').trim();
      baseValue = double.tryParse(numberPart) ?? 0;
    } else if (cleanPrice.contains('ribu')) {
      multiplier = 1000; // 1 ribu
      String numberPart = cleanPrice.replaceAll('ribu', '').trim();
      baseValue = double.tryParse(numberPart) ?? 0;
    } else {
      // Jika tidak ada satuan, anggap sebagai angka biasa
      baseValue = double.tryParse(cleanPrice) ?? 0;
    }

    return baseValue * multiplier;
  }

  static double convertCurrency(double amountInIDR, String targetCurrency) {
    if (!exchangeRates.containsKey(targetCurrency)) {
      return amountInIDR;
    }
    return amountInIDR * exchangeRates[targetCurrency]!;
  }

  static String formatCurrency(double amount, String currency) {
    switch (currency) {
      case 'IDR':
        return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]}.',
            )}';
      case 'USD':
        return '\$${amount.toStringAsFixed(2)}';
      case 'EUR':
        return '€${amount.toStringAsFixed(2)}';
      default:
        return amount.toStringAsFixed(2);
    }
  }

  static List<String> getSupportedCurrencies() {
    return ['IDR', 'USD', 'EUR'];
  }
}
