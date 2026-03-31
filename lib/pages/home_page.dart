import 'package:application_testing/controllers/note_controller.dart';
import 'package:application_testing/constants/app_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:application_testing/routes/app_routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final NoteController noteController = Get.find<NoteController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          UIConstants.appTitle,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromARGB(255, 221, 197, 255),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => noteController.openAddNoteBox(),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (noteController.notesList.isEmpty) {
          return const Center(child: Text(UIConstants.noTasksAvailable));
        }

        final grouped = noteController.groupedNotes;
        final pendingNotes = grouped['pending'] ?? [];
        final completedNotes = grouped['completed'] ?? [];

        // build list of widgets
        final items = <Widget>[];

        // pending section
        if (pendingNotes.isNotEmpty) {
          items.add(
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                '${UIConstants.pendingTasks} (${pendingNotes.length})',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          );
          items.addAll(
            pendingNotes.map((note) => _buildNoteCard(note, noteController)),
          );
        }

        // completed section
        if (completedNotes.isNotEmpty) {
          items.add(
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                '${UIConstants.completedTasks} (${completedNotes.length})',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          );
          items.addAll(
            completedNotes.map((note) => _buildNoteCard(note, noteController)),
          );
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          children: items,
        );
      }),
    );
  }

  Widget _buildNoteCard(DocumentSnapshot note, NoteController noteController) {
    String docID = note.id;
    Map<String, dynamic> noteData = note.data() as Map<String, dynamic>;
    String noteContent = noteData['note'];
    bool isCompleted = noteData['isCompleted'] ?? false;

    return Obx(() {
      // trigger update every second using currentTime
      noteController.currentTime.value;

      String formattedTime = '';
      if (noteData['timestamp'] != null) {
        formattedTime = noteController.formatTimestamp(
          noteData['timestamp'] as Timestamp,
        );
      }

      return Dismissible(
        key: Key(docID),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white, size: 28),
        ),
        secondaryBackground: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white, size: 28),
        ),
        onDismissed: (direction) {
          noteController.deleteNoteWithUndo(docID);
          Get.snackbar(
            SnackbarConstants.deleted,
            SnackbarConstants.noteDeleted,
            duration: const Duration(seconds: 3),
            mainButton: TextButton(
              onPressed: () {
                noteController.undoDeleteNote();
                Get.closeCurrentSnackbar();
              },
              child: const Text(
                ButtonConstants.undo,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
        child: Card(
          margin: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
          elevation: 4,
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              // route to note detail page
              Get.toNamed(AppRoutes.noteDetail.replaceAll(':docId', docID));
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: isCompleted
                      ? [
                          Color.fromARGB(255, 240, 250, 240),
                          Color.fromARGB(255, 220, 240, 220),
                        ]
                      : [
                          Color.fromARGB(255, 245, 235, 255),
                          Color.fromARGB(255, 235, 220, 255),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                leading: GestureDetector(
                  onTap: () {
                    noteController.toggleNoteCompletion(docID, isCompleted);
                  },
                  child: Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted ? Colors.green : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              color: Colors.green,
                              size: 15,
                            )
                          : null,
                    ),
                  ),
                ),
                title: Text(
                  noteContent,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? Colors.grey : Colors.black87,
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Text(
                        formattedTime,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
