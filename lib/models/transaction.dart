enum Kategori { primer, sekunder, tersier }

extension KategoriX on Kategori {
  String get label => switch (this) {
        Kategori.primer => 'Primer',
        Kategori.sekunder => 'Sekunder',
        Kategori.tersier => 'Tersier',
      };
}

class Transaction {
  const Transaction({
    required this.id,
    required this.name,
    required this.amount,
    required this.kategori,
    required this.date,
    this.note = '',
  });

  final String id;
  final String name;
  final int amount;
  final Kategori kategori;
  final DateTime date;
  final String note;
}
