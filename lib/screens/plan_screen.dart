import 'package:flutter/material.dart';

import '../data/session.dart';
import '../data/finance_repository.dart';
import '../data/plan_repository.dart';
import '../models/plan.dart';
import '../theme/app_colors.dart';
import '../utils/rupiah.dart';
import '../widgets/app_background.dart';
import '../widgets/gradient_button.dart';
import 'plan_form_screen.dart';

const _okColor = Color(0xFF166534);
const _okBackground = Color(0xFFDCFCE7);

/// Plan Masa Depan: daftar rencana, tombol tambah rencana, dan detailnya (PLN_009, PLN_018).
/// Catatan: akses khusus Kepala Keluarga dan Pasangan akan dipasang saat fitur peran dibuat.
class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  String get _email => Session.spaceId;

  Future<void> _addPlan(BuildContext context) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const PlanFormScreen()),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Rencana tersimpan.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PlanRepository.instance,
      builder: (context, _) {
        final sisa = FinanceRepository.instance.of(_email)?.setup.sisa ?? 0;
        final plans = PlanRepository.instance.all(_email);
        return Stack(
          fit: StackFit.expand,
          children: [
            const Positioned.fill(child: AppBackground()),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Plan Masa Depan',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.6,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Rencanakan tujuan jangka panjang keluarga.',
                          style: TextStyle(fontSize: 15, color: AppColors.body),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.softFill,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.savings_outlined, color: AppColors.accentDeep),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Sisa uang bulanan',
                                      style: TextStyle(fontSize: 13, color: AppColors.body),
                                    ),
                                    Text(
                                      formatRupiah(sisa),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        GradientButton(
                          label: 'Tambah Rencana',
                          onPressed: () => _addPlan(context),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Plan tersimpan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (plans.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: AppColors.fieldBorder),
                            ),
                            child: const Text(
                              'Belum ada rencana. Mulai dengan Tambah Rencana.',
                              style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.body),
                            ),
                          )
                        else
                          for (final plan in plans) ...[
                            _PlanCard(
                              assessment: PlanAssessment(plan: plan, sisa: sisa),
                              onTap: () => _showDetail(context, PlanAssessment(plan: plan, sisa: sisa)),
                            ),
                            const SizedBox(height: 12),
                          ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDetail(BuildContext context, PlanAssessment assessment) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _PlanDetail(assessment: assessment),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.sufficient});

  final bool sufficient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: sufficient ? _okBackground : AppColors.dangerSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        sufficient ? 'Rencana layak' : 'Belum cukup',
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: sufficient ? _okColor : AppColors.dangerDeep,
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.assessment, required this.onTap});

  final PlanAssessment assessment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final plan = assessment.plan;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.fieldBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    plan.name,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.ink),
                  ),
                ),
                _StatusChip(sufficient: assessment.sufficient),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '${plan.goal.label} · ${plan.years} tahun',
              style: const TextStyle(fontSize: 13.5, color: AppColors.body),
            ),
            const SizedBox(height: 6),
            Text(
              'Target ${formatRupiah(plan.targetAmount)} · ${formatRupiah(plan.monthlySaving)} per bulan',
              style: const TextStyle(fontSize: 14, color: AppColors.ink),
            ),
            const SizedBox(height: 6),
            Text(
              assessment.sufficient
                  ? 'Sisa uang ${formatRupiah(assessment.sisa)} mencukupi.'
                  : 'Sisa uang ${formatRupiah(assessment.sisa)} tidak mencukupi. Ketuk untuk melihat saran.',
              style: const TextStyle(fontSize: 13.5, height: 1.5, color: AppColors.body),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanDetail extends StatelessWidget {
  const _PlanDetail({required this.assessment});

  final PlanAssessment assessment;

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 14, color: AppColors.body)),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.ink),
          ),
        ],
      ),
    );
  }

  String get _advice {
    final needed = assessment.yearsNeeded;
    if (needed == null) {
      return 'Saran: kurangi pengeluaran Sekunder dan Tersier agar ada sisa uang bulanan, lalu atur ulang rencana.';
    }
    return 'Saran: kurangi pengeluaran Sekunder atau Tersier sebesar ${formatRupiah(assessment.shortfall)} per bulan, atau perpanjang waktu menjadi $needed tahun.';
  }

  @override
  Widget build(BuildContext context) {
    final plan = assessment.plan;
    final ok = assessment.sufficient;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Detail rencana',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.ink),
                  ),
                ),
                _StatusChip(sufficient: ok),
              ],
            ),
            const SizedBox(height: 12),
            _row('Nama rencana', plan.name),
            _row('Tujuan', plan.goal.label),
            _row('Target dana', formatRupiah(plan.targetAmount)),
            _row('Target waktu', '${plan.years} tahun'),
            _row('Tabungan per bulan', formatRupiah(plan.monthlySaving)),
            _row('Sisa uang bulanan', formatRupiah(assessment.sisa)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ok ? _okBackground : AppColors.dangerSoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ok
                        ? 'Sisa uang bulanan ${formatRupiah(assessment.sisa)} mencukupi untuk menabung ${formatRupiah(plan.monthlySaving)} per bulan.'
                        : 'Sisa uang bulanan ${formatRupiah(assessment.sisa)} tidak mencukupi untuk menabung ${formatRupiah(plan.monthlySaving)} per bulan.',
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                      color: ok ? _okColor : AppColors.dangerDeep,
                    ),
                  ),
                  if (!ok) ...[
                    const SizedBox(height: 8),
                    Text(
                      _advice,
                      style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.ink),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
