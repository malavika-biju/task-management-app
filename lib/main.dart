import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'blocs/task/task_bloc.dart';
import 'blocs/draft/draft_cubit.dart';
import 'services/task_service.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final taskService = TaskService();
  await taskService.init(); // Initialize Hive
  
  final prefs = await SharedPreferences.getInstance();

  runApp(MyApp(
    taskService: taskService,
    prefs: prefs,
  ));
}

class MyApp extends StatelessWidget {
  final TaskService taskService;
  final SharedPreferences prefs;

  const MyApp({
    super.key,
    required this.taskService,
    required this.prefs,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => TaskBloc(taskService)..add(LoadTasks()),
        ),
        BlocProvider(
          create: (context) => DraftCubit(prefs),
        ),
      ],
      child: MaterialApp(
        title: 'Life Planner',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(Brightness.light),
        home: const DashboardScreen(),
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final baseTheme = ThemeData(
      brightness: brightness,
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF8B5CF6),
    );

    return baseTheme.copyWith(
      scaffoldBackgroundColor: const Color(0xFFF8F7FF),
      canvasColor: Colors.white,
      textTheme: GoogleFonts.outfitTextTheme(baseTheme.textTheme).apply(
        bodyColor: const Color(0xFF1F1F39),
        displayColor: const Color(0xFF1F1F39),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF8B5CF6),
        brightness: brightness,
        surface: Colors.white,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF1F1F39)),
        titleTextStyle: GoogleFonts.outfit(
          color: const Color(0xFF1F1F39),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: const Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
