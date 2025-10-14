import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/bloc/home/home_bloc.dart';
import 'presentation/bloc/home/home_event.dart';
import 'presentation/bloc/navigation/navigation_cubit.dart';
import 'presentation/screens/welcome_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/register_screen.dart';
import 'presentation/screens/schedule_screen.dart';
import 'presentation/screens/appointments_screen.dart';
import 'presentation/screens/profile_screen.dart';
import 'domain/usecases/get_services.dart';
import 'domain/usecases/login_user.dart';
import 'data/repositories/service_repository_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/datasources/auth_data_source.dart';
import 'data/datasources/profile_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/usecases/register_user.dart';
import 'presentation/bloc/auth/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Asegurar inicialización

  // Inicializar Supabase
  await Supabase.initialize(
    url: 'https://sjczmvfxzaajruyxgrhy.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNqY3ptdmZ4emFhanJ1eXhncmh5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkxNzE1MzQsImV4cCI6MjA3NDc0NzUzNH0.gjRo2Jd2ielDgZJ60B2m0AzzOlJpi0MAsc_7AtVtARs',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Peluquería Keicy',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: primaryYellow),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const WelcomeScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const RootScreen(),
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
