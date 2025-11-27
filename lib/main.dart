import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keicybarber/domain/usecases/get_appointments.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'presentation/screens/welcome_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/register_screen.dart';
import 'presentation/screens/schedule_screen.dart';
import 'presentation/screens/appointments_screen.dart';
import 'presentation/screens/profile_screen.dart';
import 'presentation/screens/forgot_password_screen.dart';
import 'presentation/screens/schedule_location_screen.dart';

import 'presentation/bloc/home/home_bloc.dart';
import 'presentation/bloc/home/home_event.dart';

import 'presentation/bloc/navigation/navigation_cubit.dart';

import 'presentation/bloc/appointments/appointments_bloc.dart';

import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/profile/profile_bloc.dart';
import 'presentation/bloc/profile/profile_event.dart';

import 'domain/usecases/get_services.dart';
import 'domain/usecases/get_next_appointment.dart';
import 'domain/usecases/login_user.dart';
import 'domain/usecases/register_user.dart';
import 'domain/usecases/reset_password.dart';
import 'domain/usecases/logout_user.dart';
import 'domain/usecases/get_profile.dart';
import 'domain/usecases/update_profile.dart';

import 'data/datasources/auth_data_source.dart';
import 'data/datasources/profile_data_source.dart';
import 'data/datasources/service_data_source.dart';
import 'data/datasources/appointment_data_source.dart';
import 'data/datasources/location_data_source.dart';

import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/service_repository_impl.dart';
import 'data/repositories/profile_repository_impl.dart';
import 'data/repositories/appointment_repository_impl.dart';
import 'data/repositories/location_repository_impl.dart';


String _toIntlTag(Locale l) =>
    l.countryCode == null || l.countryCode!.isEmpty
        ? l.languageCode
        : '${l.languageCode}_${l.countryCode}';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? supabaseUrl;
  String? supabaseAnonKey;

  try {
    await dotenv.load(fileName: ".env");
    print("Archivo .env cargado correctamente.");

    supabaseUrl = dotenv.env['SUPABASE_URL'];
    supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseAnonKey == null) {
      print("Variables .env nulas. Usando valores por defecto.");
      supabaseUrl = 'https://sjczmvfxzaajruyxgrhy.supabase.co';
      supabaseAnonKey =
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNqY3ptdmZ4emFhanJ1eXhncmh5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkxNzE1MzQsImV4cCI6MjA3NDc0NzUzNH0.gjRo2Jd2ielDgZJ60B2m0AzzOlJpi0MAsc_7AtVtARs';
    }
  } catch (e) {
    print("Error cargando .env. Usando valores por defecto.");
    supabaseUrl = 'https://sjczmvfxzaajruyxgrhy.supabase.co';
    supabaseAnonKey =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNqY3ptdmZ4emFhanJ1eXhncmh5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkxNzE1MzQsImV4cCI6MjA3NDc0NzUzNH0.gjRo2Jd2ielDgZJ60B2m0AzzOlJpi0MAsc_7AtVtARs';
  }

  await Supabase.initialize(url: supabaseUrl!, anonKey: supabaseAnonKey!);

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

    final supabaseClient = Supabase.instance.client;

    final authDataSource = AuthDataSourceImpl(supabaseClient);
    final profileDataSource = ProfileDataSourceImpl(supabaseClient);
    final serviceDataSource = ServiceDataSource(supabaseClient);
    final appointmentDataSource = AppointmentDataSource(supabaseClient);
    final locationDataSource = LocationDataSource(supabaseClient);

    final authRepository = AuthRepositoryImpl(
      authDataSource: authDataSource,
      profileDataSource: profileDataSource,
    );

    final profileRepository =
        ProfileRepositoryImpl(profileDataSource: profileDataSource, client: supabaseClient);

    final serviceRepository =
        ServiceRepositoryImpl(serviceDataSource);

    final appointmentRepository =
        AppointmentRepositoryImpl(appointmentDataSource);

    final locationRepository =
        LocationRepositoryImpl(locationDataSource);

    final getServicesUseCase = GetServices(serviceRepository);
    final getNextAppointmentUseCase = GetNextAppointment(appointmentRepository);

    final registerUserUseCase = RegisterUser(authRepository);
    final loginUserUseCase = LoginUser(authRepository);
    final resetPasswordUseCase = ResetPassword(authRepository);
    final logoutUserUseCase = LogoutUser(authRepository);

    final getProfileUseCase = GetProfile(profileRepository);
    final updateProfileUseCase = UpdateProfile(profileRepository);

    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(
          create: (context) => HomeBloc(
            getServices: getServicesUseCase,
            getNextAppointment: getNextAppointmentUseCase,
          )..add(LoadHome()),
        ),

        BlocProvider<NavigationCubit>(
          create: (context) => NavigationCubit(),
        ),

        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            registerUserUseCase: registerUserUseCase,
            loginUserUseCase: loginUserUseCase,
            resetPasswordUseCase: resetPasswordUseCase,
            logoutUserUseCase: logoutUserUseCase,
          ),
        ),

        BlocProvider<ProfileBloc>(
          create: (context) => ProfileBloc(
            getProfileUseCase: getProfileUseCase,
            updateProfileUseCase: updateProfileUseCase,
          )..add(LoadUserProfile()),
        ),

        BlocProvider<AppointmentsBloc>(
          create: (context) => AppointmentsBloc(
            getAppointments: GetAppointments(appointmentRepository),
            appointmentRepository: appointmentRepository,
          ),
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
          final chosen = locale ??
              WidgetsBinding.instance.platformDispatcher.locale ??
              supported.first;
          final tag = _toIntlTag(chosen);
          initializeDateFormatting(tag);
          Intl.defaultLocale = tag;
          return chosen;
        },

        // -------- RUTAS --------
        home: const WelcomeScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/home': (context) => const RootScreen(),
          '/schedule': (context) => const ScheduleScreen(),

          // Se inyecta el usecase desde arriba. Solo recibe los ids.
          '/schedule-location': (context) =>
              ScheduleLocationScreen(selectedServiceIds: <String>{}, totalDurationMinutes: 0,),

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