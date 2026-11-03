/// Data keuangan bulanan dari layar Pengaturan Awal.
class FinanceSetup {
  const FinanceSetup({
    required this.gaji,
    required this.kebutuhan,
    required this.cicilan,
    required this.tabungan,
  });

  final int gaji;
  final int kebutuhan;
  final int cicilan;
  final int tabungan;

  int get pengeluaranTetap => kebutuhan + cicilan + tabungan;

  /// Sisa uang bebas belanja = batas pengeluaran Sekunder + Tersier.
  int get sisa => gaji - pengeluaranTetap;
}
