import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nfc_manager/nfc_manager.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../services/locator.dart';
import '../../domain/repositories/volunteer_repository.dart';

class NfcAidScannerScreen extends StatefulWidget {
  const NfcAidScannerScreen({super.key});

  @override
  State<NfcAidScannerScreen> createState() => _NfcAidScannerScreenState();
}

class _NfcAidScannerScreenState extends State<NfcAidScannerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _isNfcAvailable = false;
  bool _isNfcScanning = false;
  bool _isLoading = false;
  int _pendingOfflineCount = 0;

  List<Map<String, dynamic>> _activeCampaigns = [];
  int? _selectedCampaignId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initScanner();
  }

  Future<void> _initScanner() async {
    final repo = locator<VolunteerRepository>();
    _pendingOfflineCount = await repo.getPendingOfflineDistributionsCount();

    // Load active campaigns
    final campaignsRes = await repo.getActiveCampaigns();
    campaignsRes.fold((_) {}, (campaigns) {
      if (mounted && campaigns.isNotEmpty) {
        setState(() {
          _activeCampaigns = campaigns;
          _selectedCampaignId = campaigns.first['id'] as int?;
        });
      }
    });

    // Check NFC availability safely
    try {
      final available = await NfcManager.instance.isAvailable();
      if (mounted) {
        setState(() => _isNfcAvailable = available);
        if (available) {
          _startNfcSession();
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isNfcAvailable = false);
    }
  }

  void _startNfcSession() {
    if (!_isNfcAvailable || _isNfcScanning) return;
    setState(() => _isNfcScanning = true);

    try {
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          HapticFeedback.heavyImpact();
          // Extract card identifier or use tag data
          final identifier = tag.data['nfca']?['identifier'] ??
              tag.data['isodep']?['identifier'] ??
              tag.data['mifare']?['identifier'];

          String token = 'ATHAR-NFC-2026-001';
          if (identifier is List) {
            token = identifier.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
          }

          if (mounted) {
            _handleTokenDiscovered(token, 'nfc_tap');
          }
        },
      );
    } catch (_) {
      setState(() => _isNfcScanning = false);
    }
  }

  @override
  void dispose() {
    try {
      NfcManager.instance.stopSession();
    } catch (_) {}
    _scannerController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleTokenDiscovered(String token, String method) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final repo = locator<VolunteerRepository>();
    final result = await repo.lookupBeneficiary(token);

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.fold(
      (failure) {
        _showErrorDialog(failure.message);
      },
      (beneficiary) {
        _showBeneficiaryDeliveryModal(beneficiary, token, method);
      },
    );
  }

  void _showBeneficiaryDeliveryModal(Map<String, dynamic> family, String token, String method) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final familyName = family['head_of_family_name'] ?? 'عائلة مستفيدة';
    final nationalId = family['national_id'] ?? 'غير متوفر';
    final membersCount = family['family_members_count'] ?? 1;
    final governorate = family['governorate']?['name'] ?? family['governorate_name'] ?? 'دمشق';
    final address = family['district'] != null
        ? '${family['district']} - ${family['address_details'] ?? ''}'
        : (family['address'] ?? 'دمشق');
    final vulnerability = family['vulnerability_score'] ?? 80;

    int currentCampaign = _selectedCampaignId ?? (_activeCampaigns.isNotEmpty ? _activeCampaigns.first['id'] as int : 1);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (modalContext, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Verification Header Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withAlpha(30),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 22),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'تم التحقق من البطاقة الذكية',
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      method == 'nfc_tap' ? 'تلامس NFC' : 'مسح QR',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Family Details Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('اسم رب الأسرة:', style: _infoLabelStyle(isDark)),
                        Text(
                          familyName,
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('الرقم الوطني:', style: _infoLabelStyle(isDark)),
                        Text(
                          nationalId,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white70 : const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('عدد أفراد الأسرة:', style: _infoLabelStyle(isDark)),
                        Text(
                          '$membersCount أفراد',
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white70 : const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('المحافظة والعنوان:', style: _infoLabelStyle(isDark)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$governorate - $address',
                            textAlign: TextAlign.end,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : const Color(0xFF334155),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('مؤشر الاحتياج والهشاشة:', style: _infoLabelStyle(isDark)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withAlpha(30),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$vulnerability / 100',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Active Campaign Selector
              Text(
                'الحملة الإغاثية المستهدفة',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: currentCampaign,
                    isExpanded: true,
                    dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                    items: _activeCampaigns.map((c) {
                      return DropdownMenuItem<int>(
                        value: c['id'] as int,
                        child: Text(
                          '${c['title']} (${c['item_type'] ?? 'معونة إغاثية'})',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => currentCampaign = val);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Deliver Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await _executeDelivery(currentCampaign, token, method);
                  },
                  icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
                  label: Text(
                    'تأكيد التسليم الفوري للعائلة',
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _executeDelivery(int campaignId, String token, String method) async {
    setState(() => _isLoading = true);
    final repo = locator<VolunteerRepository>();

    final result = await repo.verifyAndDeliverAid(
      campaignId: campaignId,
      token: token,
      verificationMethod: method,
      notes: 'تسليم يدوي موثق ميدانياً بواسطة بطاقة أثر الذكية',
    );

    _pendingOfflineCount = await repo.getPendingOfflineDistributionsCount();
    if (!mounted) return;
    setState(() => _isLoading = false);

    result.fold(
      (failure) {
        _showErrorDialog(failure.message);
      },
      (data) {
        _showDeliverySuccessDialog(data);
      },
    );
  }

  void _showDeliverySuccessDialog(Map<String, dynamic> data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOffline = data['is_offline_cached'] == true;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isOffline ? const Color(0xFFF59E0B) : const Color(0xFF10B981)).withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isOffline ? Icons.cloud_queue_rounded : Icons.verified_rounded,
                color: isOffline ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isOffline ? 'تم التوثيق محلياً (وضع عدم الاتصال)' : 'تم التوثيق والتسليم بنجاح!',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isOffline
                  ? 'تم حفظ العملية في ذاكرة الهاتف لعدم توفر إنترنت، وستتم المزامنة تلقائياً عند عودة الاتصال.'
                  : 'تم تسجيل عملية التسليم في قاعدة البيانات المركزية وحسم الحصة من المستودع مع إضافة +15 نقطة إلى رصيد تطوعك.',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('متابعة المسح الميداني', style: GoogleFonts.cairo(fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.red, size: 24),
            const SizedBox(width: 8),
            Text('تنبيه التحقق', style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.cairo(
            fontSize: 13,
            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('حسناً', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Future<void> _syncOfflineQueue() async {
    final repo = locator<VolunteerRepository>();
    setState(() => _isLoading = true);
    final res = await repo.syncOfflineDistributions();
    _pendingOfflineCount = await repo.getPendingOfflineDistributionsCount();
    if (!mounted) return;
    setState(() => _isLoading = false);

    res.fold(
      (failure) => _showErrorDialog(failure.message),
      (syncedCount) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تمت مزامنة $syncedCount عملية تسليم بنجاح مع الخادم المركزي!'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  TextStyle _infoLabelStyle(bool isDark) => GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
      );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : const Color(0xFFF8FAFC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        title: Text(
          'ماسح الإغاثة والبطاقات الذكية',
          style: GoogleFonts.cairo(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
          labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.nfc_rounded), text: 'بطاقة NFC الذكية'),
            Tab(icon: Icon(Icons.qr_code_scanner_rounded), text: 'كاميرا مسح QR'),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              // 1. NFC Tap Screen
              _buildNfcTabView(isDark),

              // 2. QR Camera Scanner View
              _buildQrCameraView(isDark),
            ],
          ),

          // Offline Sync Floating Banner
          if (_pendingOfflineCount > 0)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_off_rounded, color: Color(0xFFF59E0B), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'لديك $_pendingOfflineCount عملية تسليم غير متزامنة',
                        style: GoogleFonts.cairo(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _syncOfflineQueue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: Text('مزامنة الآن', style: GoogleFonts.cairo(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),
            ),

          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ),
        ],
      ),
    );
  }

  Widget _buildNfcTabView(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // Pulsing NFC Antenna Icon
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withAlpha(isDark ? 40 : 20),
              border: Border.all(color: AppColors.primary.withAlpha(80), width: 2),
            ),
            child: Center(
              child: Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: const Icon(Icons.nfc_rounded, size: 60, color: Colors.white),
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1.05, 1.05),
                duration: 1000.ms,
              ),
          const SizedBox(height: 28),
          Text(
            'قرّب بطاقة المستفيد من خلف الهاتف',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'سيتم التعرف على كود البطاقة المشفر والتحقق من الاستحقاق فورا.',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 36),

          // Demo NFC Simulation Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.science_outlined, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'محاكاة تلامس البطاقات للتجربة والمناقشة:',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionChip(
                      label: Text('عائلة أبو أحمد (001)', style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w700)),
                      avatar: const Icon(Icons.contactless_rounded, size: 16),
                      onPressed: () => _handleTokenDiscovered('ATHAR-NFC-2026-001', 'nfc_tap'),
                    ),
                    ActionChip(
                      label: Text('عائلة أم محمود (002)', style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w700)),
                      avatar: const Icon(Icons.contactless_rounded, size: 16),
                      onPressed: () => _handleTokenDiscovered('ATHAR-NFC-2026-002', 'nfc_tap'),
                    ),
                    ActionChip(
                      label: Text('عائلة الرفاعي (003)', style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w700)),
                      avatar: const Icon(Icons.contactless_rounded, size: 16),
                      onPressed: () => _handleTokenDiscovered('ATHAR-NFC-2026-003', 'nfc_tap'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrCameraView(bool isDark) {
    return Stack(
      children: [
        MobileScanner(
          controller: _scannerController,
          onDetect: (capture) {
            final barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null) {
                HapticFeedback.heavyImpact();
                _handleTokenDiscovered(barcode.rawValue!, 'qr_scan');
                break;
              }
            }
          },
        ),

        // QR Overlay guide box
        Center(
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary, width: 3),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),

        Positioned(
          bottom: 40,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'وجّه الكاميرا نحو رمز الاستجابة السريعة (QR) المطبوع على البطاقة',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
