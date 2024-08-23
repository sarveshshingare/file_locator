import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemProvider with ChangeNotifier {
  List<Item> _items = [];
  DBHelper _dbHelper = DBHelper();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Item> get items => _items;

  Future<void> loadItems() async {
    final data = await _dbHelper.queryAllItems();
    _items = data.map((item) => Item.fromMap(item)).toList();
    notifyListeners();
  }

  Future<void> addItem(String name, String location) async {
    final newItem = Item(name: name, location: location);
    
    // Save to local database
    int id = await _dbHelper.insertItem(newItem.toMap());
    
    // Save to Firebase
    await _firestore.collection('items').add({
      'id': id,
      'name': name,
      'location': location,
    });
    
    await loadItems();
  }

  Future<void> updateItem(int id, String name, String location) async {
    final updatedItem = Item(id: id, name: name, location: location);
    
    // Update local database
    await _dbHelper.updateItem(updatedItem.toMap());
    
    // Update Firebase
    var snapshot = await _firestore.collection('items')
        .where('id', isEqualTo: id)
        .get();
    
    if (snapshot.docs.isNotEmpty) {
      await _firestore.collection('items').doc(snapshot.docs.first.id).update({
        'name': name,
        'location': location,
      });
    }
    
    await loadItems();
  }

  Future<void> deleteItem(int id) async {
    // Delete from local database
    await _dbHelper.deleteItem(id);
    
    // Delete from Firebase
    var snapshot = await _firestore.collection('items')
        .where('id', isEqualTo: id)
        .get();
    
    if (snapshot.docs.isNotEmpty) {
      await _firestore.collection('items').doc(snapshot.docs.first.id).delete();
    }
    
    await loadItems();
  }
}
