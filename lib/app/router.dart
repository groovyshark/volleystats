import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:volleystats/core/widgets/app_layout.dart';
import 'package:volleystats/features/players/screens/players_screen.dart';
import 'package:volleystats/features/teams/screens/teams_screen.dart';
import 'package:volleystats/features/commands/screens/commands_screen.dart';
import 'package:volleystats/features/matches/screens/matches_screen.dart';
import 'package:volleystats/features/matches/screens/match_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const AppLayout(),
      ),
      GoRoute(
        path: '/players',
        builder: (_, _) => const AppLayout(child: PlayersScreen()),
      ),
      GoRoute(
        path: '/teams',
        builder: (_, _) => const AppLayout(child: TeamsScreen()),
      ),
      GoRoute(
        path: '/commands',
        builder: (_, _) => const AppLayout(child: CommandsScreen()),
      ),
      GoRoute(
        path: '/matches',
        builder: (_, _) => const AppLayout(child: MatchesScreen()),
      ),
      GoRoute(
        path: '/match/:id',
        builder: (_, state) => AppLayout(
          child: MatchScreen(matchId: state.pathParameters['id']!),
        ),
      ),
    ],
  );
});
