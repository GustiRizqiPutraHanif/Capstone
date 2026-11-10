import 'package:flutter/material.dart';

import '../data/auth_repository.dart';
import '../data/family_repository.dart';
import '../data/session.dart';
import '../data/transaction_repository.dart';
import '../models/usage_status.dart';
import '../theme/app_colors.dart';
import '../theme/status_style.dart';
import '../utils/date_labels.dart';
import '../utils/rupiah.dart';
import '../widgets/app_background.dart';
import '../widgets/transaction_tile.dart';
import 'history_screen.dart';
import 'login_screen.dart';

/// Beranda untuk peran Anak: hanya jatah dan transaksi pribadi,
/// tanpa penghasilan dan aset keluarga (ROL_010, ROL_020).
class ChildHomeScreen extends StatelessWidget {
  const ChildHomeScreen({super.key, required this.onNavigate});

  /// Pindah tab (1 = Catat, 2 = Umpan Balik).
  final ValueChanged<int> onNavigate;

  void _logout(BuildContext context) {
    AuthRepository.instance.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([TransactionRepository.instance, FamilyRepository.instance]),
      builder: (context, _) => _buildContent(context),
    );
  }

  String _message(UsageSummary summary) => switch (summary.status) {
        UsageStatus.aman => '',
        UsageStatus.waspada => 'Pengeluaranmu sudah ${summary.percent}% dari jatah. Hati-hati ya.',
        UsageStatus.merah => 'Pengeluaranmu sudah ${summary.percent}% dari jatah dan hampir habis.',
        UsageStatus.melebihi => 'Pengeluaranmu sudah melewati jatah bulan ini.',
      };

  Widget _buildContent(BuildContext context) {
    final email = Session.email;
    final space = Session.spaceId;
    final repo = TransactionRepository.instance;
    final jatah = FamilyRepository.instance.jatahOf(email);
    final used = repo.personalInMonth(space, email, DateTime.now());
    final summary = UsageSummary(used: used, limit: jatah);
    final style = statusStyleFor(summary.status);
    final first = AuthRepository.instance.nameOf(email).split(' ').first;
    final items = repo.all(space, memberEmail: email);
    final message = jatah <= 0
        ? 'Jatah belum ditetapkan oleh Kepala Keluarga.'
        : _message(summary);

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
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Halo, $first!',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                  color: AppColors.ink,
                                ),
                              ),
                              const Text(
                                'Kelola uang jatahmu dengan bijak.',
                                style: TextStyle(fontSize: 13.5, color: AppColors.body),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.softFill,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'Anak',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accentDeep,
                            ),
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
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
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
                            'Sisa Jatah Bulan Ini',
                            style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.ink),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatRupiah(jatah - used),
                            style: const TextStyle(
                              fontSize: 36,
                              height: 1.2,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: summary.ratio.clamp(0.0, 1.0),
                              minHeight: 10,
                              backgroundColor: const Color(0x66FFFFFF),
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.ink),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Terpakai ${formatRupiah(used)}',
                                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.ink),
                                ),
                              ),
                              Text(
                                'Jatah ${formatRupiah(jatah)}',
                                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.ink),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (message.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: jatah <= 0 ? AppColors.softFill : style.background,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            if (jatah > 0) ...[
                              Text(
                                summary.status.label,
                                style: TextStyle(fontWeight: FontWeight.w800, color: style.foreground),
                              ),
                              const SizedBox(width: 10),
                            ],
                            Expanded(
                              child: Text(
                                message,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.4,
                                  color: jatah <= 0 ? AppColors.ink : style.foreground,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.add_rounded,
                            label: 'Catat Pengeluaran',
                            onTap: () => onNavigate(1),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.chat_bubble_outline_rounded,
                            label: 'Umpan Balik',
                            onTap: () => onNavigate(2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Transaksi pribadiku',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => HistoryScreen(memberEmail: email),
                            ),
                          ),
                          child: const Text(
                            'Lihat semua',
                            style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.accentDeep),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Belum ada transaksi. Mulai dengan Catat Pengeluaran.',
                          style: TextStyle(color: AppColors.body),
                        ),
                      )
                    else
                      for (final item in items.take(3)) ...[
                        TransactionTile(
                          transaction: item,
                          dateText: relativeDay(item.date, DateTime.now()),
                        ),
                        const SizedBox(height: 10),
                      ],
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.softFill,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, size: 22, color: AppColors.accentDeep),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Tampilan Anak hanya menampilkan jatah dan transaksi pribadi, tanpa penghasilan dan aset keluarga.',
                              style: TextStyle(fontSize: 13.5, height: 1.5, color: AppColors.ink),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.fieldBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.softFill,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.accentDeep),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.ink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
