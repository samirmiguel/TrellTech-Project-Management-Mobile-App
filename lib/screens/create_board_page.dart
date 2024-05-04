import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trello_wish/models/user_data.dart'; // Assurez-vous que le chemin est correct
import 'package:trello_wish/services/trello_service.dart'; // Assurez-vous que le chemin est correct

class CreateBoardPage extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Créer un nouveau Board')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Nom du Board'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _createBoard(context),
              child: Text('Créer'),
            ),
          ],
        ),
      ),
    );
  }

  void _createBoard(BuildContext context) {
    final userToken = Provider.of<UserData>(context, listen: false).userToken;
    if (_controller.text.isNotEmpty && userToken.isNotEmpty) {
      TrelloService().createBoard(_controller.text, userToken).then((success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Board créé avec succès' : "Échec de la création du board")));
      });
    }
  }
}
