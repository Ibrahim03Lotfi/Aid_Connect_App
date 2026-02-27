import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is OrganizationRequestSubmitted) {
          _showSuccessDialog(context);
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
                            color: sectionTint,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: friendlyBlue.withAlpha(15),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.business_outlined,
                            size: 32,
                            color: friendlyBlue,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'تسجيل منظمة جديدة',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: friendlyBlue,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'سجّل منظمتك لتكون جزءًا من شبكة العطاء',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: textSecondary,
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
                      color: sectionTint,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: friendlyBlue.withAlpha(30)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: friendlyBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'سيتم مراجعة طلبك من قبل الإدارة والتواصل معك خلال 48 ساعة',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 13,
                              height: 1.5,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Organization Name
                        _buildSoftInputField(
                          controller: _nameController,
                          label: 'اسم المنظمة',
                          icon: Icons.business_outlined,
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
                        const SizedBox(height: 16),

                        // Email
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
                        const SizedBox(height: 16),

                        // Phone
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
                        const SizedBox(height: 16),

                        // Address
                        _buildSoftInputField(
                          controller: _addressController,
                          label: 'العنوان',
                          icon: Icons.location_on_outlined,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return ValidationMessages.requiredField;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Registration Number
                        _buildSoftInputField(
                          controller: _registrationNumberController,
                          label: 'رقم التسجيل الرسمي',
                          icon: Icons.confirmation_number_outlined,
                          textDirection: TextDirection.ltr,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return ValidationMessages.requiredField;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Description (Multi-line)
                        _buildSoftTextArea(
                          controller: _descriptionController,
                          label: 'وصف المنظمة وأنشطتها',
                          icon: Icons.description_outlined,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return ValidationMessages.requiredField;
                            }
                            if (value!.length < 50) {
                              return 'الوصف يجب أن يكون 50 حرف على الأقل';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Submit Button - Energy Gradient
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthFormState && state.isLoading;
                    return GestureDetector(
                      onTapDown: (_) => setState(() => _isButtonPressed = true),
                      onTapUp: (_) => setState(() => _isButtonPressed = false),
                      onTapCancel: () => setState(() => _isButtonPressed = false),
                      onTap: isLoading ? null : _onSubmitPressed,
                      child: AnimatedContainer(
                        duration: microDuration,
                        curve: microCurve,
                        transform: Matrix4.identity()..scale(_isButtonPressed ? 0.97 : 1.0),
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [friendlyBlue, softTeal],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: friendlyBlue.withAlpha(_isButtonPressed ? 30 : 50),
                                blurRadius: _isButtonPressed ? 8 : 16,
                                offset: const Offset(0, 6),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Center(
                            child: isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'إرسال الطلب',
                                    style: TextStyle(
                                      fontSize: 16,
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

                // Cancel Button - Outline Style
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: friendlyBlue.withAlpha(100), width: 1.5),
                      color: surfaceColor,
                    ),
                    child: Center(
                      child: Text(
                        'إلغاء',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: friendlyBlue,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: softTeal.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 32,
                color: softTeal,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'تم إرسال الطلب',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: friendlyBlue,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'تم إرسال طلب تسجيل منظمتك بنجاح. سيتم مراجعة طلبك والتواصل معك خلال 48 ساعة.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: textSecondary,
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: friendlyBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'حسناً',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
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

  // SOFT MODERN TEXT AREA (Multi-line)
  Widget _buildSoftTextArea({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return Focus(
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          return AnimatedContainer(
            duration: microDuration,
            curve: microCurve,
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
              validator: validator,
              maxLines: 4,
              minLines: 3,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textPrimary,
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
