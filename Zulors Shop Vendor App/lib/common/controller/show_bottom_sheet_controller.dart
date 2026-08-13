import 'package:flutter/foundation.dart';

class ShowBottomSheetController extends ChangeNotifier {
  bool _isBottomSheetOpen = false;

  bool get isBottomSheetOpen => _isBottomSheetOpen;

  void openBottomSheet() {
    _isBottomSheetOpen = true;
    notifyListeners();
  }

  void closeBottomSheet() {
    _isBottomSheetOpen = false;
    notifyListeners();
  }
}