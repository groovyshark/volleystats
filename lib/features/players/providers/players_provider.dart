import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:volleystats/features/players/models/player.dart';

class PlayersNotifier extends Notifier<Players> {
  static const String _boxName = 'players';
  Box<Player>? _box;

  @override
  Players build() {
    _initializeBox();
    return [];
  }

  Future<void> _initializeBox() async {
    try {
      _box = await Hive.openBox<Player>(_boxName);
      final players = _box!.values.toList();
      state = players;
    } catch (e) {
      // Box might not be initialized yet, start with empty list
      state = [];
    }
  }

  Future<Box<Player>> _getBox() async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }
    _box = await Hive.openBox<Player>(_boxName);
    return _box!;
  }

  // Future<void> _savePlayers() async {
  //   try {
  //     final box = await _getBox();
  //     await box.clear();
  //     for (final player in state) {
  //       await box.put(player.id, player);
  //     }
  //   } catch (e) {
  //     // Handle error silently or log it
  //   }
  // }

  Future<void> addPlayer(Player player) async {
    state = [...state, player];
    try {
      final box = await _getBox();
      await box.put(player.id, player);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> removePlayer(String id) async {
    state = state.where((player) => player.id != id).toList();
    try {
      final box = await _getBox();
      await box.delete(id);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updatePlayer(Player updatedPlayer) async {
    state = state.map((player) {
      return player.id == updatedPlayer.id ? updatedPlayer : player;
    }).toList();
    try {
      final box = await _getBox();
      await box.put(updatedPlayer.id, updatedPlayer);
    } catch (e) {
      // Handle error
    }
  }
}

final playersProvider = NotifierProvider<PlayersNotifier, Players>(
  PlayersNotifier.new,
);

