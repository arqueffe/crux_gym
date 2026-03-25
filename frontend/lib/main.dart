import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'generated/l10n/app_localizations.dart';
import 'providers/route_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/role_provider.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/login_screen.dart';

bool _shouldForwardLog(String message) {
  if (kDebugMode) {
    return true;
  }

  final normalized = message.toLowerCase();
  return normalized.contains('error') ||
      normalized.contains('failed') ||
      normalized.contains('exception') ||
      normalized.contains('stack trace') ||
      normalized.contains('❌') ||
      normalized.contains('💥');
}

void _configureLoggingGuards() {
  final originalDebugPrint = debugPrint;
  debugPrint = (String? message, {int? wrapWidth}) {
    if (message != null && _shouldForwardLog(message)) {
      originalDebugPrint(message, wrapWidth: wrapWidth);
    }
  };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _configureLoggingGuards();

  // Initialize InAppWebView for flutter_3d_controller
  if (InAppWebViewPlatform.instance is InAppWebViewPlatform) {
    // Platform is already initialized
  }

  runZonedGuarded(
    () => runApp(const ClimbingGymApp()),
    (error, stackTrace) {
      debugPrint('Uncaught app error: $error');
      debugPrint('Stack trace: $stackTrace');
    },
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {
        if (_shouldForwardLog(line)) {
          parent.print(zone, line);
        }
      },
    ),
  );
}

class ClimbingGymApp extends StatelessWidget {
  const ClimbingGymApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
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
        ChangeNotifierProxyProvider<AuthProvider, RoleProvider>(
          create: (context) => RoleProvider(
            authProvider: context.read<AuthProvider>(),
          ),
          update: (context, auth, previous) => RoleProvider(
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
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp(
            title: 'Climbing Gym Routes',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,
            locale: localeProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: LocaleProvider.supportedLocales,
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
        if (authProvider.isInitializing) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context).initializing),
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
