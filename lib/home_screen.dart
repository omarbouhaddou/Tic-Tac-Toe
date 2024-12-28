import 'package:flutter/material.dart';
import 'tic_tac_toe.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  // AnimationController pour gérer l'animation du titre
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Configuration de l'animation : durée de 2 secondes avec répétition
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true); // Reverser l'animation pour un effet d'aller-retour
  }

  @override
  void dispose() {
    // Libérer les ressources lorsque le widget est détruit
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Corps principal de la page
      body: Stack(
        children: [
          // Dégradé d'arrière-plan pour un design attrayant
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.blue], // Couleurs du dégradé
                begin: Alignment.topLeft, // Début du dégradé
                end: Alignment.bottomRight, // Fin du dégradé
              ),
            ),
          ),
          // Organisation verticale des éléments (message de bienvenue, animation, boutons, pied de page)
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Espacement égal entre les sections
            children: [
              // Section 1 : Message de bienvenue
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Column(
                  children: const [
                    // Titre principal
                    Text(
                      'Welcome to Tic Tac Toe!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10), // Espacement
                    // Sous-titre
                    Text(
                      'Enjoy the classic game with a modern twist.',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              // Section 2 : Animation du titre (X O, O X)
              ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1.1).animate(CurvedAnimation(
                  parent: _controller,
                  curve: Curves.easeInOut, // Effet de transition fluide
                )),
                child: Column(
                  children: const [
                    Text(
                      'X O', // Texte animé
                      style: TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'O X', // Texte animé
                      style: TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
              // Section 3 : Boutons de navigation
              Column(
                children: [
                  // Bouton "Play Game" pour commencer une partie
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, // Couleur de fond du bouton
                      foregroundColor: Colors.white, // Couleur du texte
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // Bordures arrondies
                      ),
                    ),
                    onPressed: () {
                      // Navigation vers la page TicTacToe
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TicTacToe(),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // Taille minimale pour s'ajuster au contenu
                      children: const [
                        Icon(Icons.play_arrow, color: Colors.white), // Icône de jeu
                        SizedBox(width: 10), // Espacement
                        Text('Play Game', style: TextStyle(fontSize: 20)), // Texte du bouton
                      ],
                    ),
                  ),
                  const SizedBox(height: 20), // Espacement entre les boutons
                  // Bouton "Match History" pour afficher l'historique
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent, // Couleur de fond
                      foregroundColor: Colors.white, // Couleur du texte
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // Bordures arrondies
                      ),
                    ),
                    onPressed: () {
                      // Navigation vers la page HistoryScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HistoryScreen(),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.history, color: Colors.white), // Icône d'historique
                        SizedBox(width: 10),
                        Text('Match History', style: TextStyle(fontSize: 20)), // Texte du bouton
                      ],
                    ),
                  ),
                ],
              ),
              // Section 4 : Pied de page
              Column(
                children: const [
                  Divider(color: Colors.white54), // Ligne de séparation
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      '© 2024 Tic Tac Toe App. All Rights Reserved.', // Texte du pied de page
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
