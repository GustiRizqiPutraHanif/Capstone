import 'package:flutter/material.dart';

import '../data/auth_repository.dart';
import '../data/finance_repository.dart';
import '../data/transaction_repository.dart';
import '../models/transaction.dart';
import '../models/usage_status.dart';
import '../theme/app_colors.dart';
import '../theme/status_style.dart';
import '../utils/date_labels.dart';
import '../utils/rupiah.dart';
import '../widgets/app_background.dart';
import 'login_screen.dart';

/// Beranda: sisa uang bebas belanja, pemakaian batas, menu cepat, transaksi terbaru.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onNavigate});

  /// Pindah tab pada MainShell (1 Transaksi, 2 Analisis, 3 Plan).
  final ValueChanged<int> onNavigate;

  void _logout(BuildContext context) {
    AuthRepository.instance.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$feature dibuat pada langkah berikutnya.')));
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthRepository.instance.currentUser;
    final email = user?.email ?? '';
    final finance = FinanceRepository.instance.of(email);
    final repo = TransactionRepository.instance;
    final transactions = repo.all(email);
    final limit = finance?.setup.sisa ?? 0;
    final summary = UsageSummary(used: repo.usedLimit(email), limit: limit);

    final first = (user?.name ?? '').trim().split(' ').first;
    final greeting = 'Halo, ${first.isEmpty ? 'Keluarga' : first}!';

    return Stack(
      fit: StackFit.expand,
      children: [
        const Positioned.fill(child: AppBackground()),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(context, greeting),
                    const SizedBox(height: 20),
                    _buildLimitHero(limit),
                    const SizedBox(height: 14),
                    _buildUsageCard(summary),
                    const SizedBox(height: 22),
                    _buildQuickActions(context),
                    const SizedBox(height: 24),
                    const Text(
                      'Transaksi terbaru',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (transactions.isEmpty)
                      _buildEmpty()
                    else
                      for (final item in transactions.take(3)) ...[
                        _TransactionTile(transaction: item),
                        const SizedBox(height: 10),
                      ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, String greeting) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.softFill,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.home_rounded, color: AppColors.primary, size: 30),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: AppColors.ink,
                ),
              ),
              const Text(
                'Mari kelola keuangan keluarga dengan lebih baik.',
                style: TextStyle(fontSize: 13.5, height: 1.4, color: AppColors.body),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.body),
          tooltip: 'Menu',
          color: Colors.white,
          onSelected: (_) => _logout(context),
          itemBuilder: (_) => const [
            PopupMenuItem<String>(value: 'keluar', child: Text('Keluar')),
          ],
        ),
      ],
    );
  }

  Widget _buildLimitHero(int limit) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFAE5C), Color(0xFFF97316)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Color(0x33F97316), blurRadius: 24, offset: Offset(0, 12)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sisa Uang Bebas Belanja',
            style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.ink),
          ),
          const SizedBox(height: 4),
          Text(
            formatRupiah(limit),
            style: const TextStyle(
              fontSize: 36,
              height: 1.2,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Batas pengeluaran Sekunder + Tersier bulan ini',
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: AppColors.ink),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageCard(UsageSummary summary) {
    final style = statusStyleFor(summary.status);
    return Container(
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
              const Expanded(
                child: Text(
                  'Pemakaian batas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: style.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  summary.status.label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: style.foreground,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: summary.ratio.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: AppColors.softFill,
              valueColor: AlwaysStoppedAnimation<Color>(style.bar),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${formatRupiah(summary.used)} dari ${formatRupiah(summary.limit)}',
            style: const TextStyle(fontSize: 13.5, color: AppColors.body),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _QuickAction(
          icon: Icons.add_rounded,
          label: 'Catat Transaksi',
          onTap: () => onNavigate(1),
        ),
        _QuickAction(
          icon: Icons.bar_chart_rounded,
          label: 'Hasil & Analisis',
          onTap: () => onNavigate(2),
        ),
        _QuickAction(
          icon: Icons.calendar_month_outlined,
          label: 'Plan Masa Depan',
          onTap: () => onNavigate(3),
        ),
        _QuickAction(
          icon: Icons.chat_bubble_outline_rounded,
          label: 'Umpan Balik',
          onTap: () => _comingSoon(context, 'Umpan Balik'),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: const Text(
        'Belum ada transaksi. Mulai dengan Catat Transaksi.',
        style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.body),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.softFill,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(icon, color: AppColors.accentDeep, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction});

  final Transaction transaction;

  IconData get _icon => switch (transaction.kategori) {
        Kategori.primer => Icons.shopping_basket_outlined,
        Kategori.sekunder => Icons.local_cafe_outlined,
        Kategori.tersier => Icons.diamond_outlined,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.softFill,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(_icon, color: AppColors.accentDeep, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.name,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  '${transaction.kategori.label} · ${relativeDay(transaction.date, DateTime.now())}',
                  style: const TextStyle(fontSize: 13, color: AppColors.body),
                ),
              ],
            ),
          ),
          Text(
            '−${formatRupiah(transaction.amount)}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
