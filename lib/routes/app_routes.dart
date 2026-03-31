import 'package:get/get.dart';
import 'package:application_testing/pages/home_page.dart';
import 'package:application_testing/pages/note_detail_page.dart';
import 'package:application_testing/bindings/home_binding.dart';
import 'package:application_testing/bindings/note_detail_binding.dart';

class AppRoutes {
  static const String home = '/';
  static const String noteDetail = '/note-detail/:docId';
}

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.noteDetail,
      page: () {
        final docId = Get.parameters['docId'] ?? '';
        return NoteDetailPage(docID: docId);
      },
      binding: NoteDetailBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
