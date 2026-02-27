import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../services/locator.dart';
import '../../../../shared/constants/app_constants.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<AuthBloc>(),
      child: const RegisterView(),
    );
  }
}

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isButtonPressed = false;

  late AnimationController _headlineController;
  late AnimationController _formController;
  late Animation<double> _headlineFade;
  late Animation<Offset> _headlineSlide;
  late Animation<double> _formFade;

  // LIGHT OF IMPACT COLOR SYSTEM
  static const Color backgroundColor = Color(0xFFF9FAFB);
  static const Color surfaceColor = Colors.white;
  static const Color sectionTint = Color(0xFFF3F8FC);
  static const Color friendlyBlue = Color(0xFF1E7ABF);
  static const Color softTeal = Color(0xFF3BB3A9);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color inputFill = Color(0xFFF7FAFC);

  // ANIMATION TIMING
  static const Duration entranceDuration = Duration(milliseconds: 450);
  static const Duration microDuration = Duration(milliseconds: 250);
  static const Curve entranceCurve = Curves.easeOutCubic;
  static const Curve microCurve = Curves.easeInOutCubic;

  @override
  void initState() {
    super.initState();

    // Headline entrance animation
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

    // Form entrance animation
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

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _headlineController.dispose();
    _formController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(RegisterEvent(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            password: _passwordController.text,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        } else if (state is AuthFormState && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: friendlyBlue),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                // HERO SECTION - Compact
                FadeTransition(
                  opacity: _headlineFade,
                  child: SlideTransition(
                    position: _headlineSlide,
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: sectionTint,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: friendlyBlue.withAlpha(15),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_add_outlined,
                            size: 28,
                            color: friendlyBlue,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'انضم إلى مجتمع الأثر',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: friendlyBlue,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'سجّل الآن وكن جزءًا من التغيير الإيجابي',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: textSecondary,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // FORM SECTION - Compact Card
                FadeTransition(
                  opacity: _formFade,
                  child: Form(
                    key: _formKey,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: friendlyBlue.withAlpha(8),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Name Field
                          _buildSoftInputField(
                            controller: _nameController,
                            label: 'الاسم الكامل',
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return ValidationMessages.requiredField;
                              }
                              if (value!.length < 3) {
                                return 'الاسم يجب أن يكون 3 أحرف على الأقل';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Email Field
                          _buildSoftInputField(
                            controller: _emailController,
                            label: 'البريد الإلكتروني',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            textDirection: TextDirection.ltr,
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
                          const SizedBox(height: 12),

                          // Phone Field
                          _buildSoftInputField(
                            controller: _phoneController,
                            label: 'رقم الهاتف',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            textDirection: TextDirection.ltr,
                            suffixText: '09',
                            maxLength: 8,
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
                          const SizedBox(height: 12),

                          // Password Field
                          _buildSoftPasswordField(
                            controller: _passwordController,
                            label: 'كلمة المرور',
                            isVisible: _isPasswordVisible,
                            onToggleVisibility: () {
                              setState(() => _isPasswordVisible = !_isPasswordVisible);
                            },
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return ValidationMessages.requiredField;
                              }
                              if (value!.length < 6) {
                                return ValidationMessages.passwordTooShort;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Confirm Password Field
                          _buildSoftPasswordField(
                            controller: _confirmPasswordController,
                            label: 'تأكيد كلمة المرور',
                            isVisible: _isConfirmPasswordVisible,
                            onToggleVisibility: () {
                              setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
                            },
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return ValidationMessages.requiredField;
                              }
                              if (value != _passwordController.text) {
                                return ValidationMessages.passwordsNotMatch;
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Primary Button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthFormState && state.isLoading;
                    return GestureDetector(
                      onTapDown: (_) => setState(() => _isButtonPressed = true),
                      onTapUp: (_) => setState(() => _isButtonPressed = false),
                      onTapCancel: () => setState(() => _isButtonPressed = false),
                      onTap: isLoading ? null : _onRegisterPressed,
                      child: AnimatedContainer(
                        duration: microDuration,
                        curve: microCurve,
                        transform: Matrix4.identity()..scale(_isButtonPressed ? 0.97 : 1.0),
                        child: Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [friendlyBlue, softTeal],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: friendlyBlue.withAlpha(_isButtonPressed ? 30 : 50),
                                blurRadius: _isButtonPressed ? 8 : 14,
                                offset: const Offset(0, 4),
                                spreadRadius: 0,
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
                                : const Text(
                                    'إنشاء حساب',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
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

                // Secondary Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'لديك حساب بالفعل؟',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: friendlyBlue.withAlpha(10),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'تسجيل الدخول',
                          style: TextStyle(
                            color: friendlyBlue,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      ),
    );
    
  }

  // SOFT MODERN INPUT FIELD with visible border and icon+label layout
  Widget _buildSoftInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    TextDirection? textDirection,
    String? suffixText,
    int? maxLength,
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
              color: inputFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasFocus ? friendlyBlue.withAlpha(100) : borderLight,
                width: hasFocus ? 1.5 : 1,
              ),
              boxShadow: hasFocus
                  ? [
                      BoxShadow(
                        color: friendlyBlue.withAlpha(20),
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
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textPrimary,
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
                      color: hasFocus ? friendlyBlue : textSecondary.withAlpha(150),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: textSecondary.withAlpha(180),
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
                            color: friendlyBlue.withAlpha(15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            suffixText,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: friendlyBlue,
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

  // SOFT MODERN PASSWORD FIELD with visible border and icon+label layout
  Widget _buildSoftPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
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
              color: inputFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasFocus ? friendlyBlue.withAlpha(100) : borderLight,
                width: hasFocus ? 1.5 : 1,
              ),
              boxShadow: hasFocus
                  ? [
                      BoxShadow(
                        color: friendlyBlue.withAlpha(20),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: TextFormField(
              controller: controller,
              obscureText: !isVisible,
              textDirection: TextDirection.ltr,
              validator: validator,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textPrimary,
              ),
              decoration: InputDecoration(
                hintText: null,
                labelText: null,
                prefixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 12),
                    Icon(
                      Icons.lock_outline,
                      size: 18,
                      color: hasFocus ? friendlyBlue : textSecondary.withAlpha(150),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: textSecondary.withAlpha(180),
                      ),
                    ),
                  ],
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                suffixIcon: GestureDetector(
                  onTap: onToggleVisibility,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isVisible ? friendlyBlue.withAlpha(20) : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 16,
                      color: isVisible ? friendlyBlue : textSecondary.withAlpha(150),
                    ),
                  ),
                ),
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
}
