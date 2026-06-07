import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/splash_screen.dart';
import '../../features/game/presentation/game_screen.dart';
import '../../features/game/presentation/result_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/how_to_play_screen.dart';
import '../../features/leaderboard/presentation/leaderboard_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/room/presentation/create_room_screen.dart';
import '../../features/room/presentation/join_room_screen.dart';
import '../../features/room/presentation/waiting_room_screen.dart';
import '../../features/solo/presentation/solo_game_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/create-room',
        builder: (context, state) => const CreateRoomScreen(),
      ),
      GoRoute(
        path: '/join-room',
        builder: (context, state) => const JoinRoomScreen(),
      ),
      GoRoute(
        path: '/waiting/:roomCode',
        builder: (context, state) {
          final roomCode = state.pathParameters['roomCode']!;
          return WaitingRoomScreen(roomCode: roomCode);
        },
      ),
      GoRoute(
        path: '/game/:roomCode',
        builder: (context, state) {
          final roomCode = state.pathParameters['roomCode']!;
          return GameScreen(roomCode: roomCode);
        },
      ),
      GoRoute(
        path: '/result/:roomCode',
        builder: (context, state) {
          final roomCode = state.pathParameters['roomCode']!;
          return ResultScreen(roomCode: roomCode);
        },
      ),
      GoRoute(
        path: '/leaderboard',
        builder: (context, state) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/how-to-play',
        builder: (context, state) => const HowToPlayScreen(),
      ),
      GoRoute(
        path: '/play-alone',
        builder: (context, state) => const SoloGameScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri}')),
    ),
  );
});
