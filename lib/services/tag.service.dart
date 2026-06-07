import 'package:isar/isar.dart';
import 'package:recipe_app_final_project/models/tag.model.dart';

class TagService {
  final Isar isar;

  TagService(this.isar);

  Future<List<Tag>> getAllTags() async {
    return await isar.tags.where().findAll();
  }

  Future<Tag?> getTagByName(String name) async {
    return await isar.tags.filter().nameEqualTo(name).findFirst();
  }

  Future<void> saveTag(Tag tag) async {
    await isar.writeTxn(() async {
      await isar.tags.put(tag);
    });
  }
}
