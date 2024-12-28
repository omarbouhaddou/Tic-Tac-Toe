import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'winner_screen.dart';
import 'history_screen.dart';
import 'dart:math';
import 'dart:async';

class TicTacToe extends StatefulWidget {
  const TicTacToe({Key? key}) : super(key: key);

  @override
  _TicTacToeState createState() => _TicTacToeState();
}

class _TicTacToeState extends State<TicTacToe> {
  // Représentation de la grille de jeu sous forme de tableau
  List<String> board = List.filled(9, ''); // 9 cases initialisées comme vides
  String currentPlayer = 'X'; // Joueur en cours (X ou O)
  String playerXName = 'Player X'; // Nom du joueur X
  String playerOName = 'Player O'; // Nom du joueur O
  bool gameOver = false; // Indique si la partie est terminée
  bool isPlayingWithRobot = false; // Mode de jeu : contre robot ou contre joueur
  Timer? timer; // Chronomètre pour limiter le temps d'un tour
  int timeLeft = 30; // Temps restant pour le joueur actuel en secondes

  @override
  void initState() {
    super.initState();
    // Affiche le choix du mode de jeu au démarrage de la partie
    WidgetsBinding.instance.addPostFrameCallback((_) => _chooseModeDialog());
  }

  // Affiche une boîte de dialogue pour choisir le mode de jeu
  void _chooseModeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Empêche la fermeture sans choisir une option
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose Mode'),
          content: const Text('Do you want to play with a robot or another player?'),
          actions: [
            // Mode joueur contre joueur
            TextButton(
              onPressed: () {
                setState(() => isPlayingWithRobot = false);
                Navigator.pop(context); // Fermer la boîte de dialogue
                _showPlayerNameDialog(); // Demander les noms des joueurs
              },
              child: const Text('Player vs Player'),
            ),
            // Mode joueur contre robot
            TextButton(
              onPressed: () {
                setState(() => isPlayingWithRobot = true);
                Navigator.pop(context); // Fermer la boîte de dialogue
                _showPlayerNameDialog(); // Demander le nom du joueur
              },
              child: const Text('Player vs Robot'),
            ),
          ],
        );
      },
    );
  }

  // Affiche une boîte de dialogue pour entrer les noms des joueurs
  void _showPlayerNameDialog() {
    TextEditingController playerXController = TextEditingController();
    TextEditingController playerOController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, // Empêche la fermeture sans entrer de noms
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Player Names'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: playerXController,
                decoration: const InputDecoration(labelText: 'Player X'),
              ),
              // Ne demander que pour le joueur O si le mode n'est pas contre le robot
              if (!isPlayingWithRobot)
                TextField(
                  controller: playerOController,
                  decoration: const InputDecoration(labelText: 'Player O'),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  // Enregistrer les noms des joueurs
                  playerXName = playerXController.text.isEmpty ? 'Player X' : playerXController.text;
                  playerOName = isPlayingWithRobot
                      ? 'Robot'
                      : (playerOController.text.isEmpty ? 'Player O' : playerOController.text);
                });
                Navigator.pop(context); // Fermer la boîte de dialogue
                _startTimer(); // Lancer le chronomètre pour le premier joueur
              },
              child: const Text('Start Game'),
            ),
          ],
        );
      },
    );
  }

  // Lancer un chronomètre pour le joueur en cours
  void _startTimer() {
    timer?.cancel();
    setState(() => timeLeft = 30); // Réinitialiser le chronomètre à 30 secondes
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        timeLeft--;
        if (timeLeft == 0) _handleTimeout(); // Gérer le dépassement de temps
      });
    });
  }

  // Changer de joueur en cas de dépassement de temps
  void _handleTimeout() {
    if (!gameOver) {
      setState(() {
        currentPlayer = currentPlayer == 'X' ? 'O' : 'X'; // Alterner le joueur
        if (isPlayingWithRobot && currentPlayer == 'O') _robotMove(); // Le robot joue automatiquement
        _startTimer(); // Redémarrer le chronomètre
      });
    }
  }

  // Gérer le clic sur une case de la grille
  void _handleTap(int index) {
    if (board[index] == '' && !gameOver) { // Vérifier si la case est vide et si le jeu n'est pas terminé
      setState(() {
        board[index] = currentPlayer; // Marquer la case avec le symbole du joueur
        if (_checkWinner()) { // Vérifier si le joueur a gagné
          gameOver = true;
          String winner = currentPlayer == 'X' ? playerXName : playerOName;
          _saveMatchResult(winner); // Enregistrer le résultat dans Firestore
          _showWinnerScreen(winner); // Afficher l'écran de victoire
          timer?.cancel(); // Arrêter le chronomètre
        } else if (!board.contains('')) { // Vérifier s'il y a une égalité
          gameOver = true;
          _showDrawScreen(); // Afficher un message d'égalité
          timer?.cancel();
        } else {
          currentPlayer = currentPlayer == 'X' ? 'O' : 'X'; // Changer de joueur
          if (isPlayingWithRobot && currentPlayer == 'O') _robotMove(); // Le robot joue automatiquement
          _startTimer(); // Redémarrer le chronomètre
        }
      });
    }
  }

  // Logique pour le robot : jouer un coup aléatoire
  void _robotMove() {
    Future.delayed(const Duration(milliseconds: 500), () {
      List<int> emptyCells = []; // Trouver les cases vides
      for (int i = 0; i < board.length; i++) {
        if (board[i] == '') emptyCells.add(i);
      }
      if (emptyCells.isNotEmpty) {
        int randomIndex = emptyCells[Random().nextInt(emptyCells.length)]; // Sélection aléatoire
        _handleTap(randomIndex); // Marquer la case choisie
      }
    });
  }

  // Vérifier si un joueur a gagné
  bool _checkWinner() {
    List<List<int>> winningCombinations = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Lignes
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Colonnes
      [0, 4, 8], [2, 4, 6],            // Diagonales
    ];
    for (var combo in winningCombinations) {
      if (board[combo[0]] == currentPlayer &&
          board[combo[1]] == currentPlayer &&
          board[combo[2]] == currentPlayer) {
        return true; // Une combinaison gagnante est trouvée
      }
    }
    return false; // Aucun gagnant trouvé
  }

  // Enregistrer le résultat du match dans Firestore
  Future<void> _saveMatchResult(String winner) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final playerDoc = firestore.collection('match_history').doc(winner);

      await playerDoc.set({
        'name': winner,
        'matches_played': FieldValue.increment(1), // Incrémenter le nombre de matchs
      }, SetOptions(merge: true)); // Met à jour ou crée un nouveau document
    } catch (e) {
      print('Erreur lors de l\'enregistrement du match : $e');
    }
  }

  // Afficher l'écran de victoire
  void _showWinnerScreen(String winner) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WinnerScreen(winnerName: winner)),
    ).then((_) => _resetGame());
  }

  // Afficher un message d'égalité
  void _showDrawScreen() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Draw!'),
          content: const Text('It\'s a tie!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetGame();
              },
              child: const Text('Replay'),
            ),
          ],
        );
      },
    );
  }

  // Réinitialiser le jeu
  void _resetGame() {
    setState(() {
      board = List.filled(9, ''); // Réinitialiser la grille
      currentPlayer = 'X'; // Revenir au joueur X
      gameOver = false; // Réinitialiser l'état du jeu
    });
    _startTimer(); // Redémarrer le chronomètre
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Current Player: ${currentPlayer == 'X' ? playerXName : playerOName}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                'Time Left: $timeLeft seconds',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 20),
              AspectRatio(
                aspectRatio: 1,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                  itemCount: 9,
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () => _handleTap(index),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: board[index] == ''
                            ? Colors.white
                            : (board[index] == 'X' ? Colors.blue : Colors.red),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          board[index],
                          style: const TextStyle(fontSize: 50, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _resetGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: const Text(
                  'Reset Game',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
