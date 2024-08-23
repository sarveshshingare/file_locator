import 'package:file_locator/item_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'item_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'item_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ItemProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Locator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<ItemProvider>(context, listen: false).loadItems();
  }

  @override
  Widget build(BuildContext context) {
    final items = Provider.of<ItemProvider>(context).items;
    List<Item> displayedItems = items
        .where((item) =>
            item.name.toLowerCase().contains(_searchController.text.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('File Locator'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search items...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: displayedItems.length,
              itemBuilder: (context, index) {
                final item = displayedItems[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text(item.location),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showAddOrEditDialog(context, item: item);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          Provider.of<ItemProvider>(context, listen: false)
                              .deleteItem(item.id!);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _showAddOrEditDialog(context);
        },
      ),
    );
  }

  void _showAddOrEditDialog(BuildContext context, {Item? item}) {
    final nameController = TextEditingController(text: item?.name ?? '');
    final locationController = TextEditingController(text: item?.location ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(item == null ? 'Add Item' : 'Edit Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Item Name'),
              ),
              TextField(
                controller: locationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(item == null ? 'Add' : 'Update'),
              onPressed: () {
                final name = nameController.text;
                final location = locationController.text;

                if (item == null) {
                  Provider.of<ItemProvider>(context, listen: false)
                      .addItem(name, location);
                } else {
                  Provider.of<ItemProvider>(context, listen: false)
                      .updateItem(item.id!, name, location);
                }

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
