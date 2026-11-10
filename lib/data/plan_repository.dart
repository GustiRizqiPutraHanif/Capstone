import 'package:flutter/foundation.dart';

import '../models/plan.dart';

/// Data Plan DUMMY (di memori), satu daftar per akun. Nanti diganti API.
class PlanRepository extends ChangeNotifier {
  PlanRepository._() {
    reset();
  }

  static final PlanRepository instance = PlanRepository._();

  final Map<String, List<Plan>> _byEmail = {};

  /// Mengosongkan data lalu mengisi satu rencana contoh untuk akun Budi.
  /// (Rp300.000.000 dalam 15 tahun = Rp1.666.667 per bulan, melebihi sisa uang.)
  void reset() {
    _byEmail
      ..clear()
      ..['budi.santoso@example.com'] = [
        const Plan(
          id: 'p1',
          goal: PlanGoal.rumah,
          name: 'Rumah Pertama',
          targetAmount: 300000000,
          years: 15,
        ),
      ];
    notifyListeners();
  }

  /// Rencana terbaru di atas.
  List<Plan> all(String email) => [...?_byEmail[email]].reversed.toList();

  void add(String email, Plan plan) {
    _byEmail.putIfAbsent(email, () => []).add(plan);
    notifyListeners();
  }
}
