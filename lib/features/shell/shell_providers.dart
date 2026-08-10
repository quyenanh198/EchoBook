import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Index of the currently selected bottom-tab / rail destination.
final currentTabProvider = StateProvider<int>((ref) => 0);

/// Id of the book currently open in the Reader tab (null = no book open).
final activeBookIdProvider = StateProvider<String?>((ref) => null);
