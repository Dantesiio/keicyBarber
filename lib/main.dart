import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/home/home_bloc.dart';
import 'bloc/home/home_event.dart';
import 'bloc/navigation/navigation_cubit.dart';
import 'screens/home_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/appointments_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryYellow = const Color(0xFFF2B705);
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(create: (context) => HomeBloc()..add(LoadHome())),
        BlocProvider<NavigationCubit>(create: (context) => NavigationCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Peluquería Keicy',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: primaryYellow),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const RootScreen(),
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
    return BlocBuilder<NavigationCubit, int>(builder: (context, index) {
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
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Inicio'),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: 'Agendar'),
              BottomNavigationBarItem(icon: Icon(Icons.schedule_outlined), label: 'Citas'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
            ],
          ),
        ),
      );
    });
  }
}
