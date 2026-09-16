import 'package:flutter/material.dart';

import 'data/app_database.dart';
import 'models/professional_profile.dart';
import 'screens/home_screen.dart';
import 'screens/professional_profile_screen.dart';
import 'services/professional_profile_service.dart';
import 'services/security_service.dart';
import 'widgets/brand_logo.dart';

class MaisFisioApp extends StatelessWidget {
  const MaisFisioApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF087F78);
    const secondary = Color(0xFF3D6E91);
    const background = Color(0xFFF4F8F7);
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: primary,
      secondary: secondary,
      surface: Colors.white,
    );

    return MaterialApp(
      title: '+Fisio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: background,
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE1EAE8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: primary, width: 1.5),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide.none,
        ),
      ),
      home: const AppBootstrap(),
      builder: (context, child) =>
          AppLockGate(child: child ?? const SizedBox.shrink()),
    );
  }
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  ProfessionalProfile? _profile;
  bool _splash = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final profile = await ProfessionalProfileService.instance.load();
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _loading = false;
      _splash = false;
    });
  }

  Future<void> _registerProfessional() async {
    final profile = await Navigator.of(context).push<ProfessionalProfile>(
      MaterialPageRoute(
        builder: (_) => const ProfessionalProfileScreen(),
      ),
    );
    if (profile != null && mounted) {
      setState(() => _profile = profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_splash || _loading) {
      return const Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BrandLogo(size: 180),
                SizedBox(height: 38),
                SizedBox(
                  width: 130,
                  child: LinearProgressIndicator(minHeight: 4),
                ),
                SizedBox(height: 12),
                Text('Carregando...'),
              ],
            ),
          ),
        ),
      );
    }

    if (_profile == null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BrandLogo(size: 150),
                  const SizedBox(height: 28),
                  Text(
                    'Configure o profissional responsável para começar.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: _registerProfessional,
                    icon: const Icon(Icons.badge_outlined),
                    label: const Text('Cadastrar profissional'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return HomeScreen(
      database: AppDatabase.instance,
      professional: _profile!,
      onProfessionalChanged: (profile) {
        if (mounted) setState(() => _profile = profile);
      },
    );
  }
}

class AppLockGate extends StatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate>
    with WidgetsBindingObserver {
  bool _checking = true;
  bool _locked = false;
  bool _authRunning = false;
  DateTime? _backgroundedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkLock() async {
    final enabled = await SecurityService.isLockEnabled();
    if (!mounted) return;
    setState(() {
      _locked = enabled;
      _checking = false;
    });
    if (enabled) await _unlock();
  }

  Future<void> _unlock() async {
    if (_authRunning) return;
    _authRunning = true;
    final ok = await SecurityService.authenticate();
    _authRunning = false;
    if (mounted) setState(() => _locked = !ok);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _backgroundedAt ??= DateTime.now();
      return;
    }
    if (state == AppLifecycleState.resumed) {
      final since = _backgroundedAt;
      _backgroundedAt = null;
      if (since != null &&
          DateTime.now().difference(since) > const Duration(seconds: 10)) {
        SecurityService.isLockEnabled().then((enabled) {
          if (enabled && mounted) {
            setState(() => _locked = true);
            _unlock();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Material(
        color: Color(0xFFF4F8F7),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (!_locked) return widget.child;

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BrandLogo(size: 115),
                const SizedBox(height: 20),
                Text(
                  '+Fisio protegido',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Seus prontuários estão protegidos. Autentique-se para continuar.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _unlock,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Desbloquear +Fisio'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
