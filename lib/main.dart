import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/services/supabase_service.dart';
import 'features/live_bus/data/repositories/supabase_live_location_repository.dart';
import 'features/live_bus/domain/repositories/live_location_repository.dart';
import 'features/live_bus/presentation/controllers/live_bus_view_model.dart';
import 'ui/core/theme.dart';
import 'ui/features/auth/view_models/auth_view_model.dart';
import 'ui/features/tracker/view_models/tracker_view_model.dart';
import 'ui/features/channels/view_models/channels_view_model.dart';
import 'ui/features/admin/view_models/admin_view_model.dart';
import 'ui/features/admin/views/admin_portal_view.dart';
import 'ui/features/auth/views/signin_view.dart';
import 'ui/features/home/views/main_shell_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Supabase Client with Realtime Websockets
  await SupabaseService.instance.initialize();
  runApp(const PadmaApp());
}

class PadmaApp extends StatelessWidget {
  const PadmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Live Location Repository Provider connected to Supabase Realtime CDC
        Provider<LiveLocationRepository>(
          create: (_) => SupabaseLiveLocationRepository(autoStartDemo: true),
          dispose: (_, repo) => repo.dispose(),
        ),
        // Live Bus Telemetry ViewModel Provider
        ChangeNotifierProxyProvider<LiveLocationRepository, LiveBusViewModel>(
          create: (context) => LiveBusViewModel(
            repository: context.read<LiveLocationRepository>(),
            autoStartSharing: true,
          ),
          update: (context, repo, previous) =>
              previous ?? LiveBusViewModel(repository: repo, autoStartSharing: true),
        ),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => AdminViewModel()),
        ChangeNotifierProvider(create: (_) => TrackerViewModel()),
        ChangeNotifierProvider(create: (_) => ChannelsViewModel()),
      ],
      child: Consumer<AuthViewModel>(
        builder: (context, authVM, _) {
          Widget homeScreen;
          if (authVM.isAuthenticated) {
            homeScreen = authVM.isAdmin ? const AdminPortalView() : const MainShellView();
          } else {
            homeScreen = const SignInView();
          }

          return MaterialApp(
            title: 'Padma - AUST Transit & Community',
            debugShowCheckedModeBanner: false,
            theme: PadmaTheme.darkTheme,
            home: homeScreen,
          );
        },
      ),
    );
  }
}
