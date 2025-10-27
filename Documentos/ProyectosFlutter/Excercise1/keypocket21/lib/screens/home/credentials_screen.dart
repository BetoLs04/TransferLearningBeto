import 'package:flutter/material.dart';
import '../../models/credential.dart';
import '../../services/local_storage.dart';

class CredentialsScreen extends StatefulWidget {
  final String userId;
  final String? categoryId;
  final String? categoryName;

  const CredentialsScreen({
    Key? key,
    required this.userId,
    this.categoryId,
    this.categoryName,
  }) : super(key: key);

  @override
  _CredentialsScreenState createState() => _CredentialsScreenState();
}

class _CredentialsScreenState extends State<CredentialsScreen> {
  List<Credential> _credentials = [];
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    try {
      List<Credential> credentials;
      if (widget.categoryId != null) {
        credentials = await LocalStorage.getCredentialsByCategory(
          widget.categoryId!,
          widget.userId,
        );
      } else {
        credentials = await LocalStorage.getAllCredentials(widget.userId);
      }
      setState(() => _credentials = credentials);
    } catch (e) {
      print('Error cargando credenciales: $e');
    }
  }

  void _showAddCredentialDialog() {
    if (widget.categoryId == null) {
      _showErrorDialog('No se puede agregar credencial', 'Primero selecciona una categoría');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => CredentialDialog(
        userId: widget.userId,
        categoryId: widget.categoryId!,
        onSaved: _loadCredentials,
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCredential(String id) async {
    try {
      await LocalStorage.deleteCredential(id, widget.userId);
      _loadCredentials();
    } catch (e) {
      print('Error eliminando credencial: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName ?? 'Todas las Credenciales'),
      ),
      body: widget.categoryId == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning, size: 64, color: Colors.orange),
                  SizedBox(height: 16),
                  Text(
                    'Selecciona una categoría',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Para agregar credenciales, primero selecciona una categoría',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : _credentials.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No hay credenciales',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Agrega tu primera credencial',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _credentials.length,
                  itemBuilder: (context, index) {
                    final credential = _credentials[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        leading: Icon(Icons.lock, color: Colors.green),
                        title: Text(
                          credential.title,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text('Usuario: ${credential.username}'),
                            Text('Email: ${credential.email}'),
                            Text(
                              'Contraseña: ${_obscurePassword ? '••••••••' : credential.password}',
                            ),
                            if (credential.website != null) Text('Sitio: ${credential.website}'),
                            if (credential.notes != null) Text('Notas: ${credential.notes}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                color: Colors.blue,
                              ),
                              onPressed: () {
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteConfirmation(credential),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: widget.categoryId != null
          ? FloatingActionButton(
              onPressed: _showAddCredentialDialog,
              child: Icon(Icons.add),
              backgroundColor: Colors.blue,
            )
          : null,
    );
  }

  void _showDeleteConfirmation(Credential credential) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Credencial'),
        content: Text('¿Estás seguro de que quieres eliminar la credencial "${credential.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteCredential(credential.id);
            },
            child: Text('Eliminar'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}

class CredentialDialog extends StatefulWidget {
  final String userId;
  final String categoryId;
  final VoidCallback onSaved;

  const CredentialDialog({
    Key? key,
    required this.userId,
    required this.categoryId,
    required this.onSaved,
  }) : super(key: key);

  @override
  _CredentialDialogState createState() => _CredentialDialogState();
}

class _CredentialDialogState extends State<CredentialDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _websiteController = TextEditingController();
  final _notesController = TextEditingController();

  Future<void> _saveCredential() async {
    if (!_formKey.currentState!.validate()) return;

    final credential = Credential(
      id: LocalStorage.generateId(),
      title: _titleController.text,
      username: _usernameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      website: _websiteController.text.isEmpty ? null : _websiteController.text,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      categoryId: widget.categoryId,
      userId: widget.userId,
      createdAt: DateTime.now(),
    );

    try {
      await LocalStorage.insertCredential(credential);
      widget.onSaved();
      Navigator.of(context).pop();
    } catch (e) {
      print('Error guardando credencial: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Nueva Credencial'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Título *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un título';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Usuario',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña *',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una contraseña';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _websiteController,
                decoration: InputDecoration(
                  labelText: 'Website (opcional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notas (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saveCredential,
          child: Text('Guardar'),
        ),
      ],
    );
  }
}