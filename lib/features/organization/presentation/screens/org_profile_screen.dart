import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../config/routes/app_routes.dart';

// Light of Impact - Warm Hopeful Color System
const Color backgroundOffWhite = Color(0xFFF9FAFB);
const Color softBlueTint = Color(0xFFF3F8FC);
const Color friendlyBlue = Color(0xFF1E7ABF);
const Color softTeal = Color(0xFF3BB3A9);
const Color textDark = Color(0xFF1F2937);
const Color textMedium = Color(0xFF6B7280);
const Color textLight = Color(0xFF9CA3AF);
const Color cardWhite = Color(0xFFFFFFFF);
const Color borderLight = Color(0xFFE5E7EB);
const Color inputFill = Color(0xFFF7FAFC);

class OrgProfileScreen extends StatefulWidget {
  const OrgProfileScreen({super.key});

  @override
  State<OrgProfileScreen> createState() => _OrgProfileScreenState();
}

class _OrgProfileScreenState extends State<OrgProfileScreen> {
  bool _isLoading = false;
  bool _isEditing = false;
  
  final Map<String, dynamic> _orgData = {
    'name': 'منظمة الخير للإغاثة',
    'email': 'info@khair-org.org',
    'phone': '01234567890',
    'address': 'شارع الفيحاء، دمشق، سوريا',
    'registrationNumber': '123456789',
    'description': 'منظمة خيرية متخصصة في تقديم المساعدات العاجلة والإغاثة للأسر المحتاجة',
    'website': 'www.khair-org.org',
    'establishedYear': '2015',
  };
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _websiteController = TextEditingController();
  
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordFormKey = GlobalKey<FormState>();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _loadOrgData();
  }

  void _loadOrgData() {
    _nameController.text = _orgData['name'];
    _emailController.text = _orgData['email'];
    _phoneController.text = _orgData['phone'];
    _addressController.text = _orgData['address'];
    _descriptionController.text = _orgData['description'];
    _websiteController.text = _orgData['website'];
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
      _isEditing = false;
    });
    
    if (mounted) {
      _showSnackBar('تم حفظ البيانات بنجاح!', softTeal);
    }
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    
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
        backgroundColor: cardWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
            child: Text('إلغاء', style: TextStyle(color: textMedium)),
          ),
          GestureDetector(
            onTap: _isLoading ? null : _changePassword,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [friendlyBlue, softTeal],
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
                  : const Text(
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
            isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
                icon: Icon(Icons.edit_outlined, color: friendlyBlue, size: 20),
                onPressed: () => setState(() => _isEditing = true),
              ),
            )
          else
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [friendlyBlue, softTeal],
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
                  gradient: const LinearGradient(
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
            _orgData['name'],
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'عضو منذ ${_orgData['establishedYear']}',
            style: TextStyle(
              fontSize: 14,
              color: textMedium,
            ),
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
              value: _orgData['registrationNumber'],
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
                    style: TextStyle(
                      fontSize: 14,
                      color: textDark,
                    ),
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
              style: TextStyle(
                fontSize: 14,
                color: textDark,
              ),
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
        boxShadow: [
          BoxShadow(
            color: friendlyBlue.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
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

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
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
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: textMedium,
              ),
            )
          : null,
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: textLight),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
