import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:volleystats/features/matches/models/match_stat.dart';

class MatchStatsNotifier extends Notifier<List<MatchStat>> {
  static const String _boxName = 'match_stats';
  Box<MatchStat>? _box;
  String? _currentMatchId;

  @override
  List<MatchStat> build() {
    _initializeBox();
    return [];
  }

  Future<void> _initializeBox() async {
    try {
      _box = await Hive.openBox<MatchStat>(_boxName);
      if (_currentMatchId != null) {
        final stats = _box!.values
            .where((stat) => stat.matchId == _currentMatchId)
            .toList();
        stats.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        state = stats;
      } else {
        state = [];
      }
    } catch (e) {
      state = [];
    }
  }

  Future<Box<MatchStat>> _getBox() async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }
    _box = await Hive.openBox<MatchStat>(_boxName);
    return _box!;
  }

  void setMatchId(String matchId) {
    _currentMatchId = matchId;
    _initializeBox();
  }

  Future<void> addStat(MatchStat stat) async {
    state = [stat, ...state];
    try {
      final box = await _getBox();
      await box.put(stat.id, stat);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> removeStat(String id) async {
    state = state.where((stat) => stat.id != id).toList();
    try {
      final box = await _getBox();
      await box.delete(id);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> clearMatchStats(String matchId) async {
    state = [];
    try {
      final box = await _getBox();
      final statsToDelete = box.values
          .where((stat) => stat.matchId == matchId)
          .map((stat) => stat.id)
          .toList();
      for (final id in statsToDelete) {
        await box.delete(id);
      }
    } catch (e) {
      // Handle error
    }
  }
}

final matchStatsProvider = NotifierProvider<MatchStatsNotifier, List<MatchStat>>(
  MatchStatsNotifier.new,
);

