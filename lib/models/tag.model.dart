import 'package:isar/isar.dart';
import 'package:recipe_app_final_project/enums/tag_type.enum.dart';

part 'tag.model.g.dart';

@collection
class Tag {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;

  @Enumerated(EnumType.name)
  TagType? type;
}
