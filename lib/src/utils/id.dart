import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Generates a unique ID for layout entities.
String generateId() => _uuid.v4();
