import 'package:isar/isar.dart';

part 'interaction_log.model.g.dart';

@collection
class InteractionLog {
  Id id = Isar.autoIncrement;
  late DateTime timestamp;
  late String actionType;
  late String target;
}
