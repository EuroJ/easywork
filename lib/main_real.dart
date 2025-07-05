import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
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
  print('🚀 Starting Easy Work App...');
  
  try {
    WidgetsFlutterBinding.ensureInitialized();
    print('✅ Flutter initialized');
    
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully!');
    
    // ไม่ทดสอบ connection ทันที เพราะจะทำให้ error
    // await TestService.testFirebaseConnection();
    
    print('✅ Ready to start app...');
    
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
    print('Stack trace: ${StackTrace.current}');
  }
  
  runApp(const EasyWorkApp());
}

class EasyWorkApp extends StatelessWidget {
  const EasyWorkApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('🎨 Building EasyWorkApp...');
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          print('🔐 Auth state: ${authProvider.isAuthenticated}');
          
          return MaterialApp.router(
            title: AppStrings.appName,
            theme: AppTheme.lightTheme,
            routerConfig: _createRouter(authProvider),
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              print('🏗️ Building MaterialApp...');
              return child ?? const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  GoRouter _createRouter(AuthProvider authProvider) {
    print('🛤️ Creating router...');
    
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        print('🔄 Redirecting: ${state.fullPath}');
        final isAuthenticated = authProvider.isAuthenticated;
        final isAuthRoute = state.fullPath?.startsWith('/auth') ?? false;
        
        if (!isAuthenticated && !isAuthRoute && state.fullPath != '/' && state.fullPath != '/login' && state.fullPath != '/register') {
          print('➡️ Redirect to login');
          return '/login';
        }
        
        if (isAuthenticated && (isAuthRoute || state.fullPath == '/')) {
          print('➡️ Redirect to dashboard');
          return '/dashboard';
        }
        
        print('✅ No redirect needed');
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) {
            print('🎬 Building SplashScreen');
            return const SplashScreen();
          },
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) {
            print('🔑 Building LoginScreen');
            return const LoginScreen();
          },
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) {
            print('📝 Building RegisterScreen');
            return const RegisterScreen();
          },
        ),
        ShellRoute(
          builder: (context, state, child) {
            print('🏠 Building HomeScreen shell');
            return HomeScreen(child: child);
          },
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) {
                print('📊 Building DashboardScreen');
                return const DashboardScreen();
              },
            ),
            GoRoute(
              path: '/tasks',
              builder: (context, state) {
                print('📋 Building TaskListScreen');
                return const TaskListScreen();
              },
              routes: [
                GoRoute(
                  path: '/create',
                  builder: (context, state) {
                    print('➕ Building CreateTaskScreen');
                    return const CreateTaskScreen();
                  },
                ),
                GoRoute(
                  path: '/:taskId',
                  builder: (context, state) {
                    final taskId = state.pathParameters['taskId']!;
                    print('📄 Building TaskDetailScreen for: $taskId');
                    return TaskDetailScreen(taskId: taskId);
                  },
                ),
              ],
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) {
                print('👤 Building ProfileScreen');
                return const ProfileScreen();
              },
            ),
            GoRoute(
              path: '/team',
              builder: (context, state) {
                print('👥 Building TeamMembersScreen');
                return const TeamMembersScreen();
              },
            ),
            GoRoute(
              path: '/notifications',
              builder: (context, state) {
                print('🔔 Building NotificationsScreen');
                return const NotificationsScreen();
              },
            ),
            GoRoute(
              path: '/reports',
              builder: (context, state) {
                print('📈 Building ReportsScreen');
                return const ReportsScreen();
              },
            ),
            GoRoute(
              path: '/settings',
              builder: (context, state) {
                print('⚙️ Building SettingsScreen');
                return const SettingsScreen();
              },
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) {
        print('❌ Router error: ${state.error}');
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${state.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Go Home'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}