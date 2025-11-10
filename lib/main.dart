import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:keicybarber/presentation/screens/schedule_location_screen.dart';
import 'presentation/screens/welcome_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/register_screen.dart';
import 'presentation/screens/schedule_screen.dart';
import 'presentation/screens/appointments_screen.dart';
import 'presentation/screens/profile_screen.dart';
import 'presentation/bloc/home/home_bloc.dart';
import 'presentation/bloc/home/home_event.dart';
import 'presentation/bloc/navigation/navigation_cubit.dart';

import 'domain/usecases/get_services.dart';
import 'domain/usecases/login_user.dart';
import 'data/repositories/service_repository_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/datasources/auth_data_source.dart';
import 'data/datasources/profile_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/usecases/register_user.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'data/repositories/profile_repository_impl.dart';
import 'domain/usecases/get_profile.dart';
import 'presentation/bloc/profile/profile_bloc.dart';
import 'presentation/bloc/profile/profile_event.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String _toIntlTag(Locale l) => l.countryCode == null || l.countryCode!.isEmpty
    ? l.languageCode
    : '${l.languageCode}_${l.countryCode}';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
  final initialTag = _toIntlTag(deviceLocale);
  await initializeDateFormatting(initialTag);
  Intl.defaultLocale = initialTag;

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.platformDispatcher.onLocaleChanged = () async {
      final sysLocale = WidgetsBinding.instance.platformDispatcher.locale;
      final tag = _toIntlTag(sysLocale);
      await initializeDateFormatting(tag);
      Intl.defaultLocale = tag;
      if (mounted) setState(() {});
    };
  }

  @override
  Widget build(BuildContext context) {
    final primaryYellow = const Color(0xFFF2B705);

    final serviceRepository = ServiceRepositoryImpl();
    final getServicesUseCase = GetServices(serviceRepository);

    final supabaseClient = Supabase.instance.client;
    final authDataSource = AuthDataSourceImpl(supabaseClient);
    final profileDataSource = ProfileDataSourceImpl(supabaseClient);

    final authRepository = AuthRepositoryImpl(
      authDataSource: authDataSource,
      profileDataSource: profileDataSource,
    );

    final registerUserUseCase = RegisterUser(authRepository);
    final loginUserUseCase = LoginUser(authRepository);

    final profileRepository = ProfileRepositoryImpl(
      profileDataSource: profileDataSource,
      client: supabaseClient,
    );

    final getProfileUseCase = GetProfile(profileRepository);

    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(
          create: (context) =>
              HomeBloc(getServices: getServicesUseCase)..add(LoadHome()),
        ),
        BlocProvider<NavigationCubit>(create: (context) => NavigationCubit()),
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            registerUserUseCase: registerUserUseCase,
            loginUserUseCase: loginUserUseCase,
          ),
        ),
        BlocProvider<ProfileBloc>(
          create: (context) =>
              ProfileBloc(getProfileUseCase: getProfileUseCase)
                ..add(LoadUserProfile()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Peluquería Keicy',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: primaryYellow),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
        ),

        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'CO'),
          Locale('es'),
          Locale('en', 'US'),
          Locale('en'),
        ],
        localeResolutionCallback: (locale, supported) {
          final chosen =
              locale ??
              WidgetsBinding.instance.platformDispatcher.locale ??
              supported.first;
          final tag = _toIntlTag(chosen);
          initializeDateFormatting(tag);
          Intl.defaultLocale = tag;
          return chosen;
        },

        home: const WelcomeScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const RootScreen(),
          '/schedule': (context) => const ScheduleScreen(),
          '/schedule-location': (context) =>
              ScheduleLocationScreen(selectedServiceIds: <String>{}),
          '/appointments': (context) => const AppointmentsScreen(),
          '/profile': (context) => const ProfileScreen(),
        },
      ),
    );
  }
}

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  static final List<Widget> _pages = const [
    HomeScreen(),
    ScheduleScreen(),
    AppointmentsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, int>(
      builder: (context, index) {
        return Scaffold(
          body: SafeArea(child: _pages[index]),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
            ),
            child: BottomNavigationBar(
              currentIndex: index,
              onTap: (i) => context.read<NavigationCubit>().setPage(i),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: Colors.black54,
              showUnselectedLabels: true,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  label: 'Inicio',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month_outlined),
                  label: 'Agendar',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.schedule_outlined),
                  label: 'Citas',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  label: 'Perfil',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
