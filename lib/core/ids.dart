import 'package:uuid/uuid.dart';

/// Generates a random (v4) UUID string, used as the primary key for every
/// row inserted through the repositories.
String newId() => const Uuid().v4();
