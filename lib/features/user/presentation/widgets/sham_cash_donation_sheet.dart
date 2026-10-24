import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../config/themes/app_theme.dart';
import '../../domain/entities/case.dart';

class ShamCashDonationSheet extends StatefulWidget {
  final Case caseItem;

  const ShamCashDonationSheet({super.key, required this.caseItem});

  @override
  State<ShamCashDonationSheet> createState() => _ShamCashDonationSheetState();
}

class _ShamCashDonationSheetState extends State<ShamCashDonationSheet> {
  String _paymentMethod = 'sham_cash'; // 'sham_cash' or 'syriatel_cash'
  double _selectedAmount = 25000;
  final TextEditingController _customAmountController = TextEditingController();
  final TextEditingController _donorNameController = TextEditingController(text: 'فاعل خير');
  final TextEditingController _phoneController = TextEditingController();
  bool _isProcessing = false;

  final List<double> _presetAmounts = [10000, 25000, 50000, 100000, 250000];
  final NumberFormat _currencyFormatter = NumberFormat('#,###');

  @override
  void dispose() {
    _customAmountController.dispose();
    _donorNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.volunteer_activism_rounded, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'بوابة التبرع المباشر',
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'كفالة ومساهمة فورية في حالة: ${widget.caseItem.title}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Payment Method Tabs (Sham Cash & Syriatel Cash)
            Text('طريقة الدفع الرقمية في سوريا', style: _labelStyle),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildMethodTab(
                    id: 'sham_cash',
                    title: 'شام كاش (Sham Cash)',
                    subtitle: 'دفع فوري عبر رمز التاجر',
                    icon: Icons.qr_code_2_rounded,
                    activeColor: const Color(0xFF0284C7),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMethodTab(
                    id: 'syriatel_cash',
                    title: 'سيريتل كاش',
                    subtitle: 'تحويل مباشر للمحفظة',
                    icon: Icons.phone_android_rounded,
                    activeColor: const Color(0xFFE11D48),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Preset Amount Chips
            Text('اختر قيمة المساهمة (ليرة سورية)', style: _labelStyle),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presetAmounts.map((amt) {
                final isSelected = _selectedAmount == amt && _customAmountController.text.isEmpty;
                return ChoiceChip(
                  label: Text('${_currencyFormatter.format(amt)} ل.س'),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: const Color(0xFFF8FAFC),
                  labelStyle: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                    ),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedAmount = amt;
                        _customAmountController.clear();
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Custom Amount Input
            TextField(
              controller: _customAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'أو أدخل مبلغاً آخر بالليرة السورية...',
                prefixIcon: const Icon(Icons.payments_outlined, color: AppColors.primary),
                suffixText: 'ل.س',
                suffixStyle: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.w700),
              ),
              onChanged: (val) {
                final parsed = double.tryParse(val.replaceAll(',', ''));
                if (parsed != null && parsed > 0) {
                  setState(() => _selectedAmount = parsed);
                }
              },
            ),
            const SizedBox(height: 16),

            // Merchant / Account Info Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user, color: AppColors.success, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _paymentMethod == 'sham_cash'
                              ? 'رمز التاجر المعتمد (منظمة أثر): #409822'
                              : 'رقم محفظة سيريتل كاش: 0933001122',
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'تصل التبرعات مباشرة إلى الحساب الإغاثي المخصص للحالة دون أي اقتطاعات.',
                          style: GoogleFonts.ibmPlexSansArabic(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processDonation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _paymentMethod == 'sham_cash' ? const Color(0xFF0284C7) : const Color(0xFFE11D48),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.volunteer_activism_rounded, size: 18, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'تأكيد التبرع بمبلغ ${_currencyFormatter.format(_selectedAmount)} ل.س',
                            style: GoogleFonts.ibmPlexSansArabic(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodTab({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color activeColor,
  }) {
    final isSelected = _paymentMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = id),
      child: AnimatedContainer(
        duration: 250.ms,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withAlpha(15) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: isSelected ? activeColor : AppColors.textSecondary, size: 24),
                if (isSelected)
                  Icon(Icons.check_circle, color: activeColor, size: 18),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? activeColor : AppColors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _processDonation() async {
    setState(() => _isProcessing = true);

    // Simulate payment processing
    await Future.delayed(const Duration(milliseconds: 1400));

    if (!mounted) return;
    setState(() => _isProcessing = false);

    Navigator.pop(context); // Close bottom sheet

    // Show Success Dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 48),
            ).animate().scale(curve: Curves.elasticOut, duration: 600.ms),
            const SizedBox(height: 16),
            Text(
              'تم استلام تبرعكم بنجاح!',
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'رقم إشعار عملية ${_paymentMethod == "sham_cash" ? "شام كاش" : "سيريتل كاش"}:',
              style: GoogleFonts.ibmPlexSansArabic(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'SHAM-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'تم تحديث نسبة اكتمال الحالة مباشرة. كتب الله أجركم وأخلف عليكم بالخير والبركة.',
              textAlign: TextAlign.center,
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إغلاق وتحديث'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle get _labelStyle => GoogleFonts.ibmPlexSansArabic(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );
}
