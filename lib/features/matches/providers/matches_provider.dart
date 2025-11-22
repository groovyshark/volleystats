import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:volleystats/features/matches/models/match.dart';

class MatchesNotifier extends Notifier<List<Match>> {
  static const String _boxName = 'matches';
  Box<Match>? _box;

  @override
  List<Match> build() {
    _initializeBox();
    return [];
  }

  Future<void> _initializeBox() async {
    try {
      _box = await Hive.openBox<Match>(_boxName);
      final matches = _box!.values.toList();
      // Sort by creation date, newest first
      matches.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      state = matches;
    } catch (e) {
      state = [];
    }
  }

  Future<Box<Match>> _getBox() async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }
    _box = await Hive.openBox<Match>(_boxName);
    return _box!;
  }

  Future<void> addMatch(Match match) async {
    state = [match, ...state];
    try {
      final box = await _getBox();
      await box.put(match.id, match);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> removeMatch(String id) async {
    state = state.where((match) => match.id != id).toList();
    try {
      final box = await _getBox();
      await box.delete(id);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateMatch(Match updatedMatch) async {
    state = state.map((match) {
      return match.id == updatedMatch.id ? updatedMatch : match;
    }).toList();
    state.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    try {
      final box = await _getBox();
      await box.put(updatedMatch.id, updatedMatch);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> startMatch(String id) async {
    final match = state.firstWhere((m) => m.id == id);
    final updatedMatch = match.copyWith(startedAt: DateTime.now());
    await updateMatch(updatedMatch);
  }

  Future<void> endMatch(String id) async {
    final match = state.firstWhere((m) => m.id == id);
    final updatedMatch = match.copyWith(endedAt: DateTime.now());
    await updateMatch(updatedMatch);
  }
}

final matchesProvider = NotifierProvider<MatchesNotifier, List<Match>>(
  MatchesNotifier.new,
);

final isMatchFinishedProvider = Provider.family<bool, String>((ref, id) {
  final matches = ref.watch(matchesProvider);
  final match = matches.firstWhere((m) => m.id == id);
  return match.isFinished;
});
