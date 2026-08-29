import 'package:flutter/cupertino.dart';

// class ProgressNotifier extends ValueNotifier<int> {
//   ProgressNotifier() : super(0);

//   void updateProgress(int progress) {
//     value = progress;
//   }
// }

class ProgressNotifier extends ChangeNotifier {
  double _progress = 0.0;

  double get progress => _progress;

  void updateProgress(int percent) {
    _progress = percent / 100;
    notifyListeners();
  }

  void reset() {
    _progress = 0.0;
    notifyListeners();
  }
}
