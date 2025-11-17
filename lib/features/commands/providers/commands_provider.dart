import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:volleystats/features/commands/models/command.dart';

class CommandsNotifier extends Notifier<Commands> {
  static const String _boxName = 'commands';
  Box<Command>? _box;

  @override
  Commands build() {
    _initializeBox();
    return [];
  }

  Future<void> _initializeBox() async {
    // final exists = await Hive.boxExists(_boxName);
    // if (exists) {
    //   await Hive.deleteBoxFromDisk(_boxName);
    // }

    try {
      _box = await Hive.openBox<Command>(_boxName);
      final commands = _box!.values.toList();
      // Sort by name
      commands.sort((a, b) => a.name.compareTo(b.name));
      state = commands;
    } catch (e) {
      // Box might not be initialized yet, start with empty list
      state = [];
    }
  }

  Future<Box<Command>> _getBox() async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }
    _box = await Hive.openBox<Command>(_boxName);
    return _box!;
  }

  Future<void> addCommand(Command command) async {
    state = [...state, command];
    state.sort((a, b) => a.name.compareTo(b.name));
    try {
      final box = await _getBox();
      await box.put(command.id, command);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> removeCommand(String id) async {
    state = state.where((command) => command.id != id).toList();
    try {
      final box = await _getBox();
      await box.delete(id);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateCommand(Command updatedCommand) async {
    state = state.map((command) {
      return command.id == updatedCommand.id ? updatedCommand : command;
    }).toList();
    state.sort((a, b) => a.name.compareTo(b.name));
    try {
      final box = await _getBox();
      await box.put(updatedCommand.id, updatedCommand);
    } catch (e) {
      // Handle error
    }
  }
}

final commandsProvider = NotifierProvider<CommandsNotifier, Commands>(
  CommandsNotifier.new,
);
