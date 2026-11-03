import '../models/transaction.dart';

/// Data transaksi DUMMY (di memori), satu daftar per akun. Nanti diganti API.
class TransactionRepository {
  TransactionRepository._() {
    reset();
  }

  static final TransactionRepository instance = TransactionRepository._();

  final Map<String, List<Transaction>> _byEmail = {};

  /// Mengosongkan data lalu mengisi transaksi contoh untuk akun Budi.
  /// Total: Primer 2.400.000, Sekunder 650.000, Tersier 400.000
  /// (Sekunder + Tersier = 1.050.000 = 70% dari batas 1.500.000).
  void reset({DateTime? now}) {
    final base = now ?? DateTime.now();
    final today = DateTime(base.year, base.month, base.day);
    Transaction t(String id, String name, int amount, Kategori k, int ago) =>
        Transaction(
          id: id,
          name: name,
          amount: amount,
          kategori: k,
          date: today.subtract(Duration(days: ago)),
        );
    _byEmail
      ..clear()
      ..['budi.santoso@example.com'] = [
        t('t1', 'Beras dan minyak', 185000, Kategori.primer, 0),
        t('t2', 'Kopi kafe', 48000, Kategori.sekunder, 1),
        t('t3', 'Token listrik', 200000, Kategori.primer, 2),
        t('t4', 'Belanja bulanan', 1100000, Kategori.primer, 3),
        t('t5', 'Makan di luar', 350000, Kategori.sekunder, 4),
        t('t6', 'Langganan streaming', 54000, Kategori.sekunder, 5),
        t('t7', 'Transportasi', 515000, Kategori.primer, 6),
        t('t8', 'Parfum', 400000, Kategori.tersier, 7),
        t('t9', 'Jajan anak', 198000, Kategori.sekunder, 8),
        t('t10', 'Bensin', 400000, Kategori.primer, 9),
      ];
  }

  /// Semua transaksi akun, terbaru di atas.
  List<Transaction> all(String email) {
    final list = [...?_byEmail[email]];
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  void add(String email, Transaction transaction) {
    _byEmail.putIfAbsent(email, () => []).add(transaction);
  }

  int total(String email, Kategori kategori) {
    var sum = 0;
    for (final item in _byEmail[email] ?? const <Transaction>[]) {
      if (item.kategori == kategori) sum += item.amount;
    }
    return sum;
  }

  /// Pemakaian batas = Sekunder + Tersier.
  int usedLimit(String email) =>
      total(email, Kategori.sekunder) + total(email, Kategori.tersier);
}
