import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../services/locator.dart';
import '../../../../shared/constants/app_constants.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class OrganizationRequestScreen extends StatelessWidget {
  const OrganizationRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<AuthBloc>(),
      child: const OrganizationRequestView(),
    );
  }
}

class OrganizationRequestView extends StatefulWidget {
  const OrganizationRequestView({super.key});

  @override
  State<OrganizationRequestView> createState() => _OrganizationRequestViewState();
}

class _OrganizationRequestViewState extends State<OrganizationRequestView>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isButtonPressed = false;

  late AnimationController _headlineController;
  late AnimationController _formController;
  late Animation<double> _headlineFade;
  late Animation<Offset> _headlineSlide;
  late Animation<double> _formFade;

  // Base Light Colors
  static const Color backgroundColor = Color(0xFFF9FAFB);
  static const Color surfaceColor = Colors.white;
  static const Color sectionTint = Color(0xFFF3F8FC);
  static const Color friendlyBlue = Color(0xFF1E7ABF);
  static const Color softTeal = Color(0xFF3BB3A9);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color inputFill = Color(0xFFF7FAFC);

  // Animation Timing
  static const Duration entranceDuration = Duration(milliseconds: 450);
  static const Duration microDuration = Duration(milliseconds: 250);
  static const Curve entranceCurve = Curves.easeOutCubic;
  static const Curve microCurve = Curves.easeInOutCubic;

  @override
  void initState() {
    super.initState();

    _headlineController = AnimationController(
      vsync: this,
      duration: entranceDuration,
    );

    _headlineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headlineController, curve: entranceCurve),
    );
    _headlineSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headlineController, curve: entranceCurve));

    _formController = AnimationController(
      vsync: this,
      duration: entranceDuration,
    );

    _formFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _formController,
        curve: const Interval(0.2, 1.0, curve: entranceCurve),
      ),
    );

    _headlineController.forward();
    _formController.forward();
  }

  @override
  void dispose() {
    _headlineController.dispose();
    _formController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _registrationNumberController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onSubmitPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(SubmitOrganizationRequestEvent(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            address: _addressController.text.trim(),
            description: _descriptionController.text.trim(),
            registrationNumber: _registrationNumberController.text.trim(),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor = isDark ? AppColors.darkScaffold : backgroundColor;
    final Color activePrimary = isDark ? AppColors.primaryLight : friendlyBlue;
    final Color cardBg = isDark ? AppColors.darkCard : surfaceColor;
    final Color cardBorder = isDark ? AppColors.darkBorder : borderLight;
    final Color titleColor = isDark ? AppColors.primaryLight : friendlyBlue;
    final Color subtitleColor = isDark ? AppColors.darkTextSecondary : textSecondary;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is OrganizationRequestSubmitted) {
            _showSuccessDialog(context, isDark, activePrimary);
          } else if (state is AuthFormState && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage!,
                  style: GoogleFonts.cairo(color: Colors.white),
                ),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: activePrimary, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // HERO SECTION
                  FadeTransition(
                    opacity: _headlineFade,
                    child: SlideTransition(
                      position: _headlineSlide,
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCard : sectionTint,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? AppColors.darkBorder : activePrimary.withAlpha(30),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: activePrimary.withAlpha(isDark ? 25 : 15),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.business_outlined,
                              size: 32,
                              color: activePrimary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'تسجيل منظمة جديدة',
                            style: GoogleFonts.cairo(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: titleColor,
                              height: 1.3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'سجّل منظمتك لتكون جزءًا من شبكة العطاء',
                            style: GoogleFonts.cairo(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: subtitleColor,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // INFO CARD
                  FadeTransition(
                    opacity: _formFade,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : sectionTint,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : activePrimary.withAlpha(30),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: activePrimary,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'سيتم مراجعة طلبك من قبل الإدارة والتواصل معك خلال 48 ساعة',
                              style: GoogleFonts.cairo(
                                color: subtitleColor,
                                fontSize: 13,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // FORM SECTION
                  FadeTransition(
                    opacity: _formFade,
                    child: Form(
                      key: _formKey,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: cardBorder,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withAlpha(40)
                                  : activePrimary.withAlpha(8),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Organization Name
                            _buildSoftInputField(
                              controller: _nameController,
                              label: 'اسم المنظمة',
                              icon: Icons.business_outlined,
                              isDark: isDark,
                              activePrimary: activePrimary,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return ValidationMessages.requiredField;
                                }
                                if (value!.length < 3) {
                                  return 'اسم المنظمة يجب أن يكون 3 أحرف على الأقل';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // Email
                            _buildSoftInputField(
                              controller: _emailController,
                              label: 'البريد الإلكتروني',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              textDirection: TextDirection.ltr,
                              isDark: isDark,
                              activePrimary: activePrimary,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return ValidationMessages.requiredField;
                                }
                                if (!value!.contains('@')) {
                                  return ValidationMessages.invalidEmail;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // Phone
                            _buildSoftInputField(
                              controller: _phoneController,
                              label: 'رقم الهاتف',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              textDirection: TextDirection.ltr,
                              suffixText: '09',
                              maxLength: 8,
                              isDark: isDark,
                              activePrimary: activePrimary,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return ValidationMessages.requiredField;
                                }
                                if (value!.length != 8) {
                                  return 'يجب إدخال 8 أرقام بعد 09';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // Address
                            _buildSoftInputField(
                              controller: _addressController,
                              label: 'العنوان',
                              icon: Icons.location_on_outlined,
                              isDark: isDark,
                              activePrimary: activePrimary,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return ValidationMessages.requiredField;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // Registration Number (Optional)
                            _buildSoftInputField(
                              controller: _registrationNumberController,
                              label: 'رقم الإشهار / الترخيص (اختياري)',
                              icon: Icons.badge_outlined,
                              isDark: isDark,
                              activePrimary: activePrimary,
                              validator: (_) => null,
                            ),
                            const SizedBox(height: 14),

                            // Description (Optional)
                            _buildSoftTextArea(
                              controller: _descriptionController,
                              label: 'نبذة عن أنشطة المنظمة وأهدافها',
                              icon: Icons.description_outlined,
                              isDark: isDark,
                              activePrimary: activePrimary,
                              validator: (_) => null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Submit Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthFormState && state.isLoading;
                      return GestureDetector(
                        onTapDown: (_) => setState(() => _isButtonPressed = true),
                        onTapUp: (_) => setState(() => _isButtonPressed = false),
                        onTapCancel: () => setState(() => _isButtonPressed = false),
                        onTap: isLoading ? null : _onSubmitPressed,
                        child: AnimatedScale(
                          scale: _isButtonPressed ? 0.97 : 1.0,
                          duration: microDuration,
                          curve: microCurve,
                          child: Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  activePrimary,
                                  isDark ? const Color(0xFF0284C7) : softTeal,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: activePrimary.withAlpha(_isButtonPressed ? 30 : 50),
                                  blurRadius: _isButtonPressed ? 8 : 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(
                                      'إرسال طلب التسجيل',
                                      style: GoogleFonts.cairo(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Secondary Action (Cancel)
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'إلغاء والعودة',
                        style: GoogleFonts.cairo(
                          color: subtitleColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, bool isDark, Color activePrimary) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: isDark ? const BorderSide(color: AppColors.darkBorder) : BorderSide.none,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withAlpha(isDark ? 30 : 15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 36,
                color: Color(0xFF10B981),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'تم استلام الطلب',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'تم إرسال طلب تسجيل منظمتك بنجاح. سيتم مراجعة طلبك والتواصل معك خلال 48 ساعة.',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 13.5,
                color: isDark ? AppColors.darkTextSecondary : textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                decoration: BoxDecoration(
                  color: activePrimary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'حسناً',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SOFT MODERN INPUT FIELD
  Widget _buildSoftInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    required bool isDark,
    required Color activePrimary,
    TextInputType? keyboardType,
    TextDirection? textDirection,
    String? suffixText,
    int? maxLength,
  }) {
    final Color fieldFill = isDark ? AppColors.darkSurface : inputFill;
    final Color borderNormal = isDark ? AppColors.darkBorder : borderLight;
    final Color textColor = isDark ? AppColors.darkTextPrimary : textPrimary;
    final Color hintColor = isDark ? AppColors.darkTextHint : textSecondary.withAlpha(180);

    return Focus(
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          return AnimatedContainer(
            duration: microDuration,
            curve: microCurve,
            height: 48,
            decoration: BoxDecoration(
              color: fieldFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasFocus ? activePrimary : borderNormal,
                width: hasFocus ? 1.5 : 1,
              ),
              boxShadow: hasFocus
                  ? [
                      BoxShadow(
                        color: activePrimary.withAlpha(20),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              textDirection: textDirection,
              validator: validator,
              maxLength: maxLength,
              buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
              textAlign: textDirection == TextDirection.ltr ? TextAlign.left : TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
              decoration: InputDecoration(
                hintText: null,
                labelText: null,
                prefixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 12),
                    Icon(
                      icon,
                      size: 18,
                      color: hasFocus ? activePrimary : hintColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: hintColor,
                      ),
                    ),
                  ],
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                suffixIcon: suffixText != null
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: activePrimary.withAlpha(15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            suffixText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: activePrimary,
                            ),
                          ),
                        ),
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
          );
        },
      ),
    );
  }

  // SOFT MODERN TEXT AREA (Multi-line)
  Widget _buildSoftTextArea({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    required bool isDark,
    required Color activePrimary,
  }) {
    final Color fieldFill = isDark ? AppColors.darkSurface : inputFill;
    final Color borderNormal = isDark ? AppColors.darkBorder : borderLight;
    final Color textColor = isDark ? AppColors.darkTextPrimary : textPrimary;
    final Color hintColor = isDark ? AppColors.darkTextHint : textSecondary.withAlpha(180);

    return Focus(
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          return AnimatedContainer(
            duration: microDuration,
            curve: microCurve,
            decoration: BoxDecoration(
              color: fieldFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasFocus ? activePrimary : borderNormal,
                width: hasFocus ? 1.5 : 1,
              ),
              boxShadow: hasFocus
                  ? [
                      BoxShadow(
                        color: activePrimary.withAlpha(20),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: TextFormField(
              controller: controller,
              validator: validator,
              maxLines: 4,
              minLines: 3,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
                height: 1.5,
              ),
              decoration: InputDecoration(
                hintText: null,
                labelText: null,
                prefixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 12),
                    Icon(
                      icon,
                      size: 18,
                      color: hasFocus ? activePrimary : hintColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: hintColor,
                      ),
                    ),
                  ],
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                alignLabelWithHint: true,
              ),
            ),
          );
        },
      ),
    );
  }
}
