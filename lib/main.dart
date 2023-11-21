import 'dart:async';
import 'package:code_challenge/src/providers/auth_service.dart';
import 'package:code_challenge/src/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:overlay_loading_progress/overlay_loading_progress.dart';
import 'src/screens/home_screen.dart';
import 'src/globals.dart';

void main() {
  runZonedGuarded(() {
    runApp(const MyApp());
  }, (error, stackTrace) {
    snackbarKey.currentState?.showSnackBar(
        SnackBar(content: Text("$error"), backgroundColor: Colors.red));
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyAppHomePage(),
      scaffoldMessengerKey: snackbarKey,
    );
  }
}

class MyAppHomePage extends StatelessWidget {
  const MyAppHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Code Challenge',
          style: TextStyle(fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      drawer: MyAppDrawer(),
      body: const DataFetchWidget(),
    );
  }
}

class MyAppDrawer extends StatelessWidget {
  MyAppDrawer({Key? key}) : super(key: key);

  final AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.deepPurple,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Logout'),
            onTap: () async {
              OverlayLoadingProgress.start(context);
              await authService.logout().then((value){
                OverlayLoadingProgress.stop();
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen())
                );
              });
            },
          ),
        ],
      ),
    );
  }
}
