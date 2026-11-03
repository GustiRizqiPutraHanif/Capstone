import '../models/finance_setup.dart';

class SavedFinance {
  const SavedFinance({required this.setup, required this.sekunderPercent});

  final FinanceSetup setup;

  /// Persen sisa uang untuk Sekunder; Tersier = 100 - nilai ini.
  final int sekunderPercent;
}

/// Data keuangan DUMMY (di memori), satu per akun. Nanti diganti API.
class FinanceRepository {
  FinanceRepository._() {
    reset();
  }

  static final FinanceRepository instance = FinanceRepository._();

  final Map<String, SavedFinance> _byEmail = {};

  /// Mengosongkan data lalu mengisi data akun lama (Budi) dari Excel.
  void reset() {
    _byEmail
      ..clear()
      ..['budi.santoso@example.com'] = const SavedFinance(
        setup: FinanceSetup(
          gaji: 8000000,
          kebutuhan: 4000000,
          cicilan: 1500000,
          tabungan: 1000000,
        ),
        sekunderPercent: 70,
      );
  }

  void save({
    required String email,
    required FinanceSetup setup,
    required int sekunderPercent,
  }) {
    _byEmail[email] = SavedFinance(
      setup: setup,
      sekunderPercent: sekunderPercent,
    );
  }

  SavedFinance? of(String email) => _byEmail[email];
}
