import 'package:get/get.dart';
import 'package:application_testing/controllers/note_controller.dart';

class HomeBinding extends Bindings {
  // dependency injection for NoteController
  @override
  void dependencies() {
    Get.lazyPut<NoteController>(() => NoteController(), fenix: true);
  }
}
