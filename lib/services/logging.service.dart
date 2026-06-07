import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/interaction_log.model.dart';

class LoggingService {
  final Isar isar;

  LoggingService(this.isar);

  Future<void> logAction(String actionType, String target) async {
    final log = InteractionLog()
      ..timestamp = DateTime.now()
      ..actionType = actionType
      ..target = target;

    await isar.writeTxn(() async {
      await isar.interactionLogs.put(log);
    });

    print('📍 LOGGED: $actionType -> $target');
  }

  Future<List<InteractionLog>> getAllLogs() async {
    return await isar.interactionLogs.where().findAll();
  }

  Future<void> exportLogsToFileAndShare() async {
    final logs = await getAllLogs();

    StringBuffer csvData = StringBuffer();
    csvData.writeln("Timestamp,ActionType,Target");

    for (var l in logs) {
      csvData.writeln(
        "${l.timestamp.toIso8601String()},${l.actionType},${l.target}",
      );
    }

    try {
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/interaction_logs.csv';
      final file = File(path);

      await file.writeAsString(csvData.toString());

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(path)],
          text: 'Interaction Logs - Final Project',
        ),
      );
    } catch (e) {
      print("Error saving the file: $e");
    }
  }
}
