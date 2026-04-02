import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/storage_service.dart';
import 'core/services/audio_service.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Immersive UI
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
  ));

  // Init Hive storage
  await StorageService.init();

  // Init audio and register lifecycle observer so native handles are released
  // when the engine is torn down (prevents permanent AudioPlayer leaks).
  await AudioService.instance.init();
  WidgetsBinding.instance.addObserver(_AudioLifecycleObserver());

  runApp(
    const ProviderScope(
      child: ChickenManApp(),
    ),
  );
}

class _AudioLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        AudioService.instance.stopBgm();
      case AppLifecycleState.resumed:
        // BGM is not auto-restarted; the game screen handles that.
        break;
      case AppLifecycleState.detached:
        AudioService.instance.dispose();
      case AppLifecycleState.inactive:
        break;
    }
  }
}
