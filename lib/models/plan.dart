enum PlanGoal { pendidikan, rumah, pensiun, lainnya }

extension PlanGoalX on PlanGoal {
  String get label => switch (this) {
        PlanGoal.pendidikan => 'Dana pendidikan',
        PlanGoal.rumah => 'Pembelian rumah',
        PlanGoal.pensiun => 'Dana pensiun',
        PlanGoal.lainnya => 'Lainnya',
      };
}

/// Rencana keuangan jangka panjang.
class Plan {
  const Plan({
    required this.id,
    required this.goal,
    required this.name,
    required this.targetAmount,
    required this.years,
  });

  final String id;
  final PlanGoal goal;
  final String name;
  final int targetAmount;
  final int years;

  /// Tabungan per bulan = target dana / (tahun x 12), dibulatkan ke rupiah terdekat.
  /// Contoh: 150.000.000 dalam 15 tahun = Rp833.333 (PLN_009).
  int get monthlySaving {
    final months = years * 12;
    return (targetAmount * 2 + months) ~/ (months * 2);
  }
}

/// Perbandingan sebuah rencana dengan sisa uang bulanan.
class PlanAssessment {
  const PlanAssessment({required this.plan, required this.sisa});

  final Plan plan;

  /// Sisa uang bebas belanja per bulan (dari Pengaturan Awal).
  final int sisa;

  bool get sufficient => plan.monthlySaving <= sisa;

  /// Kekurangan per bulan (0 jika mencukupi).
  int get shortfall => sufficient ? 0 : plan.monthlySaving - sisa;

  /// Lama waktu minimal (tahun, dibulatkan ke atas) agar sisa uang mencukupi.
  /// null jika tidak ada sisa uang sama sekali.
  int? get yearsNeeded {
    if (sisa <= 0) return null;
    final perYear = sisa * 12;
    return (plan.targetAmount + perYear - 1) ~/ perYear;
  }
}
