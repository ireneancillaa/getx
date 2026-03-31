import 'package:get/get.dart';
import 'package:application_testing/controllers/note_controller.dart';

class NoteDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NoteController>(() => NoteController(), fenix: true);
  }
}
