import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider_offline.dart';  // ✅ ใช้แค่ offline เท่านั้น
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_acceptTerms) {
      _showErrorSnackBar('ກະລຸນາຍອມຮັບເງື່ອນໄຂການໃຊ້ງານ');
      return;
    }

    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProviderOffline>();  // ✅ เปลี่ยนเป็น offline
      final success = await authProvider.signUp(
        _emailController.text.trim(),
        _passwordController.text,
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
      );

      if (success && mounted) {
        context.go('/dashboard');
      } else if (mounted) {
        _showErrorSnackBar(authProvider.errorMessage ?? 'ເກີດຂໍ້ຜິດພາດໃນການສ້າງບັນຊີ');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        colors: [
          AppColors.background,
          AppColors.surfaceVariant,
        ],
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildHeader(),
                const SizedBox(height: 32),
                _buildRegisterForm(),
                const SizedBox(height: 24),
                _buildSignInLink(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_add_rounded,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          AppStrings.createAccount,
          style: AppTextStyles.h2.copyWith(
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'ເຂົ້າຮ່ວມທີມງານຂອງພວກເຮົາ',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: AppStrings.firstName,
                    hint: 'ຊື່',
                    controller: _firstNameController,
                    prefixIcon: Icons.person_outline,
                    validator: Validators.name,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    label: AppStrings.lastName,
                    hint: 'ນາມສະກຸນ',
                    controller: _lastNameController,
                    prefixIcon: Icons.person_outline,
                    validator: Validators.name,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: AppStrings.email,
              hint: 'user@example.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: Validators.email,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: AppStrings.password,
              hint: '••••••••',
              controller: _passwordController,
              obscureText: _obscurePassword,
              prefixIcon: Icons.lock_outline,
              suffixIcon: _obscurePassword ? Icons.visibility : Icons.visibility_off,
              onSuffixIconTap: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              validator: Validators.password,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: AppStrings.confirmPassword,
              hint: '••••••••',
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              prefixIcon: Icons.lock_outline,
              suffixIcon: _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
              onSuffixIconTap: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
              validator: (value) => Validators.confirmPassword(value, _passwordController.text),
            ),
            const SizedBox(height: 24),
            _buildTermsCheckbox(),
            const SizedBox(height: 32),
            Consumer<AuthProviderOffline>(  // ✅ เปลี่ยนเป็น offline
              builder: (context, authProvider, child) {
                return CustomButton(
                  text: AppStrings.createAccount,
                  onPressed: _handleRegister,
                  isLoading: authProvider.isLoading,
                  isFullWidth: true,
                  icon: Icons.person_add,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _acceptTerms,
            onChanged: (value) {
              setState(() {
                _acceptTerms = value ?? false;
              });
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              children: [
                const TextSpan(text: 'ຂ້ອຍຍອມຮັບ '),
                TextSpan(
                  text: 'ເງື່ອນໄຂການໃຊ້ງານ',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const TextSpan(text: ' ແລະ '),
                TextSpan(
                  text: 'ນະໂຍບາຍຄວາມເປັນສ່ວນຕົວ',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.alreadyHaveAccount,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 4),
        TextButton(
          onPressed: () {
            context.go('/login');
          },
          child: Text(
            AppStrings.login,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}