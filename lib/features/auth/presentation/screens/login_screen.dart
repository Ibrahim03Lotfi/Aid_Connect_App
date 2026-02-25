import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../shared/constants/app_constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;

  // Controllers
  final _emailController = TextEditingController();
  final _orgNameController = TextEditingController();
  final _volunteerNameController = TextEditingController();
  final _passwordController = TextEditingController();

  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  final List<Map<String, dynamic>> _tabs = [
    {
      'icon': Icons.person_outline,
      'activeIcon': Icons.person,
      'label': 'مستخدم',
      'color': const Color(0xFF1E7ABF),
    },
    {
      'icon': Icons.business_outlined,
      'activeIcon': Icons.business,
      'label': 'منظمة',
      'color': const Color(0xFF1E7ABF),
    },
    {
      'icon': Icons.volunteer_activism_outlined,
      'activeIcon': Icons.volunteer_activism,
      'label': 'متطوع',
      'color': const Color(0xFF1E7ABF),
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _orgNameController.dispose();
    _volunteerNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onLoginPressed() {
    final formKey = _formKeys[_currentIndex];
    if (formKey.currentState?.validate() ?? false) {
      // STATIC LOGIN - direct navigation
      final role = _getRoleFromIndex(_currentIndex);
      _navigateBasedOnRole(role);
    }
  }

  String _getRoleFromIndex(int index) {
    switch (index) {
      case 0:
        return UserRoles.user;
      case 1:
        return UserRoles.organization;
      case 2:
        return UserRoles.volunteer;
      default:
        return UserRoles.user;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = _tabs[_currentIndex]['color'] as Color;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header with Logo
            _buildHeader(currentColor),

            // Animated Tab Selector
            _buildTabSelector(currentColor),

            // Page Content with Forms
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildUserTab(),
                  _buildOrganizationTab(),
                  _buildVolunteerTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color currentColor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Column(
        children: [
          // Animated Logo Container
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        currentColor,
                        currentColor.withAlpha(200),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: currentColor.withAlpha(60),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.volunteer_activism,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Aid Connect',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: currentColor,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'تسجيل الدخول إلى حسابك',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector(Color currentColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: List.generate(3, (index) {
          final isSelected = _currentIndex == index;
          final tab = _tabs[index];
          return Expanded(
            child: GestureDetector(
              onTap: () => _onTabTapped(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withAlpha(20),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        isSelected ? tab['activeIcon'] : tab['icon'],
                        key: ValueKey(isSelected),
                        size: 18,
                        color: isSelected
                            ? tab['color'] as Color
                            : Colors.grey[500],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tab['label'],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? tab['color'] as Color
                            : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildUserTab() {
    return _buildFormContainer(
      child: Form(
        key: _formKeys[0],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            _buildTextField(
              controller: _emailController,
              label: 'البريد الإلكتروني',
              hint: 'example@email.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
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
            const SizedBox(height: 20),
            _buildPasswordField(),
            const SizedBox(height: 12),
            _buildForgotPassword(),
            const SizedBox(height: 32),
            _buildLoginButton(const Color(0xFF1E7ABF)),
            const SizedBox(height: 24),
            _buildRegisterRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrganizationTab() {
    return _buildFormContainer(
      child: Form(
        key: _formKeys[1],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E7ABF).withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF1E7ABF).withAlpha(40),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: const Color(0xFF1E7ABF),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'أدخل اسم المنظمة وكلمة المرور للدخول',
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFF1E7ABF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _orgNameController,
              label: 'اسم المنظمة',
              hint: 'اسم المنظمة المسجل',
              prefixIcon: Icons.business,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'اسم المنظمة مطلوب';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildPasswordField(),
            const SizedBox(height: 12),
            _buildForgotPassword(),
            const SizedBox(height: 32),
            _buildLoginButton(const Color(0xFF1E7ABF)),
            const SizedBox(height: 16),
            _buildOrgRequestButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildVolunteerTab() {
    return _buildFormContainer(
      child: Form(
        key: _formKeys[2],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E7ABF).withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF1E7ABF).withAlpha(40),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: const Color(0xFF1E7ABF),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'أدخل اسم المتطوع وكلمة المرور',
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFF1E7ABF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _volunteerNameController,
              label: 'اسم المتطوع',
              hint: 'الاسم الكامل',
              prefixIcon: Icons.person_outline,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'اسم المتطوع مطلوب';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildPasswordField(),
            const SizedBox(height: 12),
            _buildForgotPassword(),
            const SizedBox(height: 32),
            _buildLoginButton(const Color(0xFF1E7ABF)),
          ],
        ),
      ),
    );
  }

  Widget _buildFormContainer({required Widget child}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: child,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    TextCapitalization? textCapitalization,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization ?? TextCapitalization.none,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(prefixIcon, color: Colors.grey[500], size: 24),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _tabs[_currentIndex]['color'] as Color,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'كلمة المرور',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: true,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[500], size: 24),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.visibility_off_outlined,
                color: Colors.grey[500],
                size: 24,
              ),
              onPressed: () {
                // Toggle password visibility
              },
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _tabs[_currentIndex]['color'] as Color,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
          ),
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
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(0, 40),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          'نسيت كلمة المرور؟',
          style: TextStyle(
            color: _tabs[_currentIndex]['color'] as Color,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(Color color) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _onLoginPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'تسجيل الدخول',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(width: 10),
            Icon(Icons.arrow_forward, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOrgRequestButton() {
    return OutlinedButton(
      onPressed: () {
        Navigator.pushNamed(context, AppRoutes.organizationRequest);
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF1E7ABF),
        side: const BorderSide(color: Color(0xFF1E7ABF), width: 2),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_business, size: 24),
          SizedBox(width: 10),
          Text(
            'طلب تسجيل منظمة جديدة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'ليس لديك حساب؟',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 6),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.register);
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 40),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'سجل الآن',
            style: TextStyle(
              color: _tabs[_currentIndex]['color'] as Color,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  void _navigateBasedOnRole(String role) {
    switch (role) {
      case UserRoles.user:
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        break;
      case UserRoles.organization:
        Navigator.pushReplacementNamed(context, AppRoutes.orgDashboard);
        break;
      case UserRoles.volunteer:
        Navigator.pushReplacementNamed(context, AppRoutes.volunteerDashboard);
        break;
      default:
        Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }
}
