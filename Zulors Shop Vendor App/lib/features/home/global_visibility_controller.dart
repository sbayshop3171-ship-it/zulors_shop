import 'package:flutter/material.dart';

class GlobalVisibilityController {
  // Shared ScrollController
  static ScrollController scrollController = ScrollController();

  // Visibility notifier for the global component
  static final ValueNotifier<bool> isVisible = ValueNotifier(true);

  // Internal variables
  static double _lastOffset = 0;
  static VoidCallback? _listener;

  /// Call this in `initState` of each scrollable screen
  static void initListener() {
    // Reset last offset (optional but safer)
    _lastOffset = 0;

    // Prevent duplicate listeners
    _listener ??= () {
      final offset = scrollController.offset;

      if (offset > _lastOffset + 10) {
        // Scrolling down
        if (isVisible.value) isVisible.value = false;
      } else if (offset < _lastOffset - 10) {
        // Scrolling up
        if (!isVisible.value) isVisible.value = true;
      }

      _lastOffset = offset;
    };

    // Attach listener
    scrollController.addListener(_listener!);
  }

  /// Call this in `dispose` of each screen using the controller
  static void disposeScrollController() {
    if (_listener != null) {
      scrollController.removeListener(_listener!);
      _listener = null;
    }

    // Dispose and reset the controller so a new screen can re-init
    scrollController.dispose();

    // Create a fresh controller for the next screen
    scrollController = ScrollController();
  }
}