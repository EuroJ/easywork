import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'providers/auth_provider_offline.dart';
import 'providers/task_provider_offline.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/dashboard_screen.dart';
import 'screens/tasks/task_list_screen.dart';
import 'screens/tasks/task_detail_screen.dart';
import 'screens/tasks/create_task_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/team/team_members_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/reports/reports_screen.dart';

void main() async {
  print('🚀 Starting Easy Work App (Offline Mode)...');
  
  WidgetsFlutterBinding.ensureInitialized();
  print('✅ Flutter initialized');
  print('✅ Offline mode - no Firebase needed');
  
  runApp(const EasyWorkOfflineApp());
}

class EasyWorkOfflineApp extends StatelessWidget {
  const EasyWorkOfflineApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('🎨 Building EasyWorkOfflineApp...');
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProviderOffline()),
        ChangeNotifierProvider(create: (_) => TaskProviderOffline()),
      ],
      child: MaterialApp.router(
        title: AppStrings.appName,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  static final GoRouter _router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // Protected Routes with HomeScreen Shell
      ShellRoute(
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/tasks',
            builder: (context, state) => const TaskListScreen(),
          ),
          GoRoute(
            path: '/task/:id',
            builder: (context, state) {
              final taskId = state.pathParameters['id']!;
              return TaskDetailScreen(taskId: taskId);
            },
          ),
          GoRoute(
            path: '/create-task',
            builder: (context, state) => const CreateTaskScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/team',
            builder: (context, state) => const TeamMembersScreen(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      try {
        final authProvider = context.read<AuthProviderOffline>();
        final isLoggedIn = authProvider.isAuthenticated;
        final currentPath = state.uri.path;
        final isLoggingIn = currentPath == '/login' || 
                           currentPath == '/register' || 
                           currentPath == '/';

        print('🔐 Redirect check: isLoggedIn=$isLoggedIn, path=$currentPath');

        // ถ้ายังไม่ login และไม่ได้อยู่ในหน้า auth ให้ไปหน้า login
        if (!isLoggedIn && !isLoggingIn) {
          print('🔄 Redirecting to login...');
          return '/login';
        }

        // ถ้า login แล้วแต่ยังอยู่ในหน้า auth ให้ไปหน้า dashboard
        if (isLoggedIn && isLoggingIn) {
          print('🔄 Redirecting to dashboard...');
          return '/dashboard';
        }

        return null; // ไม่ต้อง redirect
      } catch (e) {
        print('⚠️ Redirect error: $e');
        return '/login'; // fallback to login if error
      }
    },
  );
}