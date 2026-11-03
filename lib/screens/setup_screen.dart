import 'package:flutter/material.dart';

import '../data/auth_repository.dart';
import '../data/finance_repository.dart';
import '../models/finance_setup.dart';
import '../services/recommendation_service.dart';
import '../theme/app_colors.dart';
import '../utils/rupiah.dart';
import '../widgets/app_background.dart';
import '../widgets/app_text_field.dart';
import '../widgets/error_banner.dart';
import '../widgets/gradient_button.dart';
import 'main_shell.dart';

/// Pengaturan Awal: data keuangan bulanan + sisa uang bebas belanja.
/// Tidak meminta membuat keluarga atau mengundang anggota (test case SET_003).
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _gaji = TextEditingController();
  final _kebutuhan = TextEditingController();
  final _cicilan = TextEditingController();
  final _tabungan = TextEditingController();
  final _formatter = RupiahInputFormatter();

  int _sekunderPercent = 70;
  RecommendationSource _source = RecommendationSource.defaultRule;
  bool _userAdjusted = false;
  int _requestId = 0;
  bool _isSaving = false;

  List<TextEditingController> get _controllers =>
      [_gaji, _kebutuhan, _cicilan, _tabungan];

  @override
  void initState() {
    super.initState();
    for (final controller in _controllers) {
      controller.addListener(_onInputChanged);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.removeListener(_onInputChanged);
      controller.dispose();
    }
    super.dispose();
  }

  int _value(TextEditingController controller) =>
      parseRupiah(controller.text) ?? 0;

  FinanceSetup get _setup => FinanceSetup(
        gaji: _value(_gaji),
        kebutuhan: _value(_kebutuhan),
        cicilan: _value(_cicilan),
        tabungan: _value(_tabungan),
      );

  void _onInputChanged() {
    setState(() {});
    _refreshRecommendation();
  }

  /// Meminta rekomendasi pembagian Sekunder/Tersier dari layanan
  /// (sekarang aturan bawaan, nanti model).
  Future<void> _refreshRecommendation() async {
    final setup = _setup;
    if (setup.sisa <= 0) return;
    final id = ++_requestId;
    final result = await recommendSafely(RecommendationService.instance, setup);
    if (!mounted || id != _requestId || _userAdjusted) return;
    setState(() {
      _sekunderPercent = result.sekunderPercent;
      _source = result.source;
    });
  }

  String? _validateGaji(String? value) {
    if (value == null || value.trim().isEmpty) return 'Gaji wajib diisi';
    final parsed = parseRupiah(value);
    if (parsed == null || parsed <= 0) return 'Gaji harus lebih dari 0';
    return null;
  }

  String? _validateOptional(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = parseRupiah(value);
    if (parsed == null || parsed < 0) return 'Nominal tidak boleh negatif';
    return null;
  }

  Future<void> _save() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final setup = _setup;
    if (setup.sisa < 0) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Periksa kembali datamu',
            style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink),
          ),
          content: const Text(
            'Pengeluaran tetap melebihi pemasukan. Tetap simpan data ini?',
            style: TextStyle(height: 1.5, color: AppColors.body),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Perbaiki'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Tetap simpan'),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }

    setState(() => _isSaving = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final user = AuthRepository.instance.currentUser;
    FinanceRepository.instance.save(
      email: user?.email ?? '',
      setup: setup,
      sekunderPercent: setup.sisa > 0 ? _sekunderPercent : 0,
    );
    user?.setupDone = true;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Data keuangan tersimpan. Sisa uang bebas belanja ${formatRupiah(setup.sisa)}.',
          ),
        ),
      );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const MainShell()),
    );
  }

  Widget _moneyField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    required TextInputAction action,
  }) {
    return AppTextField(
      label: label,
      hint: '0',
      prefix: 'Rp',
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(signed: true),
      textInputAction: action,
      inputFormatters: [_formatter],
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    final setup = _setup;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: AppBackground()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(26, 24, 26, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.softFill,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Pengaturan Awal',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accentDeep,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Atur keuangan bulananmu',
                        style: TextStyle(
                          fontSize: 28,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.8,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Isi data per bulan. Sisa uang bebas belanja dihitung otomatis.',
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: AppColors.body,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _moneyField(
                              label: 'Gaji per bulan',
                              controller: _gaji,
                              validator: _validateGaji,
                              action: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),
                            _moneyField(
                              label: 'Kebutuhan per bulan',
                              controller: _kebutuhan,
                              validator: _validateOptional,
                              action: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),
                            _moneyField(
                              label: 'Cicilan per bulan',
                              controller: _cicilan,
                              validator: _validateOptional,
                              action: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),
                            _moneyField(
                              label: 'Tabungan per bulan',
                              controller: _tabungan,
                              validator: _validateOptional,
                              action: TextInputAction.done,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (setup.sisa < 0) ...[
                        const ErrorBanner(
                          message:
                              'Pengeluaran tetap melebihi pemasukan. Kurangi kebutuhan, cicilan, atau tabungan.',
                        ),
                        const SizedBox(height: 14),
                      ],
                      _buildSisaCard(setup),
                      if (setup.sisa > 0) ...[
                        const SizedBox(height: 14),
                        _buildRecommendationCard(setup),
                      ],
                      const SizedBox(height: 22),
                      GradientButton(
                        label: 'Simpan',
                        isLoading: _isSaving,
                        onPressed: _save,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSisaCard(FinanceSetup setup) {
    final negative = setup.sisa < 0;
    final textColor = negative ? AppColors.dangerDeep : AppColors.ink;
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
      decoration: BoxDecoration(
        color: negative ? AppColors.dangerSoft : null,
        gradient: negative
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFAE5C), Color(0xFFF97316)],
              ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33F97316),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sisa uang bebas belanja',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatRupiah(setup.sisa),
            style: TextStyle(
              fontSize: 34,
              height: 1.2,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            negative
                ? '${formatNumber(setup.gaji)} − ${formatNumber(setup.kebutuhan)} − ${formatNumber(setup.cicilan)} − ${formatNumber(setup.tabungan)}.'
                : '${formatNumber(setup.gaji)} − ${formatNumber(setup.kebutuhan)} − ${formatNumber(setup.cicilan)} − ${formatNumber(setup.tabungan)}. Ini menjadi batas pengeluaran Sekunder + Tersier.',
            style: TextStyle(
              fontSize: 13.5,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(FinanceSetup setup) {
    final sekunder = (setup.sisa * _sekunderPercent / 100).round();
    final tersier = setup.sisa - sekunder;
    final note = _source == RecommendationSource.model
        ? 'Rekomendasi model. Geser untuk mengubah.'
        : 'Pembagian bawaan. Geser untuk mengubah.';
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pembagian sisa uang',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _shareTile(
                  'Sekunder',
                  '$_sekunderPercent%',
                  formatRupiah(sekunder),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _shareTile(
                  'Tersier',
                  '${100 - _sekunderPercent}%',
                  formatRupiah(tersier),
                ),
              ),
            ],
          ),
          Slider(
            value: _sekunderPercent.toDouble(),
            min: 0,
            max: 100,
            divisions: 20,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.softFill,
            onChanged: (value) => setState(() {
              _sekunderPercent = value.round();
              _userAdjusted = true;
            }),
          ),
          Text(
            note,
            style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _shareTile(String label, String percent, String amount) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.softFill,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.body),
          ),
          const SizedBox(height: 2),
          Text(
            percent,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.accentDeep,
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
