import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String id;
  final String name;
  final String? description;

  Item({
    required this.id,
    required this.name,
    this.description,
  });

  factory Item.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Item(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
    };
  }
}

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'items';

  Future<List<Item>> getAllItems() async {
    final snapshot = await _firestore.collection(_collectionName).get();
    return snapshot.docs.map((doc) => Item.fromFirestore(doc)).toList();
  }

  Future<Item?> getItem(String id) async {
    final doc = await _firestore.collection(_collectionName).doc(id).get();
    return doc.exists ? Item.fromFirestore(doc) : null;
  }

  Future<String> addItem(String name, String? description) async {
    final docRef = await _firestore.collection(_collectionName).add({
      'name': name,
      'description': description,
    });
    return docRef.id;
  }

  Future<void> updateItem(String id, String name, String? description) async {
    await _firestore.collection(_collectionName).doc(id).update({
      'name': name,
      'description': description,
    });
  }

  Future<void> deleteItem(String id) async {
    await _firestore.collection(_collectionName).doc(id).delete();
  }
}
