import 'dart:async';
import 'package:application_testing/constants/app_constants.dart';
import 'package:application_testing/services/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// to manage notes
class NoteController extends GetxController {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController textController = TextEditingController();

  // observable list of notes
  final RxList<DocumentSnapshot> notesList = <DocumentSnapshot>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt currentTime = DateTime.now().millisecondsSinceEpoch.obs;
  late StreamSubscription<QuerySnapshot> _notesSubscription;
  late Timer _timer;

  @override
  void onInit() {
    super.onInit();
    fetchNotes();
    _startTimer();
  }

  @override
  void onClose() {
    textController.dispose();
    _notesSubscription.cancel();
    _timer.cancel();
    super.onClose();
  }

  // start timer to update current time every second
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      currentTime.value = DateTime.now().millisecondsSinceEpoch;
    });
  }

  // format timestamp to relative time
  String formatTimestamp(Timestamp timestamp) {
    final noteTime = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(noteTime);

    if (difference.inSeconds < 1) return TimestampConstants.justNow;
    if (difference.inMinutes < 1) {
      return '${difference.inSeconds}${TimestampConstants.secondsAgo}';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes}${TimestampConstants.minutesAgo}';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours}${TimestampConstants.hoursAgo}';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays}${TimestampConstants.daysAgo}';
    }
    return formatFullTimestamp(timestamp);
  }

  // format timestamp with full HH:MM:SS
  String formatFullTimestamp(Timestamp timestamp) {
    final noteTime = timestamp.toDate();
    return '${noteTime.day.toString().padLeft(2, '0')}/${noteTime.month.toString().padLeft(2, '0')}/${noteTime.year} '
        '${noteTime.hour.toString().padLeft(2, '0')}:${noteTime.minute.toString().padLeft(2, '0')}:${noteTime.second.toString().padLeft(2, '0')}';
  }

  // group notes into pending and completed
  Map<String, List<DocumentSnapshot>> get groupedNotes {
    final pending = <DocumentSnapshot>[];
    final completed = <DocumentSnapshot>[];

    for (var note in notesList) {
      final noteData = note.data() as Map<String, dynamic>;
      if (noteData['isCompleted'] ?? false) {
        completed.add(note);
      } else {
        pending.add(note);
      }
    }

    return {'pending': pending, 'completed': completed};
  }

  // fetch notes stream
  void fetchNotes() {
    _notesSubscription = firestoreService.getNotesStream().listen((snapshot) {
      notesList.value = snapshot.docs;
    });
  }

  // add note
  Future<void> addNote(String note) async {
    if (note.isEmpty) {
      Get.snackbar(SnackbarConstants.error, SnackbarConstants.noteCantBeEmpty);
      return;
    }
    try {
      isLoading.value = true;
      await firestoreService.addNote(note);
      textController.clear();
      Get.snackbar(SnackbarConstants.success, SnackbarConstants.noteAdded);
      Get.back();
    } catch (e) {
      Get.snackbar(
        SnackbarConstants.error,
        '${SnackbarConstants.failedToAdd}: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // update note
  Future<void> updateNote(String docID, String newNote) async {
    if (newNote.isEmpty) {
      Get.snackbar(SnackbarConstants.error, SnackbarConstants.noteCantBeEmpty);
      return;
    }
    try {
      isLoading.value = true;
      await firestoreService.updateNote(docID, newNote);
      textController.clear();
      Get.snackbar(SnackbarConstants.success, SnackbarConstants.noteUpdated);
      Get.back();
    } catch (e) {
      Get.snackbar(
        SnackbarConstants.error,
        '${SnackbarConstants.failedToUpdate}: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // delete note with undo capability
  DocumentSnapshot? _deletedNote;

  Future<void> deleteNoteWithUndo(String docID) async {
    try {
      final note = notesList.firstWhereOrNull((n) => n.id == docID);
      if (note != null) {
        _deletedNote = note;
        await firestoreService.deleteNote(docID);
      }
    } catch (e) {
      Get.snackbar(
        SnackbarConstants.error,
        '${SnackbarConstants.failedToDelete}: $e',
      );
    }
  }

  // undo delete note
  Future<void> undoDeleteNote() async {
    if (_deletedNote == null) return;
    try {
      final data = _deletedNote!.data() as Map<String, dynamic>;
      final oldTimestamp = data['timestamp'] as Timestamp;
      // re-add note with original timestamp
      await firestoreService.addNoteWithTimestamp(data['note'], oldTimestamp);
      _deletedNote = null;
    } catch (e) {
      Get.snackbar(
        SnackbarConstants.error,
        '${SnackbarConstants.failedToRestore}: $e',
      );
    }
  }

  // delete note
  Future<void> deleteNote(String docID) async {
    try {
      await firestoreService.deleteNote(docID);
      Get.snackbar(SnackbarConstants.success, SnackbarConstants.noteDeleted);
    } catch (e) {
      Get.snackbar(
        SnackbarConstants.error,
        '${SnackbarConstants.failedToDelete}: $e',
      );
    }
  }

  // toggle note completion
  Future<void> toggleNoteCompletion(String docID, bool isCompleted) async {
    try {
      await firestoreService.toggleNoteCompletion(docID, isCompleted);
      // Show notification based on completion status
      final message = isCompleted
          ? SnackbarConstants.noteIncompleted
          : SnackbarConstants.noteCompleted;
      Get.snackbar(SnackbarConstants.success, message);
    } catch (e) {
      Get.snackbar(
        SnackbarConstants.error,
        '${SnackbarConstants.failedToToggle}: $e',
      );
    }
  }

  // open dialog to add note
  void openAddNoteBox() {
    textController.clear();

    Get.dialog(
      AlertDialog(
        title: const Text(DialogConstants.addNote),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: DialogConstants.enterNoteHere,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(DialogConstants.cancel),
          ),
          TextButton(
            onPressed: () {
              addNote(textController.text);
            },
            child: const Text(DialogConstants.save),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // open dialog to edit note
  void openEditNoteBox(String docID) {
    final note = notesList.firstWhereOrNull((n) => n.id == docID);
    if (note != null) {
      Map<String, dynamic> noteData = note.data() as Map<String, dynamic>;
      textController.text = noteData['note'] ?? '';
    }

    Get.dialog(
      AlertDialog(
        title: const Text(DialogConstants.editNote),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: DialogConstants.enterNoteHere,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(DialogConstants.cancel),
          ),
          TextButton(
            onPressed: () {
              updateNote(docID, textController.text);
            },
            child: const Text(DialogConstants.update),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
