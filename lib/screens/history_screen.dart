import 'package:flutter/material.dart';

import '../data/session.dart';
import '../data/transaction_repository.dart';
import '../theme/app_colors.dart';
import '../utils/date_labels.dart';
import '../utils/rupiah.dart';
import '../widgets/app_background.dart';
import '../widgets/transaction_tile.dart';
import '../models/transaction.dart';

/// Riwayat transaksi: lihat semua, hapus, dan total pengeluaran ikut berubah.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, this.memberEmail});

  /// Jika diisi: hanya transaksi pribadi anggota ini (riwayat Anak).
  final String? memberEmail;

  Future<void> _confirmDelete(BuildContext context, Transaction item, String email) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Hapus transaksi?',
          style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink),
        ),
        content: Text(
          '${item.name} (${formatRupiah(item.amount)}) akan dihapus dari riwayat.',
          style: const TextStyle(height: 1.5, color: AppColors.body),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    TransactionRepository.instance.remove(email, item.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Transaksi dihapus.')));
  }

  @override
  Widget build(BuildContext context) {
    final email = Session.spaceId;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: AppBackground()),
          SafeArea(
            child: ListenableBuilder(
              listenable: TransactionRepository.instance,
              builder: (context, _) {
                final repo = TransactionRepository.instance;
                final items = repo.all(email, memberEmail: memberEmail);
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            tooltip: 'Kembali',
                            padding: EdgeInsets.zero,
                            alignment: Alignment.centerLeft,
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 20,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Riwayat Transaksi',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.6,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFFFAE5C), Color(0xFFF97316)],
                            ),
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total pengeluaran',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.ink,
                                ),
                              ),
                              Text(
                                formatRupiah(items.fold<int>(0, (sum, item) => sum + item.amount)),
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.8,
                                  color: AppColors.ink,
                                ),
                              ),
                              Text(
                                '${items.length} transaksi',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (items.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text(
                              'Belum ada transaksi.',
                              style: TextStyle(color: AppColors.body),
                            ),
                          )
                        else
                          for (final item in items) ...[
                            TransactionTile(
                              transaction: item,
                              dateText: formatDate(item.date),
                              onDelete: () => _confirmDelete(context, item, email),
                            ),
                            const SizedBox(height: 10),
                          ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
