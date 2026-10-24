import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../core/theme/theme_service.dart';
import '../../../../services/locator.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/repositories/volunteer_repository.dart';

class VolunteerProfileScreen extends StatefulWidget {
  const VolunteerProfileScreen({super.key});

  @override
  State<VolunteerProfileScreen> createState() => _VolunteerProfileScreenState();
}

class _VolunteerProfileScreenState extends State<VolunteerProfileScreen> {
  bool _isLoading = true;
  bool _isEditing = false;
  Map<String, dynamic>? _profile;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordFormKey = GlobalKey<FormState>();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  List<String> _skills = [];
  final List<String> _availableSkills = [
    'إغاثة',
    'تدريس',
    'طب',
    'بناء',
    'تنظيم فعاليات',
    'قيادة',
    'تصوير',
    'كتابة محتوى',
    'تصميم',
    'برمجة',
  ];

  // Dynamic Theme Colors
  bool get _isDark => mounted && Theme.of(context).brightness == Brightness.dark;
  Color get _backgroundOffWhite => _isDark ? AppColors.darkScaffold : const Color(0xFFF8FAFC);
  Color get _softBlueTint => _isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
  Color get _friendlyBlue => _isDark ? const Color(0xFF60A5FA) : const Color(0xFF1E7ABF);
  Color get _softTeal => const Color(0xFF3BB3A9);
  Color get _textDark => _isDark ? Colors.white : const Color(0xFF0F172A);
  Color get _textMedium => _isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  Color get _textLight => _isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
  Color get _cardWhite => _isDark ? AppColors.darkCard : const Color(0xFFFFFFFF);
  Color get _borderLight => _isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);
  Color get _inputFill => _isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final repository = locator<VolunteerRepository>();
    final result = await repository.getProfile();
    
    result.fold(
      (failure) => setState(() => _isLoading = false),
      (profile) {
        setState(() {
          _profile = profile;
          _nameController.text = profile['name'] ?? '';
          _phoneController.text = profile['phone'] ?? '';
          _bioController.text = profile['bio'] ?? '';
          _skills = List<String>.from(profile['skills'] ?? []);
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    
    final repository = locator<VolunteerRepository>();
    final result = await repository.updateProfile(
      name: _nameController.text,
      phone: _phoneController.text,
      bio: _bioController.text,
      skills: _skills,
    );
    
    result.fold(
      (failure) {
        setState(() => _isLoading = false);
        _showSnackBar('فشل: ${failure.message}', Colors.red);
      },
      (_) {
        setState(() {
          _isLoading = false;
          _isEditing = false;
        });
        _showSnackBar('تم حفظ البيانات بنجاح!', _softTeal);
      },
    );
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final repository = locator<VolunteerRepository>();
    final result = await repository.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() => _isLoading = false);
        _showSnackBar('فشل: ${failure.message}', Colors.red);
      },
      (_) {
        setState(() => _isLoading = false);
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        Navigator.pop(context);
        _showSnackBar('تم تغيير كلمة المرور بنجاح!', _softTeal);
      },
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.cairo(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: _borderLight),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _friendlyBlue.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.lock_outline, color: _friendlyBlue),
            ),
            const SizedBox(width: 12),
            Text(
              'تغيير كلمة المرور',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: _textDark,
              ),
            ),
          ],
        ),
        content: Form(
          key: _passwordFormKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPasswordField(
                  controller: _currentPasswordController,
                  label: 'كلمة المرور الحالية',
                  isObscure: _obscureCurrentPassword,
                  onToggle: () => setState(() => _obscureCurrentPassword = !_obscureCurrentPassword),
                  validator: (v) => v?.isEmpty ?? true ? 'يرجى إدخال كلمة المرور الحالية' : null,
                ),
                const SizedBox(height: 12),
                _buildPasswordField(
                  controller: _newPasswordController,
                  label: 'كلمة المرور الجديدة',
                  isObscure: _obscureNewPassword,
                  onToggle: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'يرجى إدخال كلمة المرور الجديدة';
                    if (v!.length < 8) return 'يجب أن تكون 8 أحرف على الأقل';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  label: 'تأكيد كلمة المرور',
                  isObscure: _obscureConfirmPassword,
                  onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'يرجى تأكيد كلمة المرور';
                    if (v != _newPasswordController.text) return 'كلمات المرور غير متطابقة';
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _currentPasswordController.clear();
              _newPasswordController.clear();
              _confirmPasswordController.clear();
            },
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(
                color: _textMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: _isLoading ? null : _changePassword,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_friendlyBlue, _softTeal],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'تغيير',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isObscure,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      validator: validator,
      style: GoogleFonts.cairo(color: _textDark, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.cairo(color: _textMedium, fontSize: 13),
        prefixIcon: Icon(Icons.lock_outline, color: _friendlyBlue, size: 20),
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Icon(
            isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: _textLight,
            size: 20,
          ),
        ),
        filled: true,
        fillColor: _inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _friendlyBlue, width: 1.5),
        ),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: _borderLight),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.logout, color: Colors.red),
            ),
            const SizedBox(width: 12),
            Text(
              'تأكيد تسجيل الخروج',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: _textDark,
              ),
            ),
          ],
        ),
        content: Text(
          'هل أنت متأكد من تسجيل الخروج؟',
          style: GoogleFonts.cairo(fontSize: 14, color: _textMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(color: _textMedium, fontWeight: FontWeight.w600),
            ),
          ),
          GestureDetector(
            onTap: () async {
              Navigator.pop(context);
              await locator<AuthRepository>().logout();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                this.context,
                AppRoutes.login,
                (route) => false,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'خروج',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundOffWhite,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: _isDark ? AppColors.darkCard : _backgroundOffWhite,
        elevation: 0,
        title: Text(
          'الملف الشخصي',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _textDark,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!_isEditing)
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _cardWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _borderLight, width: 1),
              ),
              child: IconButton(
                icon: Icon(Icons.edit_outlined, color: _friendlyBlue, size: 20),
                onPressed: () => setState(() => _isEditing = true),
              ),
            )
          else
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_friendlyBlue, _softTeal],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.check, color: Colors.white, size: 20),
                      onPressed: _isLoading ? null : _saveProfile,
                    ),
            ),
        ],
      ),
      body: _isLoading && _profile == null
          ? _buildLoadingView()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 28),
                    _buildSectionTitle('المعلومات الشخصية'),
                    const SizedBox(height: 16),
                    _buildPersonalInfoSection(),
                    const SizedBox(height: 28),
                    _buildSectionTitle('المهارات'),
                    const SizedBox(height: 16),
                    _buildSkillsSection(),
                    const SizedBox(height: 28),
                    _buildSectionTitle('الإعدادات'),
                    const SizedBox(height: 16),
                    _buildActionsSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _cardWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _borderLight),
              boxShadow: _isDark
                  ? []
                  : [
                      BoxShadow(
                        color: _friendlyBlue.withAlpha(20),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(_friendlyBlue),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_friendlyBlue, _softTeal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: _isDark
                      ? []
                      : [
                          BoxShadow(
                            color: _friendlyBlue.withAlpha(30),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                ),
                child: const Icon(
                  Icons.volunteer_activism,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _cardWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _borderLight),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      size: 18,
                      color: _friendlyBlue,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _profile?['name'] ?? '',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'متطوع منذ ${_profile?['joinedAt'] ?? _profile?['joined_at'] ?? ''}',
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.cairo(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: _friendlyBlue,
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Container(
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderLight, width: 1),
        boxShadow: _isDark
            ? []
            : [
                BoxShadow(
                  color: _friendlyBlue.withAlpha(8),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoField(
              label: 'الاسم',
              controller: _nameController,
              icon: Icons.person_outlined,
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            _buildInfoField(
              label: 'رقم الهاتف',
              controller: _phoneController,
              icon: Icons.phone_outlined,
              enabled: _isEditing,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _buildInfoField(
              label: 'البريد الإلكتروني',
              value: _profile?['email'],
              icon: Icons.email_outlined,
              enabled: false,
            ),
            const SizedBox(height: 16),
            _buildBioField(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField({
    required String label,
    TextEditingController? controller,
    String? value,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _textMedium,
          ),
        ),
        const SizedBox(height: 6),
        if (enabled && controller != null)
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.cairo(color: _textDark, fontSize: 14),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: _friendlyBlue, size: 20),
              filled: true,
              fillColor: _inputFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _friendlyBlue, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: _softBlueTint,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borderLight),
            ),
            child: Row(
              children: [
                Icon(icon, color: _textLight, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller?.text ?? value ?? '',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نبذة عني',
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _textMedium,
          ),
        ),
        const SizedBox(height: 6),
        if (_isEditing)
          TextFormField(
            controller: _bioController,
            maxLines: 4,
            style: GoogleFonts.cairo(color: _textDark, fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: _inputFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _friendlyBlue, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _softBlueTint,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borderLight),
            ),
            child: Text(
              _bioController.text.isEmpty ? 'لا توجد نبذة' : _bioController.text,
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: _bioController.text.isEmpty ? _textLight : _textDark,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSkillsSection() {
    return Container(
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderLight, width: 1),
        boxShadow: _isDark
            ? []
            : [
                BoxShadow(
                  color: _friendlyBlue.withAlpha(8),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _isEditing
            ? Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableSkills.map((skill) {
                  final isSelected = _skills.contains(skill);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _skills.remove(skill);
                        } else {
                          _skills.add(skill);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? _friendlyBlue.withAlpha(30) : _softBlueTint,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? _friendlyBlue : _borderLight,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected)
                            Icon(Icons.check, color: _friendlyBlue, size: 16),
                          if (isSelected) const SizedBox(width: 4),
                          Text(
                            skill,
                            style: GoogleFonts.cairo(
                              color: isSelected ? _friendlyBlue : _textMedium,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              )
            : _skills.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'لم تضف أي مهارات بعد',
                        style: GoogleFonts.cairo(color: _textMedium, fontSize: 13),
                      ),
                    ),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _skills.map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _friendlyBlue.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _friendlyBlue.withAlpha(50), width: 1),
                        ),
                        child: Text(
                          skill,
                          style: GoogleFonts.cairo(
                            color: _friendlyBlue,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
      ),
    );
  }

  Widget _buildActionsSection() {
    final themeService = locator<ThemeService>();

    return Container(
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderLight, width: 1),
        boxShadow: _isDark
            ? []
            : [
                BoxShadow(
                  color: _friendlyBlue.withAlpha(8),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          // Theme Switcher Setting
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeService.themeModeNotifier,
            builder: (context, currentMode, _) {
              return Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.palette_outlined,
                    title: 'مظهر التطبيق',
                    subtitle: currentMode == ThemeMode.dark
                        ? 'الوضع الليلي مفعّل'
                        : currentMode == ThemeMode.light
                            ? 'الوضع النهاري مفعّل'
                            : 'تلقائي (حسب إعدادات النظام)',
                    color: const Color(0xFF8B5CF6),
                    trailingWidget: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currentMode == ThemeMode.dark
                              ? 'ليلي'
                              : currentMode == ThemeMode.light
                                  ? 'نهاري'
                                  : 'تلقائي',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _friendlyBlue,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios, size: 14, color: _textLight),
                      ],
                    ),
                    onTap: () => _showThemeSelectionDialog(currentMode),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 2, 16, 12),
                    child: Row(
                      children: [
                        _buildThemeSegmentButton(
                          icon: Icons.light_mode_rounded,
                          label: 'نهاري',
                          isSelected: currentMode == ThemeMode.light,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            themeService.setThemeMode(ThemeMode.light);
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildThemeSegmentButton(
                          icon: Icons.dark_mode_rounded,
                          label: 'ليلي',
                          isSelected: currentMode == ThemeMode.dark,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            themeService.setThemeMode(ThemeMode.dark);
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildThemeSegmentButton(
                          icon: Icons.brightness_auto_rounded,
                          label: 'تلقائي',
                          isSelected: currentMode == ThemeMode.system,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            themeService.setThemeMode(ThemeMode.system);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          Divider(color: _borderLight, height: 1, indent: 56),

          _buildMenuItem(
            icon: Icons.lock_outline,
            title: 'تغيير كلمة المرور',
            subtitle: 'تحديث كلمة المرور الخاصة بك',
            color: _friendlyBlue,
            onTap: _showChangePasswordDialog,
          ),
          Divider(color: _borderLight, height: 1, indent: 56),
          _buildMenuItem(
            icon: Icons.notifications_outlined,
            title: 'إعدادات الإشعارات',
            subtitle: 'تخصيص الإشعارات',
            color: Colors.orange,
            onTap: () {},
          ),
          Divider(color: _borderLight, height: 1, indent: 56),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'المساعدة والدعم',
            subtitle: 'تواصل مع فريق الدعم',
            color: _softTeal,
            onTap: () {},
          ),
          Divider(color: _borderLight, height: 1, indent: 56),
          _buildMenuItem(
            icon: Icons.logout,
            title: 'تسجيل الخروج',
            subtitle: '',
            color: Colors.red,
            onTap: _logout,
            isDanger: true,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSegmentButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (_isDark
                    ? _friendlyBlue.withAlpha(45)
                    : _friendlyBlue.withAlpha(20))
                : (_isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? _friendlyBlue
                  : (_isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? _friendlyBlue : _textMedium,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? _friendlyBlue : _textMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemeSelectionDialog(ThemeMode currentMode) {
    final themeService = locator<ThemeService>();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: _cardWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: _borderLight),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.palette_outlined, color: Color(0xFF8B5CF6), size: 22),
            ),
            const SizedBox(width: 12),
            Text(
              'مظهر التطبيق',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: _textDark,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeRadioTile(
              title: 'الوضع النهاري (فاتح)',
              subtitle: 'ألوان ساطعة مريحة للميدان المشمس',
              icon: Icons.light_mode_rounded,
              mode: ThemeMode.light,
              currentMode: currentMode,
              onSelect: () {
                HapticFeedback.selectionClick();
                themeService.setThemeMode(ThemeMode.light);
                Navigator.pop(dialogCtx);
              },
            ),
            const SizedBox(height: 8),
            _buildThemeRadioTile(
              title: 'الوضع الليلي (داكن)',
              subtitle: 'خلفية داكنة موفرة للطاقة ومريحة للعين',
              icon: Icons.dark_mode_rounded,
              mode: ThemeMode.dark,
              currentMode: currentMode,
              onSelect: () {
                HapticFeedback.selectionClick();
                themeService.setThemeMode(ThemeMode.dark);
                Navigator.pop(dialogCtx);
              },
            ),
            const SizedBox(height: 8),
            _buildThemeRadioTile(
              title: 'تلقائي (حسب النظام)',
              subtitle: 'يتزامن تلقائياً مع إعدادات جهازك',
              icon: Icons.brightness_auto_rounded,
              mode: ThemeMode.system,
              currentMode: currentMode,
              onSelect: () {
                HapticFeedback.selectionClick();
                themeService.setThemeMode(ThemeMode.system);
                Navigator.pop(dialogCtx);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'إغلاق',
              style: GoogleFonts.cairo(color: _textMedium, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeRadioTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required VoidCallback onSelect,
  }) {
    final isSelected = mode == currentMode;
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? _friendlyBlue.withAlpha(_isDark ? 35 : 18)
              : _softBlueTint,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _friendlyBlue : _borderLight,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? _friendlyBlue : _textMedium,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? _friendlyBlue : _textDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 10.5,
                      color: _textMedium,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: _friendlyBlue, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    Widget? trailingWidget,
    bool isDanger = false,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: isDanger ? Colors.red : _textDark,
        ),
      ),
      subtitle: subtitle.isNotEmpty
          ? Text(
              subtitle,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: _textMedium,
              ),
            )
          : null,
      trailing: trailingWidget ?? Icon(Icons.arrow_forward_ios, size: 14, color: _textLight),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
