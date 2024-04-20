import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_note_app/firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FireStore fireStore = FireStore();
  final TextEditingController noteController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late User? currentUser;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() {
    currentUser = _firebaseAuth.currentUser;
  }

  void openNote({String? docId}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: TextField(
            controller: noteController,
          ),
          title: const Text('Note'),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (docId == null) {
                  fireStore.addNote(
                    noteController.text,
                  );
                } else {
                  fireStore.updateNote(docId, noteController.text);
                }
                noteController.clear();
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
              onPressed: () => _firebaseAuth.signOut(),
              icon: const Icon(Icons.logout))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openNote,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: fireStore.getNotesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List noteList = snapshot.data!.docs;
            return ListView.builder(
              itemCount: noteList.length,
              itemBuilder: (context, index) {
                //get each doc
                DocumentSnapshot document = noteList[index];
                String docID = document.id;
                //get note from each doc
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String note = data['note'];

                //display as a list title
                return ListTile(
                  title: Text(note),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => openNote(docId: docID),
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: () => fireStore.deleteNote(docID),
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Text('No notes');
          }
        },
      ),
    );
  }
}
