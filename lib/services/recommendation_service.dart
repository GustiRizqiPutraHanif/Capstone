import '../models/finance_setup.dart';

enum RecommendationSource { defaultRule, model }

/// Hasil rekomendasi: berapa persen sisa uang untuk Sekunder (sisanya Tersier).
class Recommendation {
  const Recommendation({required this.sekunderPercent, required this.source});

  final int sekunderPercent;
  final RecommendationSource source;

  int get tersierPercent => 100 - sekunderPercent;
}

/// TITIK SAMBUNG MODEL (mata kuliah Machine Learning).
///
/// Layar Pengaturan Awal hanya memanggil [RecommendationService.instance].
/// Sekarang isinya aturan bawaan 70/30. Kalau model sudah siap, buat class
/// baru yang memanggil API (NestJS -> layanan model), lalu ganti satu baris:
///
///   RecommendationService.instance = ApiRecommendationService();
///
/// Layar tidak perlu diubah. Jika panggilan gagal, [recommendSafely]
/// otomatis memakai pembagian bawaan agar aplikasi tetap jalan.
abstract class RecommendationService {
  Future<Recommendation> recommend(FinanceSetup setup);

  static RecommendationService instance = const DefaultRecommendationService();
}

/// Pembagian bawaan: 70% Sekunder, 30% Tersier.
class DefaultRecommendationService implements RecommendationService {
  const DefaultRecommendationService();

  @override
  Future<Recommendation> recommend(FinanceSetup setup) async {
    return const Recommendation(
      sekunderPercent: 70,
      source: RecommendationSource.defaultRule,
    );
  }
}

/// Memanggil layanan; jika error, kembali ke pembagian bawaan.
Future<Recommendation> recommendSafely(
  RecommendationService service,
  FinanceSetup setup,
) async {
  try {
    return await service.recommend(setup);
  } catch (_) {
    return const Recommendation(
      sekunderPercent: 70,
      source: RecommendationSource.defaultRule,
    );
  }
}
