import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

import 'package:volleystats/features/matches/models/match.dart';
import 'package:volleystats/features/matches/models/match_stat.dart';
import 'package:volleystats/features/players/models/player.dart';
import 'package:volleystats/features/teams/models/team.dart';

class MatchExportService {
  /// Exports match statistics to an Excel file
  /// Returns the file path if successful, null otherwise
  static Future<String?> exportMatchStatsToExcel({
    required Match match,
    required List<MatchStat> stats,
    required List<Player> players,
    required List<Team> teams,
  }) async {
    try {
      // Create Excel workbook
      final excel = Excel.createExcel();
      excel.delete('Sheet1'); // Delete default sheet
      final sheet = excel[MatchExportService._sanitizeSheetName(match.name)];

      // Get unique actions from stats
      final allActions = <String>{};
      for (final stat in stats) {
        allActions.add(stat.action);
      }
      final sortedActions = allActions.toList()..sort();

      // Get players in this match
      final matchPlayerIds = <String>{};
      // Add directly selected players
      matchPlayerIds.addAll(match.playerIds);
      // Add players from selected teams
      for (final teamId in match.teamIds) {
        try {
          final team = teams.firstWhere((t) => t.id == teamId);
          matchPlayerIds.addAll(team.playerIds);
        } catch (e) {
          // Team not found, skip it
        }
      }

      final matchPlayers = players
          .where((p) => matchPlayerIds.contains(p.id))
          .toList();

      // If no players, show all players (for stats that might have been recorded)
      final displayPlayers = matchPlayers.isEmpty
          ? players.where((p) => stats.any((s) => s.playerId == p.id)).toList()
          : matchPlayers;

      // Sort players by name
      displayPlayers.sort((a, b) => a.name.compareTo(b.name));

      // Calculate stats for each player
      final playerStats = <String, Map<String, int>>{};
      for (final stat in stats) {
        final playerId = stat.playerId;
        final action = stat.action;

        if (!playerStats.containsKey(playerId)) {
          playerStats[playerId] = {};
        }

        // Count total actions
        playerStats[playerId]![action] =
            (playerStats[playerId]![action] ?? 0) + 1;

        // Count positive/negative results
        if (stat.result.startsWith('+')) {
          playerStats[playerId]!['${action}_positive'] =
              (playerStats[playerId]!['${action}_positive'] ?? 0) + 1;
        } else if (stat.result.startsWith('-')) {
          playerStats[playerId]!['${action}_negative'] =
              (playerStats[playerId]!['${action}_negative'] ?? 0) + 1;
        }
      }

      // Write header row
      int rowIndex = 0;

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          .value = TextCellValue(
        'Player',
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          .value = TextCellValue(
        'Number',
      );

      int colIndex = 2;
      for (final action in sortedActions) {
        sheet
            .cell(
              CellIndex.indexByColumnRow(
                columnIndex: colIndex++,
                rowIndex: rowIndex,
              ),
            )
            .value = TextCellValue(
          action.toUpperCase(),
        );
      }
      sheet
          .cell(
            CellIndex.indexByColumnRow(
              columnIndex: colIndex,
              rowIndex: rowIndex,
            ),
          )
          .value = TextCellValue(
        'Total',
      );

      // Style header row
      for (int i = 0; i <= colIndex; i++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.fromHexString('FFE0E0E0'),
          horizontalAlign: HorizontalAlign.Center,
        );
      }
      rowIndex++;

      // Write player data rows
      for (final player in displayPlayers) {
        final statsForPlayer = playerStats[player.id] ?? {};

        sheet
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
            )
            .value = TextCellValue(
          player.name,
        );
        sheet
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex),
            )
            .value = TextCellValue(
          player.number?.toString() ?? '-',
        );

        int total = 0;
        int colIdx = 2;
        for (final action in sortedActions) {
          final count = statsForPlayer[action] ?? 0;
          sheet
              .cell(
                CellIndex.indexByColumnRow(
                  columnIndex: colIdx++,
                  rowIndex: rowIndex,
                ),
              )
              .value = IntCellValue(
            count,
          );
          total += count;
        }
        sheet
            .cell(
              CellIndex.indexByColumnRow(
                columnIndex: colIdx,
                rowIndex: rowIndex,
              ),
            )
            .value = IntCellValue(
          total,
        );
        rowIndex++;
      }

      // Add match info sheet
      final infoSheet = excel['Match Info'];
      int infoRow = 0;

      void writeInfoRow(String label, CellValue value) {
        infoSheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: infoRow))
            .value = TextCellValue(
          label,
        );
        infoSheet
                .cell(
                  CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: infoRow),
                )
                .value =
            value;
        infoRow++;
      }

      writeInfoRow('Match Name:', TextCellValue(match.name));
      writeInfoRow(
        'Created At:',
        TextCellValue(match.createdAt.toString().split('.').first),
      );

      if (match.startedAt != null) {
        writeInfoRow(
          'Started At:',
          TextCellValue(match.startedAt!.toString().split('.').first),
        );
      }
      if (match.endedAt != null) {
        writeInfoRow(
          'Ended At:',
          TextCellValue(match.endedAt!.toString().split('.').first),
        );
      }
      writeInfoRow('Total Stats:', IntCellValue(stats.length));

      // Style info sheet headers
      for (int i = 0; i < infoRow; i++) {
        final cell = infoSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i),
        );
        cell.cellStyle = CellStyle(bold: true);
      }

      // Save file
      final bytes = excel.save();
      if (bytes == null) {
        return null;
      }

      // Let user choose where to save
      final fileName =
          '${MatchExportService._sanitizeFileName(match.name)}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Match Statistics',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (path != null) {
        final file = File(path);
        await file.writeAsBytes(bytes);
        return path;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Sanitizes a string to be used as a sheet name
  static String _sanitizeSheetName(String name) {
    // Excel sheet names have restrictions: max 31 chars, no special chars
    String sanitized = name.replaceAll(RegExp(r'[\\/?*\[\]]'), '_');
    if (sanitized.length > 31) {
      sanitized = sanitized.substring(0, 31);
    }
    return sanitized.isEmpty ? 'Sheet1' : sanitized;
  }

  /// Sanitizes a string to be used as a file name
  static String _sanitizeFileName(String name) {
    // Remove invalid file name characters
    String sanitized = name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    // Replace spaces with underscores
    sanitized = sanitized.replaceAll(' ', '_');
    return sanitized;
  }
}
