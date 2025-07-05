import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/auth_provider_offline.dart';  // ✅ เปลี่ยนเป็น offline
import '../../widgets/common/gradient_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    print('🎬 SplashScreen initState (Offline Mode)');
    _initializeAnimations();
    _checkAuthState();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  void _checkAuthState() {
    print('🔍 Checking auth state (Offline Mode)...');
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        print('⏰ Splash timeout, checking auth...');
        final authProvider = context.read<AuthProviderOffline>();  // ✅ เปลี่ยนเป็น offline
        if (authProvider.isAuthenticated) {
          print('✅ User authenticated, going to dashboard');
          context.go('/dashboard');
        } else {
          print('❌ User not authenticated, going to login');
          context.go('/login');
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 Building SplashScreen UI (Offline Mode)');
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.secondary,
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLogo(),
                      const SizedBox(height: 24),
                      _buildAppName(),
                      const SizedBox(height: 8),
                      _buildTagline(),
                      const SizedBox(height: 12),
                      _buildOfflineBadge(),  // ✅ เพิ่ม offline indicator
                      const SizedBox(height: 40),
                      _buildLoadingIndicator(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(
        Icons.work_rounded,
        size: 60,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildAppName() {
    return Text(
      AppStrings.appName,
      style: AppTextStyles.h1.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTagline() {
    return Text(
      'ຈັດການວຽກງານຢ່າງມີປະສິດທິພາບ',
      style: AppTextStyles.bodyLarge.copyWith(
        color: Colors.white.withOpacity(0.9),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildOfflineBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.offline_bolt,
            size: 16,
            color: Colors.white.withOpacity(0.9),
          ),
          const SizedBox(width: 6),
          Text(
            'Offline Demo Mode',
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const SizedBox(
      width: 32,
      height: 32,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }
}