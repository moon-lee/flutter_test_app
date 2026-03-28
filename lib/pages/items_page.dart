import 'package:flutter/material.dart';
import '../database/firebase_service.dart';

class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ItemsPageState createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Item> items = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  Item? editingItem;

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> loadItems() async {
    final loadedItems = await _firebaseService.getAllItems();
    setState(() {
      items = loadedItems;
    });
  }

  Future<void> addItem() async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name is required')),
      );
      return;
    }

    try {
      await _firebaseService.addItem(
        nameController.text,
        descriptionController.text.isEmpty ? null : descriptionController.text,
      );
      nameController.clear();
      descriptionController.clear();
      await loadItems();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding item: $e')),
      );
    }
  }

  Future<void> updateItem() async {
    if (editingItem == null || nameController.text.isEmpty) {
      return;
    }

    try {
      await _firebaseService.updateItem(
        editingItem!.id,
        nameController.text,
        descriptionController.text.isEmpty ? null : descriptionController.text,
      );
      nameController.clear();
      descriptionController.clear();
      setState(() {
        editingItem = null;
      });
      await loadItems();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating item: $e')),
      );
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _firebaseService.deleteItem(id);
      await loadItems();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting item: $e')),
      );
    }
  }

  void startEditing(Item item) {
    setState(() {
      editingItem = item;
      nameController.text = item.name;
      descriptionController.text = item.description ?? '';
    });
  }

  void cancelEditing() {
    setState(() {
      editingItem = null;
      nameController.clear();
      descriptionController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Items Manager'),
        elevation: 2,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Use side-by-side layout on larger screens
            if (constraints.maxWidth > 800) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form section - flexible width
                  Flexible(
                    flex: 1,
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              editingItem == null ? 'Add New Item' : 'Edit Item',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: 'Name',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.label),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.description),
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: editingItem == null ? addItem : updateItem,
                                  icon: Icon(editingItem == null ? Icons.add : Icons.save),
                                  label: Text(editingItem == null ? 'Add Item' : 'Update Item'),
                                ),
                                if (editingItem != null) ...[
                                  const SizedBox(width: 12),
                                  OutlinedButton.icon(
                                    onPressed: cancelEditing,
                                    icon: const Icon(Icons.cancel),
                                    label: const Text('Cancel'),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Items list section - flexible width
                  Flexible(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Items List',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Card(
                            elevation: 2,
                            child: SingleChildScrollView(
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(
                                  Theme.of(context).colorScheme.surfaceContainerHighest,
                                ),
                                dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                                  (Set<WidgetState> states) {
                                    if (states.contains(WidgetState.selected)) {
                                      return Theme.of(context).colorScheme.primaryContainer;
                                    }
                                    return null;
                                  },
                                ),
                                columns: const [
                                  DataColumn(
                                    label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  DataColumn(
                                    label: Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  DataColumn(
                                    label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ],
                                rows: items.map((item) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500))),
                                      DataCell(Text(item.description ?? '', maxLines: 2, overflow: TextOverflow.ellipsis)),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit, color: Colors.blue),
                                              tooltip: 'Edit',
                                              onPressed: () => startEditing(item),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                              tooltip: 'Delete',
                                              onPressed: () => deleteItem(item.id),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              // Vertical layout on smaller screens
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 1,
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                editingItem == null ? 'Add New Item' : 'Edit Item',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Name',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.label),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: descriptionController,
                                decoration: const InputDecoration(
                                  labelText: 'Description',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.description),
                                ),
                                maxLines: 3,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: editingItem == null ? addItem : updateItem,
                                    icon: Icon(editingItem == null ? Icons.add : Icons.save),
                                    label: Text(editingItem == null ? 'Add Item' : 'Update Item'),
                                  ),
                                  if (editingItem != null) ...[
                                    const SizedBox(width: 12),
                                    OutlinedButton.icon(
                                      onPressed: cancelEditing,
                                      icon: const Icon(Icons.cancel),
                                      label: const Text('Cancel'),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Flexible(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Items List',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Card(
                            elevation: 2,
                            child: SingleChildScrollView(
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(
                                  Theme.of(context).colorScheme.surfaceContainerHighest,
                                ),
                                dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                                  (Set<WidgetState> states) {
                                    if (states.contains(WidgetState.selected)) {
                                      return Theme.of(context).colorScheme.primaryContainer;
                                    }
                                    return null;
                                  },
                                ),
                                columns: const [
                                  DataColumn(
                                    label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  DataColumn(
                                    label: Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  DataColumn(
                                    label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ],
                                rows: items.map((item) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500))),
                                      DataCell(Text(item.description ?? '', maxLines: 2, overflow: TextOverflow.ellipsis)),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit, color: Colors.blue),
                                              tooltip: 'Edit',
                                              onPressed: () => startEditing(item),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                              tooltip: 'Delete',
                                              onPressed: () => deleteItem(item.id),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}