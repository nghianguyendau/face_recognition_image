import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreHelper {
  static const String collectionName = 'faces';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference<Map<String, dynamic>> _facesCollection;

  FirestoreHelper() {
    _facesCollection = _firestore.collection(collectionName);
  }


  Future<String> insert(Map<String, dynamic> data) async {
    DocumentReference docRef = await _facesCollection.add(data);
    return docRef.id;
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    QuerySnapshot querySnapshot = await _facesCollection.get();
    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Future<int?> queryRowCount() async {
    AggregateQuerySnapshot snapshot = await _facesCollection.count().get();
    return snapshot.count;
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await _facesCollection.doc(id).update(data);
  }

  Future<void> delete(String id) async {
    await _facesCollection.doc(id).delete();
  }
}