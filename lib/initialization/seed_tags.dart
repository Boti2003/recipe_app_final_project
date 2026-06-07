import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:isar/isar.dart';
import 'package:recipe_app_final_project/enums/tag_type.enum.dart';
import 'package:recipe_app_final_project/models/tag.model.dart';
import '../main.dart'; // a getIt miatt

Future<void> seedTagsFromJson() async {
  final isar = getIt<Isar>();

  final count = await isar.tags.count();

  if (count == 0) {
    final String jsonString = await rootBundle.loadString('assets/tags.json');
    final List<dynamic> jsonList = jsonDecode(jsonString);

    final tagsToInsert = jsonList.map((json) {
      return Tag()
        ..name = json['name']
        ..type = TagType.values.firstWhere((e) => e.name == json['type']);
    }).toList();

    await isar.writeTxn(() async {
      await isar.tags.putAll(tagsToInsert);
    });

    print('Tags seeded successfully from JSON!');
  }
}
