import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/themes/app_theme.dart';

class JoinVolunteerScreen extends StatefulWidget {
  const JoinVolunteerScreen({super.key});

  @override
  State<JoinVolunteerScreen> createState() => _JoinVolunteerScreenState();
}

class _JoinVolunteerScreenState extends State<JoinVolunteerScreen> {
  final Set<String> _selectedSkills = {'كشف وبحث ميداني'};
  bool _hasVehicle = false;
  String _availability = 'عطلة نهاية الأسبوع';
  String _selectedGovernorate = 'دمشق';
  final TextEditingController _phoneController = TextEditingController();

  final List<Map<String, dynamic>> _skillsList = [
    {'id': 'مسعف / كادر تمريض', 'icon': Icons.medical_services_outlined},
    {'id': 'سائق سيارة / نقل إغاثي', 'icon': Icons.directions_car_outlined},
    {'id': 'لوجستي وتوزيع مساعدات', 'icon': Icons.inventory_2_outlined},
    {'id': 'كشف وبحث ميداني', 'icon': Icons.person_search_outlined},
    {'id': 'إعلام وتوثيق رقمي', 'icon': Icons.photo_camera_outlined},
    {'id': 'دعم نفسي واجتماعي', 'icon': Icons.sentiment_satisfied_alt_outlined},
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Divider(
            height: 0.5,
            thickness: 0.5,
            color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
          ),
        ),
        // Top Right Brand Logo + Screen Title
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  'أثر',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'الانضمام كمتطوع',
                  style: GoogleFonts.cairo(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                Text(
                  'فريق الاستجابة الميداني',
                  style: GoogleFonts.cairo(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Banner
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(80),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'كن ذراع أثر في الميدان',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'ساهم في كشف الحالات، توزيع السلات عبر البطاقات الذكية، والاستجابة لنداءات الطوارئ.',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: Colors.white.withAlpha(220),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(40),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.volunteer_activism_rounded, color: Colors.white, size: 36),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),
            const SizedBox(height: 24),

            // Skills Selector
            Text('المهارات والقدرات الميدانية', style: _headingStyle(isDark)),
            const SizedBox(height: 6),
            Text('اختر المهارات التي تتقنها لتكليفك بالمهمات المناسبة:', style: _subStyle(isDark)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 10,
              children: _skillsList.map((skill) {
                final isSelected = _selectedSkills.contains(skill['id']);
                return FilterChip(
                  avatar: Icon(
                    skill['icon'] as IconData,
                    size: 18,
                    color: isSelected ? Colors.white : AppColors.primary,
                  ),
                  label: Text(skill['id'] as String),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: isDark ? AppColors.darkCard : Colors.white,
                  labelStyle: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : (isDark ? Colors.white : AppColors.textPrimary),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : (isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
                    ),
                  ),
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedSkills.add(skill['id'] as String);
                      } else {
                        if (_selectedSkills.length > 1) {
                          _selectedSkills.remove(skill['id'] as String);
                        }
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Vehicle Ownership
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
              ),
              child: SwitchListTile(
                title: Text(
                  'هل تمتلك وسيلة نقل للتوزيع الميداني؟',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'تساعدنا في توجيه مهمات النقل والتوزيع السريع لك',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                value: _hasVehicle,
                activeThumbColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) => setState(() => _hasVehicle = val),
              ),
            ),
            const SizedBox(height: 20),

            // Availability & Governorate
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('أوقات التفرغ', style: _headingStyle(isDark)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _availability,
                            isExpanded: true,
                            dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                            items: ['عطلة نهاية الأسبوع', 'فترة مسائية', 'متفرغ كلياً']
                                .map((a) => DropdownMenuItem(
                                      value: a,
                                      child: Text(
                                        a,
                                        style: GoogleFonts.cairo(
                                          fontSize: 12,
                                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                                        ),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (val) => setState(() => _availability = val!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('محافظة التطوع', style: _headingStyle(isDark)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedGovernorate,
                            isExpanded: true,
                            dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                            items: ['دمشق', 'ريف دمشق', 'حلب', 'حمص', 'حماة']
                                .map((g) => DropdownMenuItem(
                                      value: g,
                                      child: Text(
                                        g,
                                        style: GoogleFonts.cairo(
                                          fontSize: 12,
                                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                                        ),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (val) => setState(() => _selectedGovernorate = val!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Phone
            Text('رقم الهاتف للتواصل السريع', style: _headingStyle(isDark)),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: GoogleFonts.cairo(color: isDark ? Colors.white : const Color(0xFF0F172A)),
                decoration: InputDecoration(
                  hintText: '09xxxxxxxx',
                  hintStyle: GoogleFonts.cairo(color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.phone_rounded, color: AppColors.primary),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showVolunteerSuccessDialog(isDark),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  'إرسال طلب الانضمام لفريق أثر',
                  style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVolunteerSuccessDialog(bool isDark) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
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
              child: const Icon(Icons.handshake_rounded, color: AppColors.success, size: 48),
            ),
            const SizedBox(height: 16),
            Text(
              'أهلاً بك في عائلة أثر!',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'تم تسجيل طلبك بنجاح. سيتم مراجعة مهاراتك من إدارة الميدان، وبمجرد الاعتماد ستتحول واجهة تطبيقك إلى "البوابة الميدانية للمتطوع" لبدء المهام ومسح البطاقات الذكية.',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('العودة للرئيسية', style: GoogleFonts.cairo(fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _headingStyle(bool isDark) => GoogleFonts.cairo(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: isDark ? Colors.white : const Color(0xFF0F172A),
      );

  TextStyle _subStyle(bool isDark) => GoogleFonts.cairo(
        fontSize: 12,
        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
      );
}
