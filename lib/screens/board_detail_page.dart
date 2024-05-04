import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:trello_wish/api/trello_api.dart' as trelloApi;
import 'package:trello_wish/models/trelloCard.dart';
import 'package:trello_wish/screens/CreateCardPage.dart';
import 'package:trello_wish/screens/card_detail_page.dart';

class BoardDetailPage extends StatefulWidget {
  final String boardId;

  BoardDetailPage({Key? key, required this.boardId}) : super(key: key);

  @override
  _BoardDetailPageState createState() => _BoardDetailPageState();
}

class _BoardDetailPageState extends State<BoardDetailPage> {
  Future<bool> deleteCard(String cardId) async {
    final apiKey = trelloApi.TrelloAPI.apiKey;
    final apiToken = trelloApi.TrelloAPI.apiToken;
    final url = 'https://api.trello.com/1/cards/$cardId?key=$apiKey&token=$apiToken';

    final response = await http.delete(Uri.parse(url));

    if (response.statusCode == 200) {
      print("Carte supprimée avec succès");
      return true; // La carte a été supprimée avec succès
    } else {
      print("Échec de la suppression de la carte: ${response.body}");
      return false; // Échec de la suppression de la carte
    }
  }

  late Future<Map<String, List<TrelloCard>>> _cardsFuture;

  @override
  void initState() {
    super.initState();
    _cardsFuture = fetchBoardDetails(widget.boardId);
  }

  Future<Map<String, List<TrelloCard>>> fetchBoardDetails(String boardId) async {
    Map<String, String> listNames = await fetchLists(boardId);
    List<TrelloCard> cards = await fetchCards(boardId);
    Map<String, List<TrelloCard>> cardsByListName = {
      for (var name in listNames.values) name: []
    };

    for (TrelloCard card in cards) {
      String listName = listNames[card.idList] ?? "Liste inconnue";
      card.listName = listName;
      cardsByListName[listName]!.add(card);
    }

    return cardsByListName;
  }

Future<List<TrelloCard>> fetchCards(String boardId) async {
  const apiKey = trelloApi.TrelloAPI.apiKey;
  const apiToken = trelloApi.TrelloAPI.apiToken;
  final response = await http.get(
    Uri.parse(
        'https://api.trello.com/1/boards/$boardId/cards?key=$apiKey&token=$apiToken'),
  );

  if (response.statusCode == 200) {
    List<dynamic> cardsJson = json.decode(response.body);
    // Pass an empty list of members as a placeholder
    return cardsJson.map((json) => TrelloCard.fromJson(json, [])).toList();
  } else {
    throw Exception('Failed to load cards');
  }
}


  Future<Map<String, String>> fetchLists(String boardId) async {
    final response = await http.get(
      Uri.parse(
          'https://api.trello.com/1/boards/$boardId/lists?key=${trelloApi.TrelloAPI.apiKey}&token=${trelloApi.TrelloAPI.apiToken}'),
    );

    if (response.statusCode == 200) {
      List<dynamic> listsJson = json.decode(response.body);
      Map<String, String> listNames = {};
      for (var list in listsJson) {
        listNames[list['id']] = list['name'];
      }
      return listNames;
    } else {
      throw Exception('Failed to load lists');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du Tableau', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, List<TrelloCard>>>(
        future: _cardsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text("Erreur: ${snapshot.error}", style: TextStyle(fontSize: 18)));
            }

            var cardsByListName = snapshot.data!;
            if (cardsByListName.isEmpty) {
              return Center(child: Text("Aucune carte disponible", style: TextStyle(fontSize: 18)));
            }

            return ListView(
              padding: EdgeInsets.all(8),
              children: cardsByListName.entries.map<Widget>((entry) {
                String title = '${entry.key} (${entry.value.length})';
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ExpansionTile(
                    title: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                    children: entry.value.isNotEmpty
                        ? entry.value.map((card) {
                      return ListTile(
                        title: Text(card.name, style: TextStyle(color: Colors.deepPurple[800])),
                        subtitle: Text(card.desc, overflow: TextOverflow.ellipsis),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () async {
                            final bool deleted = await deleteCard(card.id);
                            if (deleted) {
                              setState(() {
                                _cardsFuture = fetchBoardDetails(widget.boardId);
                              });
                            }
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CardDetailPage(cardId: card.id)),
                          );
                        },
                      );
                    }).toList()
                        : [Center(child: Text("Pas de carte dans cette liste"))],
                  ),
                );
              }).toList(),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(
            MaterialPageRoute(builder: (context) => CreateCardPage(boardId: widget.boardId)),
          )
              .then((value) {
            if (value == true) {
              setState(() {
                _cardsFuture = fetchBoardDetails(widget.boardId);
              });
            }
          });
        },
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

}


