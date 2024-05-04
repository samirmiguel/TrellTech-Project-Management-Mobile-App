import 'package:flutter/material.dart';
import '../api/trello_api.dart';

class CreateWorkspaceScreen extends StatefulWidget {
  @override
  _CreateWorkspaceScreenState createState() => _CreateWorkspaceScreenState();
}

class _CreateWorkspaceScreenState extends State<CreateWorkspaceScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _createWorkspace() async {
    String name = _nameController.text;
    String description = _descriptionController.text;


    var trelloApi = TrelloAPI(apiKey: apiKey, token: token);

    bool success = await trelloApi.createWorkspace(name, description);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Workspace créé avec succès')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la création du workspace')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Créer un Workspace'),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nom du Workspace'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createWorkspace,
              child: Text('Créer'),
            ),
          ],
        ),
      ),
    );
  }
}
