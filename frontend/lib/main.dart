import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'providers/route_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize InAppWebView for flutter_3d_controller
  if (InAppWebViewPlatform.instance is InAppWebViewPlatform) {
    // Platform is already initialized
  }

  runApp(const ClimbingGymApp());
}

class ClimbingGymApp extends StatelessWidget {
  const ClimbingGymApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, RouteProvider>(
          create: (context) => RouteProvider(
            authProvider: context.read<AuthProvider>(),
          ),
          update: (context, auth, previous) => RouteProvider(
            authProvider: auth,
          ),
        ),
        ChangeNotifierProxyProvider2<AuthProvider, RouteProvider,
            ProfileProvider>(
          create: (context) => ProfileProvider(
            authProvider: context.read<AuthProvider>(),
            routeProvider: context.read<RouteProvider>(),
          ),
          update: (context, auth, route, previous) => ProfileProvider(
            authProvider: auth,
            routeProvider: route,
          ),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Climbing Gym Routes',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Initialize authentication when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading screen during initialization
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing...'),
                ],
              ),
            ),
          );
        }

        // Show login screen if not authenticated
        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }

        // Show main app if authenticated
        return const MainNavigationScreen();
      },
    );
  }
}
