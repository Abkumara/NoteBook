// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
// final user = _firebaseAuth.currentUser;

// class FireStore {
//   //get collection

//   final CollectionReference notes = FirebaseFirestore.instance
//       .collection('users')
//       .doc(user?.uid)
//       .collection('notes');
//   //Create Data
//   Future<void> addNote(String Note, String userId) {
//     return notes.add({
//       'note': Note,
//       'timeStamp': Timestamp.now(),
//       'userId': userId,
//     });
//   }

//   //Read Data
//   Stream<QuerySnapshot> getNotesStream(String userId) {
//     final noteStream = notes
//         .where('userId', isEqualTo: userId)
//         .orderBy('timeStamp', descending: true)
//         .snapshots();
//     return noteStream;
//   }

//   //Update Data
//   Future<void> updateNote(String docID, String newNote) {
//     return notes
//         .doc(docID)
//         .update({'note': newNote, 'timeStamp': Timestamp.now()});
//   }

//   //Delete Data
//   Future<void> deleteNote(String docId) {
//     return notes.doc(docId).delete();
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FireStore {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late User? _currentUser;

  FireStore() {
    _currentUser = _firebaseAuth.currentUser;
  }

  // Getter for notes collection
  CollectionReference get notes {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser?.uid)
        .collection('notes');
  }

  // Create Data
  Future<void> addNote(String note) async {
    await notes.add({
      'note': note,
      'timeStamp': Timestamp.now(),
      'userId': _currentUser?.uid,
    });
  }

  // Read Data
  Stream<QuerySnapshot> getNotesStream() {
    final noteStream = notes.orderBy('timeStamp', descending: true).snapshots();
    return noteStream;
  }

  // Update Data
  Future<void> updateNote(String docID, String newNote) async {
    await notes
        .doc(docID)
        .update({'note': newNote, 'timeStamp': Timestamp.now()});
  }

  // Delete Data
  Future<void> deleteNote(String docId) async {
    await notes.doc(docId).delete();
  }
}
