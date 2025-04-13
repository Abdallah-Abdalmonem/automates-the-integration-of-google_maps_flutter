import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tool_outomate/bloc/map_bloc.dart';
import 'package:tool_outomate/src/ui/map_screen.dart';
import 'src/ui/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Maps Integration Tool',
      theme: ThemeData(primarySwatch: Colors.indigo),
      routes: {
        '/': (_) => BlocProvider(
              create: (_) => MapBloc(),
              child: const HomeScreen(),
            ),
        '/map': (_) => const MapScreen(),
      },
    );
  }
}
