import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../core/theme/theme_service.dart';
import '../../../../services/locator.dart';
import '../bloc/org_profile_bloc/org_profile_bloc.dart';
import '../bloc/org_profile_bloc/org_profile_event.dart';
import '../bloc/org_profile_bloc/org_profile_state.dart';
import '../../domain/entities/org_profile.dart';
import '../../domain/repositories/organization_repository.dart';

class OrgProfileScreen extends StatelessWidget {
  const OrgProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          OrgProfileBloc(repository: locator<OrganizationRepository>())
            ..add(const LoadProfile()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  bool get _isDark => mounted && Theme.of(context).brightness == Brightness.dark;
  Color get backgroundOffWhite => _isDark ? AppColors.darkScaffold : const Color(0xFFF9FAFB);
  Color get softBlueTint => _isDark ? const Color(0xFF1E293B) : const Color(0xFFF3F8FC);
  Color get friendlyBlue => _isDark ? const Color(0xFF60A5FA) : const Color(0xFF1E7ABF);
  Color get softTeal => const Color(0xFF3BB3A9);
  Color get textDark => _isDark ? Colors.white : const Color(0xFF1F2937);
  Color get textMedium => _isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);
  Color get textLight => _isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
  Color get cardWhite => _isDark ? AppColors.darkCard : const Color(0xFFFFFFFF);
  Color get borderLight => _isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB);
  Color get inputFill => _isDark ? const Color(0xFF0F172A) : const Color(0xFFF7FAFC);

  bool _isEditing = false;
  OrgProfile? _currentProfile;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _websiteController = TextEditingController();
  final _registrationNumberController = TextEditingController();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordFormKey = GlobalKey<FormState>();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    _registrationNumberController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _loadOrgData(OrgProfile profile) {
    _currentProfile = profile;
    _nameController.text = profile.name;
    _emailController.text = profile.email;
    _phoneController.text = profile.phone;
    _addressController.text = profile.address;
    _descriptionController.text = profile.description;
    _registrationNumberController.text = profile.registrationNumber;
  }

  Future<void> _saveProfile() async {
    context.read<OrgProfileBloc>().add(
      UpdateProfile(
        name: _nameController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        description: _descriptionController.text,
        registrationNumber: _registrationNumberController.text,
      ),
    );
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    await Future.delayed(const Duration(seconds: 1));

    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    if (mounted) {
      Navigator.pop(context);
      _showSnackBar('تم تغيير كلمة المرور بنجاح!', softTeal);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: friendlyBlue.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.lock_outline, color: friendlyBlue),
            ),
            const SizedBox(width: 12),
            const Text('تغيير كلمة المرور'),
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
                  onToggle: () => setState(
                    () => _obscureCurrentPassword = !_obscureCurrentPassword,
                  ),
                  validator: (v) => v?.isEmpty ?? true
                      ? 'يرجى إدخال كلمة المرور الحالية'
                      : null,
                ),
                const SizedBox(height: 12),
                _buildPasswordField(
                  controller: _newPasswordController,
                  label: 'كلمة المرور الجديدة',
                  isObscure: _obscureNewPassword,
                  onToggle: () => setState(
                    () => _obscureNewPassword = !_obscureNewPassword,
                  ),
                  validator: (v) {
                    if (v?.isEmpty ?? true)
                      return 'يرجى إدخال كلمة المرور الجديدة';
                    if (v!.length < 8) return 'يجب أن تكون 8 أحرف على الأقل';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  label: 'تأكيد كلمة المرور',
                  isObscure: _obscureConfirmPassword,
                  onToggle: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  ),
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'يرجى تأكيد كلمة المرور';
                    if (v != _newPasswordController.text)
                      return 'كلمات المرور غير متطابقة';
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
            child: Text('إلغاء', style: TextStyle(color: textMedium)),
          ),
          GestureDetector(
            onTap: _changePassword,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [friendlyBlue, softTeal],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'تغيير',
                style: TextStyle(
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
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textMedium, fontSize: 13),
        prefixIcon: Icon(Icons.lock_outline, color: friendlyBlue, size: 20),
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Icon(
            isObscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: textLight,
            size: 20,
          ),
        ),
        filled: true,
        fillColor: inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: friendlyBlue, width: 1.5),
        ),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.logout, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text('تأكيد تسجيل الخروج'),
          ],
        ),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: TextStyle(color: textMedium)),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
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
              child: const Text(
                'خروج',
                style: TextStyle(
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
    return BlocListener<OrgProfileBloc, OrgProfileState>(
      listener: (context, state) {
        if (state is OrgProfileLoaded) {
          _loadOrgData(state.profile);
        } else if (state is OrgProfileUpdated) {
          setState(() => _isEditing = false);
          _showSnackBar('تم حفظ البيانات بنجاح!', softTeal);
          context.read<OrgProfileBloc>().add(const LoadProfile());
        } else if (state is OrgProfileError) {
          _showSnackBar(state.message, Colors.red);
        }
      },
      child: BlocBuilder<OrgProfileBloc, OrgProfileState>(
        builder: (context, state) {
          if (state is OrgProfileLoading && _currentProfile == null) {
            return Scaffold(
              backgroundColor: backgroundOffWhite,
              appBar: AppBar(
                backgroundColor: backgroundOffWhite,
                elevation: 0,
                title: Text(
                  'الملف الشخصي',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
                ),
                centerTitle: true,
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            backgroundColor: backgroundOffWhite,
            appBar: AppBar(
              backgroundColor: backgroundOffWhite,
              elevation: 0,
              title: Text(
                'الملف الشخصي',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
              centerTitle: true,
              actions: [
                if (!_isEditing)
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cardWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderLight, width: 1),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        color: friendlyBlue,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _isEditing = true),
                    ),
                  )
                else
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [friendlyBlue, softTeal],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: state is OrgProfileLoading
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: state is OrgProfileLoading
                                ? null
                                : _saveProfile,
                          ),
                  ),
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 28),
                    _buildSectionTitle('معلومات المنظمة'),
                    const SizedBox(height: 16),
                    _buildOrgInfoSection(),
                    const SizedBox(height: 28),
                    _buildSectionTitle('معلومات التواصل'),
                    const SizedBox(height: 16),
                    _buildContactSection(),
                    const SizedBox(height: 28),
                    _buildSectionTitle('الإعدادات'),
                    const SizedBox(height: 16),
                    _buildActionsSection(),
                  ],
                ),
              ),
            ),
          );
        },
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
                    colors: [friendlyBlue, softTeal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: friendlyBlue.withAlpha(30),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.business,
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
                      color: cardWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderLight),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(10),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      size: 18,
                      color: friendlyBlue,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _nameController.text,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _currentProfile != null
                ? 'عضو منذ ${_currentProfile!.joinedAt}'
                : '',
            style: TextStyle(fontSize: 14, color: textMedium),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: softTeal.withAlpha(20),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: softTeal.withAlpha(50), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_rounded, color: softTeal, size: 16),
                const SizedBox(width: 4),
                Text(
                  'منظمة معتمدة',
                  style: TextStyle(
                    color: softTeal,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: friendlyBlue,
      ),
    );
  }

  Widget _buildOrgInfoSection() {
    return Container(
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: friendlyBlue.withAlpha(8),
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
              label: 'اسم المنظمة',
              controller: _nameController,
              icon: Icons.business_outlined,
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            _buildInfoField(
              label: 'الرقم الضريبي',
              controller: _registrationNumberController,
              icon: Icons.numbers_outlined,
              enabled: false,
            ),
            const SizedBox(height: 16),
            _buildInfoField(
              label: 'الموقع الإلكتروني',
              controller: _websiteController,
              icon: Icons.language_outlined,
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            _buildDescriptionField(),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: friendlyBlue.withAlpha(8),
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
              label: 'البريد الإلكتروني',
              controller: _emailController,
              icon: Icons.email_outlined,
              enabled: _isEditing,
              keyboardType: TextInputType.emailAddress,
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
              label: 'العنوان',
              controller: _addressController,
              icon: Icons.location_on_outlined,
              enabled: _isEditing,
              maxLines: 2,
            ),
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
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textMedium,
          ),
        ),
        const SizedBox(height: 6),
        if (enabled && controller != null)
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: friendlyBlue, size: 20),
              filled: true,
              fillColor: inputFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: friendlyBlue, width: 1.5),
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
              color: softBlueTint,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderLight),
            ),
            child: Row(
              children: [
                Icon(icon, color: textLight, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller?.text ?? value ?? '',
                    style: TextStyle(fontSize: 14, color: textDark),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نبذة عن المنظمة',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textMedium,
          ),
        ),
        const SizedBox(height: 6),
        if (_isEditing)
          TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              filled: true,
              fillColor: inputFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: friendlyBlue, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: softBlueTint,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderLight),
            ),
            child: Text(
              _descriptionController.text,
              style: TextStyle(fontSize: 14, color: textDark),
            ),
          ),
      ],
    );
  }

  Widget _buildActionsSection() {
    return Container(
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderLight, width: 1),
        boxShadow: _isDark
            ? []
            : [
                BoxShadow(
                  color: friendlyBlue.withAlpha(8),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          // Theme Switcher Setting
          ValueListenableBuilder<ThemeMode>(
            valueListenable: locator<ThemeService>().themeModeNotifier,
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
                            color: friendlyBlue,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios, size: 14, color: textLight),
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
                            locator<ThemeService>().setThemeMode(ThemeMode.light);
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildThemeSegmentButton(
                          icon: Icons.dark_mode_rounded,
                          label: 'ليلي',
                          isSelected: currentMode == ThemeMode.dark,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            locator<ThemeService>().setThemeMode(ThemeMode.dark);
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildThemeSegmentButton(
                          icon: Icons.brightness_auto_rounded,
                          label: 'تلقائي',
                          isSelected: currentMode == ThemeMode.system,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            locator<ThemeService>().setThemeMode(ThemeMode.system);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          Divider(color: borderLight, height: 1, indent: 56),
          _buildMenuItem(
            icon: Icons.lock_outline,
            title: 'تغيير كلمة المرور',
            subtitle: 'تحديث كلمة المرور الخاصة بك',
            color: friendlyBlue,
            onTap: _showChangePasswordDialog,
          ),
          Divider(color: borderLight, height: 1, indent: 56),
          _buildMenuItem(
            icon: Icons.notifications_outlined,
            title: 'إعدادات الإشعارات',
            subtitle: 'تخصيص الإشعارات',
            color: Colors.orange,
            onTap: () {},
          ),
          Divider(color: borderLight, height: 1, indent: 56),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'المساعدة والدعم',
            subtitle: 'تواصل مع فريق الدعم',
            color: softTeal,
            onTap: () {},
          ),
          Divider(color: borderLight, height: 1, indent: 56),
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
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? friendlyBlue
                : (_isDark ? const Color(0xFF0C1220) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? friendlyBlue
                  : (_isDark ? AppColors.darkBorder : borderLight),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected
                    ? Colors.white
                    : (_isDark ? const Color(0xFF94A3B8) : textMedium),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (_isDark ? const Color(0xFFCBD5E1) : textDark),
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
        backgroundColor: cardWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: borderLight),
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
                color: textDark,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeRadioTile(
              title: 'الوضع النهاري (فاتح)',
              subtitle: 'ألوان ساطعة مريحة للعمل اليومي',
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
              style: GoogleFonts.cairo(
                color: textMedium,
                fontWeight: FontWeight.w700,
              ),
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
    final isSelected = currentMode == mode;

    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? friendlyBlue.withAlpha(_isDark ? 35 : 18)
              : (_isDark ? const Color(0xFF0C1220) : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? friendlyBlue
                : (_isDark ? AppColors.darkBorder : borderLight),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? friendlyBlue.withAlpha(25)
                    : (_isDark ? const Color(0xFF1E293B) : const Color(0xFFEDF2F7)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? friendlyBlue : textMedium,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 13.5,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? friendlyBlue : textDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: textMedium,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? friendlyBlue : (_isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                  width: 2,
                ),
                color: isSelected ? friendlyBlue : Colors.transparent,
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(Icons.check, size: 13, color: Colors.white),
                    )
                  : null,
            ),
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
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDanger ? Colors.red : textDark,
        ),
      ),
      subtitle: subtitle.isNotEmpty
          ? Text(subtitle, style: TextStyle(fontSize: 12, color: textMedium))
          : null,
      trailing: trailingWidget ?? Icon(Icons.arrow_forward_ios, size: 16, color: textLight),
    );
  }
}
