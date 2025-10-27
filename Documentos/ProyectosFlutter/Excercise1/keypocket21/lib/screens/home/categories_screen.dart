import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../services/local_storage.dart';
import 'credentials_screen.dart';

class CategoriesScreen extends StatefulWidget {
  final String userId;

  const CategoriesScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _categoryNameController = TextEditingController();
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await LocalStorage.getCategories(widget.userId);
      setState(() => _categories = categories);
    } catch (e) {
      print('Error cargando categorías: $e');
    }
  }

  Future<void> _addCategory() async {
    if (_categoryNameController.text.isEmpty) return;

    final newCategory = Category(
      id: LocalStorage.generateId(),
      name: _categoryNameController.text,
      userId: widget.userId,
      createdAt: DateTime.now(),
    );

    try {
      await LocalStorage.insertCategory(newCategory);
      _categoryNameController.clear();
      await _loadCategories();
      Navigator.of(context).pop();
    } catch (e) {
      print('Error agregando categoría: $e');
    }
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nueva Categoría'),
        content: TextField(
          controller: _categoryNameController,
          decoration: InputDecoration(
            hintText: 'Nombre de la categoría',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: _addCategory,
            child: Text('Agregar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(String id) async {
    try {
      await LocalStorage.deleteCategory(id, widget.userId);
      await _loadCategories();
    } catch (e) {
      print('Error eliminando categoría: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _categories.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay categorías',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Agrega una nueva categoría para comenzar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: Icon(Icons.category, color: Colors.blue),
                    title: Text(
                      category.name,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      'Creada: ${_formatDate(category.createdAt)}',
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteConfirmation(category),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CredentialsScreen(
                            userId: widget.userId,
                            categoryId: category.id,
                            categoryName: category.name,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showDeleteConfirmation(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Categoría'),
        content: Text('¿Estás seguro de que quieres eliminar la categoría "${category.name}"? También se eliminarán todas sus credenciales.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteCategory(category.id);
            },
            child: Text('Eliminar'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}