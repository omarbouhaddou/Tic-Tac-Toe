import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  // Fonction pour supprimer l'historique
  Future<void> _deleteHistory() async {
    try {
      // Accéder à la collection "match_history" dans Firestore
      final firestore = FirebaseFirestore.instance;
      final collection = firestore.collection('match_history');

      // Récupérer tous les documents de la collection
      var snapshots = await collection.get();

      // Supprimer chaque document de la collection
      for (var doc in snapshots.docs) {
        await doc.reference.delete();
      }

      print("Historique supprimé avec succès !");
    } catch (e) {
      print("Erreur lors de la suppression de l'historique : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Corps principal
      body: Container(
        // Décoration : dégradé de couleurs
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.purpleAccent], // Dégradé bleu/violet
            begin: Alignment.topCenter, // Départ du dégradé en haut
            end: Alignment.bottomCenter, // Fin du dégradé en bas
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Barre supérieure contenant le titre et les icônes
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribution des éléments
                  children: [
                    // Bouton retour à l'écran précédent
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context), // Retourner à la page précédente
                    ),
                    // Titre de la page
                    const Text(
                      'Match History',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    // Icône de suppression pour vider l'historique
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () async {
                        // Afficher une boîte de dialogue de confirmation
                        final shouldDelete = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirmer la suppression'),
                                content: const Text(
                                    'Êtes-vous sûr de vouloir supprimer tout l\'historique ?'),
                                actions: [
                                  // Bouton pour annuler la suppression
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Annuler'),
                                  ),
                                  // Bouton pour confirmer la suppression
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Supprimer'),
                                  ),
                                ],
                              ),
                            ) ??
                            false; // Par défaut, ne rien supprimer

                        if (shouldDelete) {
                          await _deleteHistory(); // Supprimer l'historique
                          // Afficher une notification
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Historique supprimé avec succès !"),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              // Affichage de l'historique
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  // Écoute des données de la collection "match_history" dans Firestore
                  stream: FirebaseFirestore.instance
                      .collection('match_history') // Nom de la collection
                      .orderBy('matches_played', descending: true) // Trier par matchs joués
                      .snapshots(),
                  builder: (context, snapshot) {
                    // Affichage d'un indicateur de chargement pendant la récupération des données
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    // Si aucune donnée n'est trouvée ou si la collection est vide
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No matches played yet!', // Message lorsque l'historique est vide
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      );
                    }

                    // Récupération des données des joueurs
                    final players = snapshot.data!.docs;

                    // Liste affichant chaque joueur et son nombre de matchs
                    return ListView.builder(
                      padding: const EdgeInsets.all(12.0),
                      itemCount: players.length,
                      itemBuilder: (context, index) {
                        final player = players[index]; // Document Firestore
                        final data = player.data() as Map<String, dynamic>; // Données du joueur

                        // Affichage d'une carte pour chaque joueur
                        return Card(
                          elevation: 5, // Élévation pour un effet visuel
                          margin: const EdgeInsets.symmetric(vertical: 8), // Espacement
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12), // Bordures arrondies
                          ),
                          color: Colors.white, // Couleur de fond de la carte
                          child: ListTile(
                            leading: const Icon(
                              Icons.sports_esports, // Icône pour représenter un joueur
                              color: Colors.blueAccent,
                            ),
                            // Nom du joueur
                            title: Text(
                              data['name'] ?? 'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            // Nombre de matchs joués
                            subtitle: Text(
                              'Matches Played: ${data['matches_played'] ?? 0}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            trailing: const Icon(
                              Icons.emoji_events, // Icône de trophée
                              color: Colors.orangeAccent,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
