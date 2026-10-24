import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/themes/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _identifierController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isButtonPressed = false;
  bool _isSubmitted = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  static const Duration entranceDuration = Duration(milliseconds: 450);
  static const Duration microDuration = Duration(milliseconds: 200);
  static const Curve entranceCurve = Curves.easeOutCubic;
  static const Curve microCurve = Curves.easeInOutCubic;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: entranceDuration,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: entranceCurve),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: entranceCurve));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _identifierController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      setState(() => _isButtonPressed = true);
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() {
        _isButtonPressed = false;
        _isLoading = true;
      });

      // Simulate sending reset instructions
      await Future.delayed(const Duration(milliseconds: 1200));

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSubmitted = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor = isDark ? AppColors.darkScaffold : const Color(0xFFF9FAFB);
    final Color cardColor = isDark ? AppColors.darkCard : Colors.white;
    final Color borderColor = isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB);
    final Color inputColor = isDark ? AppColors.darkSurface : const Color(0xFFF7FAFC);
    final Color primaryColor = isDark ? AppColors.primaryLight : const Color(0xFF1E7ABF);
    final Color titleColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937);
    final Color subtitleColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF6B7280);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: primaryColor, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _isSubmitted
                      ? _buildSuccessView(
                          isDark: isDark,
                          primaryColor: primaryColor,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          titleColor: titleColor,
                          subtitleColor: subtitleColor,
                        )
                      : _buildFormView(
                          isDark: isDark,
                          primaryColor: primaryColor,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          inputColor: inputColor,
                          titleColor: titleColor,
                          subtitleColor: subtitleColor,
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView({
    required bool isDark,
    required Color primaryColor,
    required Color cardColor,
    required Color borderColor,
    required Color inputColor,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),

        // Hero Icon
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : const Color(0xFFF3F8FC),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? AppColors.darkBorder : primaryColor.withAlpha(40),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withAlpha(isDark ? 30 : 20),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.lock_reset_rounded,
              size: 34,
              color: primaryColor,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Title
        Text(
          'استعادة كلمة المرور',
          style: GoogleFonts.cairo(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: titleColor,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        // Subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'أدخل البريد الإلكتروني أو رقم الهاتف المرتبط بحسابك وسنرسل لك تعليمات استعادة كلمة المرور.',
            style: GoogleFonts.cairo(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: subtitleColor,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 32),

        // Input Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withAlpha(40) : primaryColor.withAlpha(8),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'البريد الإلكتروني أو الهاتف',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 8),
                _buildInputField(
                  controller: _identifierController,
                  hint: 'example@domain.com أو 09xxxxxxxx',
                  icon: Icons.alternate_email_rounded,
                  inputColor: inputColor,
                  borderColor: borderColor,
                  primaryColor: primaryColor,
                  textColor: titleColor,
                  hintColor: isDark ? AppColors.darkTextHint : const Color(0xFF94A3B8),
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'يرجى إدخال البريد الإلكتروني أو رقم الهاتف';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 28),

        // Submit Button
        GestureDetector(
          onTapDown: (_) => setState(() => _isButtonPressed = true),
          onTapUp: (_) => setState(() => _isButtonPressed = false),
          onTapCancel: () => setState(() => _isButtonPressed = false),
          onTap: _isLoading ? null : _onSubmit,
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
                    primaryColor,
                    isDark ? const Color(0xFF0284C7) : const Color(0xFF3BB3A9),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withAlpha(_isButtonPressed ? 30 : 60),
                    blurRadius: _isButtonPressed ? 8 : 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'إرسال رمز الاستعادة',
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
        ),

        const SizedBox(height: 24),

        // Return to Login Link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'تذكرت كلمة المرور؟',
              style: GoogleFonts.cairo(
                color: subtitleColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text(
                'تسجيل الدخول',
                style: GoogleFonts.cairo(
                  color: primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSuccessView({
    required bool isDark,
    required Color primaryColor,
    required Color cardColor,
    required Color borderColor,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 36),
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withAlpha(isDark ? 40 : 20),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF10B981),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              size: 44,
              color: Color(0xFF10B981),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'تم إرسال التعليمات!',
          style: GoogleFonts.cairo(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: titleColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'تم إرسال رابط إعادة تعيين كلمة المرور إلى:\n${_identifierController.text.trim()}\nيرجى مراجعة رسائلك واتباع التعليمات.',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: subtitleColor,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 36),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            'العودة لتسجيل الدخول',
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            setState(() => _isSubmitted = false);
          },
          child: Text(
            'لم يصلك الرمز؟ إعادة المحاولة',
            style: GoogleFonts.cairo(
              color: subtitleColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color inputColor,
    required Color borderColor,
    required Color primaryColor,
    required Color textColor,
    required Color hintColor,
    required String? Function(String?) validator,
  }) {
    return Focus(
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          return AnimatedContainer(
            duration: microDuration,
            curve: microCurve,
            height: 48,
            decoration: BoxDecoration(
              color: inputColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasFocus ? primaryColor : borderColor,
                width: hasFocus ? 1.5 : 1,
              ),
              boxShadow: hasFocus
                  ? [
                      BoxShadow(
                        color: primaryColor.withAlpha(20),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              validator: validator,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: hintColor,
                ),
                prefixIcon: Icon(
                  icon,
                  size: 18,
                  color: hasFocus ? primaryColor : hintColor,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
            ),
          );
        },
      ),
    );
  }
}
