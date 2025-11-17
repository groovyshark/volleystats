import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:volleystats/features/teams/models/team.dart';

class TeamsNotifier extends Notifier<List<Team>> {
  static const String _boxName = 'teams';
  Box<Team>? _box;

  @override
  List<Team> build() {
    _initializeBox();
    return [];
  }

  Future<void> _initializeBox() async {
    try {
      _box = await Hive.openBox<Team>(_boxName);
      final teams = _box!.values.toList();
      state = teams;
    } catch (e) {
      // Box might not be initialized yet, start with empty list
      state = [];
    }
  }

  Future<Box<Team>> _getBox() async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }
    _box = await Hive.openBox<Team>(_boxName);
    return _box!;
  }

  Future<void> addTeam(Team team) async {
    state = [...state, team];
    try {
      final box = await _getBox();
      await box.put(team.id, team);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> removeTeam(String id) async {
    state = state.where((team) => team.id != id).toList();
    try {
      final box = await _getBox();
      await box.delete(id);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateTeam(Team updatedTeam) async {
    state = state.map((team) {
      return team.id == updatedTeam.id ? updatedTeam : team;
    }).toList();
    try {
      final box = await _getBox();
      await box.put(updatedTeam.id, updatedTeam);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> addPlayerToTeam(String teamId, String playerId) async {
    final team = state.firstWhere((t) => t.id == teamId);
    if (!team.playerIds.contains(playerId)) {
      final updatedTeam = team.copyWith(
        playerIds: [...team.playerIds, playerId],
      );
      await updateTeam(updatedTeam);
    }
  }

  Future<void> removePlayerFromTeam(String teamId, String playerId) async {
    final team = state.firstWhere((t) => t.id == teamId);
    final updatedTeam = team.copyWith(
      playerIds: team.playerIds.where((id) => id != playerId).toList(),
    );
    await updateTeam(updatedTeam);
  }
}

final teamsProvider = NotifierProvider<TeamsNotifier, List<Team>>(
  TeamsNotifier.new,
);

