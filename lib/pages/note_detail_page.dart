import 'package:application_testing/controllers/note_controller.dart';
import 'package:application_testing/constants/app_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NoteDetailPage extends StatelessWidget {
  final String docID;

  const NoteDetailPage({required this.docID, super.key});

  @override
  Widget build(BuildContext context) {
    final NoteController noteController = Get.find<NoteController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromARGB(255, 221, 197, 255),
        elevation: 0,
      ),
      body: Obx(() {
        final note = noteController.notesList.firstWhereOrNull(
          (n) => n.id == docID,
        );

        if (note == null) {
          return const Center(child: Text(UIConstants.noTasksAvailable));
        }

        final noteData = note.data() as Map<String, dynamic>;
        final noteContent = noteData['note'] ?? '';
        final isCompleted = noteData['isCompleted'] ?? false;

        // trigger update every second
        noteController.currentTime.value;

        // format detailed timestamp with HH:MM:SS
        String formattedTimestamp = '';
        if (noteData['timestamp'] != null) {
          formattedTimestamp = noteController.formatFullTimestamp(
            noteData['timestamp'] as Timestamp,
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Note Content Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 245, 235, 255),
                          Color.fromARGB(255, 235, 220, 255),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isCompleted
                                      ? Colors.green
                                      : Colors.grey,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: isCompleted
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.green,
                                        size: 18,
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                noteContent,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: isCompleted
                                      ? Colors.grey
                                      : Colors.black87,
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Timestamp Info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Colors.black54,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Last updated: $formattedTimestamp',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                const Text(
                  'Actions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                // Toggle Completion Button
                ElevatedButton.icon(
                  onPressed: () {
                    noteController.toggleNoteCompletion(docID, isCompleted);
                  },
                  icon: Icon(isCompleted ? Icons.undo : Icons.check_circle),
                  label: Text(
                    isCompleted ? 'Mark as Incomplete' : 'Mark as Complete',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
                const SizedBox(height: 12),

                // Edit Button
                ElevatedButton.icon(
                  onPressed: () {
                    noteController.openEditNoteBox(docID);
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Note'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
                const SizedBox(height: 12),

                // Delete Button
                ElevatedButton.icon(
                  onPressed: () {
                    Get.dialog(
                      AlertDialog(
                        title: const Text(DialogConstants.deleteNote),
                        content: const Text(DialogConstants.deleteConfirmation),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text(DialogConstants.cancel),
                          ),
                          TextButton(
                            onPressed: () {
                              noteController.deleteNote(docID);
                              Get.back();
                              Get.back();
                            },
                            child: const Text(
                              DialogConstants.delete,
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete Note'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
