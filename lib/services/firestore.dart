import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // reference to notes collection in firestore
  final CollectionReference notes = FirebaseFirestore.instance.collection(
    'notes',
  );

  // create
  Future<void> addNote(String note) {
    return notes.add({
      'note': note,
      'timestamp': Timestamp.now(),
      'isCompleted': false,
    });
  }

  // create note with custom timestamp (for undo)
  Future<void> addNoteWithTimestamp(String note, Timestamp timestamp) {
    return notes.add({
      'note': note,
      'timestamp': timestamp,
      'isCompleted': false,
    });
  }

  // read
  // stream for real-time updates
  Stream<QuerySnapshot> getNotesStream() {
    return notes.orderBy('timestamp', descending: true).snapshots();
  }

  // update
  Future<void> updateNote(String docID, String newNote) {
    return notes.doc(docID).update({
      'note': newNote,
      'timestamp': Timestamp.now(),
    });
  }

  // delete
  Future<void> deleteNote(String docID) {
    return notes.doc(docID).delete();
  }

  // toggle note completion
  Future<void> toggleNoteCompletion(String docID, bool isCompleted) {
    return notes.doc(docID).update({'isCompleted': !isCompleted});
  }
}
