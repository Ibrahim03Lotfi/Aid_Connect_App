import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../core/theme/theme_service.dart';
import '../../../../services/locator.dart';
import '../../../auth/domain/entities/user.dart';
import '../bloc/profile_bloc/profile_bloc.dart';
import '../bloc/profile_bloc/profile_event.dart';
import '../bloc/profile_bloc/profile_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<ProfileBloc>()..add(const FetchProfileEvent()),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : const Color(0xFFF8FAFC),
      appBar: _buildAppBar(context, isDark),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is LogoutSuccess) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (route) => false,
            );
          } else if (state is ProfileUpdateSuccess) {
            _showStyledSnackBar(context, 'تم تحديث الملف الشخصي بنجاح', Icons.check_circle);
          } else if (state is PasswordChangeSuccess) {
            _showStyledSnackBar(context, 'تم تغيير كلمة المرور بنجاح', Icons.check_circle);
          } else if (state is ProfileError) {
            _showStyledSnackBar(context, state.message, Icons.error_outline, isError: true);
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return _buildLoadingView(isDark);
          }

          if (state is ProfileLoaded) {
            return _ProfileContent(user: state.user, isDark: isDark);
          }

          if (state is ProfileError) {
            return _buildErrorView(state.message, context, isDark);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
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
      // Aligned to Top Right in RTL
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
                'الملف الشخصي',
                style: GoogleFonts.cairo(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
              Text(
                'إعدادات الحساب والمظهر',
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
    );
  }

  void _showStyledSnackBar(BuildContext context, String message, IconData icon, {bool isError = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: isError ? Colors.red : const Color(0xFF10B981)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isError ? Colors.red.withAlpha(50) : const Color(0xFF10B981).withAlpha(50),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildLoadingView(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black38 : const Color(0xFF0284C7).withAlpha(20),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0284C7)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'جاري التحميل...',
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message, BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded, color: Colors.red, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              'حدث خطأ',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                context.read<ProfileBloc>().add(const FetchProfileEvent());
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'إعادة المحاولة',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final User user;
  final bool isDark;

  const _ProfileContent({required this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final themeService = locator<ThemeService>();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        // 1. Avatar & Profile Summary Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161F30) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark ? const Color(0xFF26334D) : const Color(0xFFE2E8F0),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black26 : const Color(0xFF0284C7).withAlpha(10),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0284C7).withAlpha(35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 43,
                  backgroundColor: Colors.transparent,
                  backgroundImage: user.avatar != null && user.avatar!.isNotEmpty
                      ? NetworkImage(user.avatar!)
                      : null,
                  child: user.avatar == null || user.avatar!.isEmpty
                      ? const Icon(
                          Icons.person_rounded,
                          size: 46,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                user.name,
                style: GoogleFonts.cairo(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                user.email,
                style: GoogleFonts.cairo(
                  fontSize: 12.5,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withAlpha(20),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  _formatRole(user.role),
                  style: GoogleFonts.cairo(
                    color: const Color(0xFF0284C7),
                    fontWeight: FontWeight.w800,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // 2. Interactive Theme Switcher Card (Dark / Light / System)
        ValueListenableBuilder<ThemeMode>(
          valueListenable: themeService.themeModeNotifier,
          builder: (context, currentMode, _) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161F30) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF26334D) : const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.palette_outlined,
                          color: Color(0xFF0284C7),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مظهر التطبيق',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'التبديل بين الوضع الليلي والنهاري',
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 3-Option Segmented Selector
                  Row(
                    children: [
                      _buildThemeOption(
                        context: context,
                        icon: Icons.light_mode_rounded,
                        label: 'نهاري',
                        isSelected: currentMode == ThemeMode.light,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          themeService.setThemeMode(ThemeMode.light);
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildThemeOption(
                        context: context,
                        icon: Icons.dark_mode_rounded,
                        label: 'ليلي',
                        isSelected: currentMode == ThemeMode.dark,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          themeService.setThemeMode(ThemeMode.dark);
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildThemeOption(
                        context: context,
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
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 18),

        // 3. Settings & Options Menu
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161F30) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0xFF26334D) : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _MenuItem(
                icon: Icons.bookmark_outline_rounded,
                title: 'المفضلة',
                subtitle: 'الحالات التي قمت بحفظها',
                iconBgColor: const Color(0xFF0284C7).withAlpha(18),
                iconColor: const Color(0xFF0284C7),
                isDark: isDark,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.favorites);
                },
              ),
              Divider(
                height: 1,
                color: isDark ? const Color(0xFF26334D) : const Color(0xFFE2E8F0),
                indent: 16,
                endIndent: 16,
              ),
              _MenuItem(
                icon: Icons.edit_outlined,
                title: 'تعديل الملف الشخصي',
                subtitle: 'تحديث الاسم ورقم الهاتف',
                iconBgColor: const Color(0xFF10B981).withAlpha(18),
                iconColor: const Color(0xFF10B981),
                isDark: isDark,
                onTap: () {
                  _showEditProfileDialog(context, user);
                },
              ),
              Divider(
                height: 1,
                color: isDark ? const Color(0xFF26334D) : const Color(0xFFE2E8F0),
                indent: 16,
                endIndent: 16,
              ),
              _MenuItem(
                icon: Icons.lock_outline_rounded,
                title: 'تغيير كلمة المرور',
                subtitle: 'حماية وتأمين الحساب',
                iconBgColor: Colors.amber.withAlpha(18),
                iconColor: Colors.amber.shade700,
                isDark: isDark,
                onTap: () {
                  _showChangePasswordDialog(context);
                },
              ),
              Divider(
                height: 1,
                color: isDark ? const Color(0xFF26334D) : const Color(0xFFE2E8F0),
                indent: 16,
                endIndent: 16,
              ),
              ValueListenableBuilder<ThemeMode>(
                valueListenable: themeService.themeModeNotifier,
                builder: (context, currentMode, _) {
                  return _MenuItem(
                    icon: Icons.palette_outlined,
                    title: 'مظهر التطبيق',
                    subtitle: currentMode == ThemeMode.dark
                        ? 'الوضع الليلي مفعّل'
                        : currentMode == ThemeMode.light
                            ? 'الوضع النهاري مفعّل'
                            : 'تلقائي (حسب إعدادات النظام)',
                    iconBgColor: const Color(0xFF8B5CF6).withAlpha(18),
                    iconColor: const Color(0xFF8B5CF6),
                    isDark: isDark,
                    onTap: () {
                      _showThemeSelectionDialog(context);
                    },
                  );
                },
              ),
              Divider(
                height: 1,
                color: isDark ? const Color(0xFF26334D) : const Color(0xFFE2E8F0),
                indent: 16,
                endIndent: 16,
              ),
              _MenuItem(
                icon: Icons.info_outline_rounded,
                title: 'حول التطبيق',
                subtitle: 'عن منصة أثر للإغاثة والتنمية',
                iconBgColor: const Color(0xFF0284C7).withAlpha(15),
                iconColor: const Color(0xFF0284C7),
                isDark: isDark,
                onTap: () {
                  _showAboutDialog(context);
                },
              ),
              Divider(
                height: 1,
                color: isDark ? const Color(0xFF26334D) : const Color(0xFFE2E8F0),
                indent: 16,
                endIndent: 16,
              ),
              _MenuItem(
                icon: Icons.logout_rounded,
                title: 'تسجيل الخروج',
                subtitle: 'الخروج من الحساب الحالي',
                iconBgColor: Colors.red.withAlpha(18),
                iconColor: Colors.red,
                textColor: Colors.red,
                isDark: isDark,
                onTap: () {
                  _showLogoutConfirmation(context);
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
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
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF0284C7)
                : (isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF0284C7)
                  : (isDark ? const Color(0xFF26334D) : const Color(0xFFE2E8F0)),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRole(String role) {
    switch (role.toLowerCase()) {
      case 'volunteer':
        return 'متطوع ميداني';
      case 'organization':
        return 'منظمة شريكة';
      case 'admin':
        return 'مسؤول المنصة';
      default:
        return 'مستخدم مساهم';
    }
  }

  void _showEditProfileDialog(BuildContext context, User user) {
    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phone);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF161F30) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'تعديل الملف الشخصي',
            style: GoogleFonts.cairo(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStyledTextField(
                controller: nameController,
                label: 'الاسم',
                icon: Icons.person_outline_rounded,
                isDark: isDark,
              ),
              const SizedBox(height: 14),
              _buildStyledTextField(
                controller: phoneController,
                label: 'رقم الهاتف',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                isDark: isDark,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'إلغاء',
                style: GoogleFonts.cairo(
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<ProfileBloc>().add(
                      UpdateProfileEvent(
                        name: nameController.text,
                        phone: phoneController.text,
                      ),
                    );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'حفظ',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF161F30) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                'تغيير كلمة المرور',
                style: GoogleFonts.cairo(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPasswordField(
                    controller: currentPasswordController,
                    label: 'كلمة المرور الحالية',
                    obscure: obscureCurrent,
                    isDark: isDark,
                    onToggle: () => setState(() => obscureCurrent = !obscureCurrent),
                  ),
                  const SizedBox(height: 10),
                  _buildPasswordField(
                    controller: newPasswordController,
                    label: 'كلمة المرور الجديدة',
                    obscure: obscureNew,
                    isDark: isDark,
                    onToggle: () => setState(() => obscureNew = !obscureNew),
                  ),
                  const SizedBox(height: 10),
                  _buildPasswordField(
                    controller: confirmPasswordController,
                    label: 'تأكيد كلمة المرور',
                    obscure: obscureConfirm,
                    isDark: isDark,
                    onToggle: () => setState(() => obscureConfirm = !obscureConfirm),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    'إلغاء',
                    style: GoogleFonts.cairo(
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (newPasswordController.text != confirmPasswordController.text) {
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('كلمات المرور غير متطابقة')),
                      );
                      return;
                    }
                    Navigator.pop(dialogContext);
                    context.read<ProfileBloc>().add(
                          ChangePasswordEvent(
                            currentPassword: currentPasswordController.text,
                            newPassword: newPasswordController.text,
                          ),
                        );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'تغيير',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF26334D) : const Color(0xFFE2E8F0),
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.cairo(
          color: isDark ? Colors.white : const Color(0xFF0F172A),
          fontSize: 13,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.cairo(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            fontSize: 13,
          ),
          prefixIcon: Icon(icon, color: const Color(0xFF0284C7), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required bool isDark,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF26334D) : const Color(0xFFE2E8F0),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: GoogleFonts.cairo(
          color: isDark ? Colors.white : const Color(0xFF0F172A),
          fontSize: 13,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.cairo(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            fontSize: 13,
          ),
          prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF0284C7), size: 20),
          suffixIcon: IconButton(
            icon: Icon(
              obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              size: 20,
            ),
            onPressed: onToggle,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF161F30) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'تسجيل الخروج',
            style: GoogleFonts.cairo(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          content: Text(
            'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
            style: GoogleFonts.cairo(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              fontSize: 13.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'إلغاء',
                style: GoogleFonts.cairo(
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<ProfileBloc>().add(const LogoutEvent());
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'تسجيل الخروج',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF161F30) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'أثر',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'منصة أثر للإغاثة والتنمية',
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          content: Text(
            'منظومة إنسانية رقمية متكاملة لربط المتبرعين والمنظمات الإنسانية والفرق الميدانية في سوريا، وتوثيق الحالات ومتابعة التبرعات بشفافية كاملة عبر بطاقات شام كاش وتقنيات التحقق الميداني.\n\nالإصدار: 2.0.0 (2026)',
            style: GoogleFonts.cairo(
              fontSize: 12.5,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'إغلاق',
                style: GoogleFonts.cairo(
                  color: const Color(0xFF0284C7),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showThemeSelectionDialog(BuildContext context) {
    final themeService = locator<ThemeService>();
    final currentMode = themeService.themeMode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF161F30) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDark ? const Color(0xFF26334D) : const Color(0xFFE2E8F0),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0284C7).withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.palette_outlined, color: Color(0xFF0284C7), size: 22),
            ),
            const SizedBox(width: 12),
            Text(
              'مظهر التطبيق',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeRadioTile(
              title: 'الوضع النهاري (فاتح)',
              subtitle: 'ألوان ساطعة مريحة للقراءة',
              icon: Icons.light_mode_rounded,
              mode: ThemeMode.light,
              currentMode: currentMode,
              isDark: isDark,
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
              isDark: isDark,
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
              isDark: isDark,
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
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
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
    required bool isDark,
    required VoidCallback onSelect,
  }) {
    final isSelected = currentMode == mode;
    final primaryColor = const Color(0xFF0284C7);

    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withAlpha(isDark ? 35 : 18)
              : (isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : (isDark ? const Color(0xFF26334D) : const Color(0xFFE2E8F0)),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor.withAlpha(25)
                    : (isDark ? const Color(0xFF1E293B) : const Color(0xFFEDF2F7)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? primaryColor : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
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
                      color: isSelected
                          ? primaryColor
                          : (isDark ? Colors.white : const Color(0xFF0F172A)),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
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
                  color: isSelected ? primaryColor : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                  width: 2,
                ),
                color: isSelected ? primaryColor : Colors.transparent,
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
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconBgColor;
  final Color iconColor;
  final Color? textColor;
  final bool isDark;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconBgColor,
    required this.iconColor,
    required this.isDark,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: textColor ?? (isDark ? Colors.white : const Color(0xFF0F172A)),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.cairo(
          fontSize: 11,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: isDark ? const Color(0xFF64748B) : const Color(0xFFCBD5E1),
      ),
    );
  }
}
