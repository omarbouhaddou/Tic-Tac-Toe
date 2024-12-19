import 'package:flutter/material.dart';
import 'winner_screen.dart';
import 'history_screen.dart';
import 'dart:math';
import 'dart:async';

class TicTacToe extends StatefulWidget {
  final List<String> matchHistory;

  const TicTacToe({Key? key, required this.matchHistory}) : super(key: key);

  @override
  _TicTacToeState createState() => _TicTacToeState();
}

class _TicTacToeState extends State<TicTacToe> {
  List<String> board = List.filled(9, '');
  String currentPlayer = 'X';
  String playerXName = 'Player X';
  String playerOName = 'Player O';
  bool gameOver = false;
  bool isPlayingWithRobot = false;
  Timer? timer; 
  int timeLeft = 30; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _chooseModeDialog());
  }

  void _chooseModeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose Mode'),
          content: const Text('Do you want to play with a robot or another player?'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => isPlayingWithRobot = false);
                Navigator.pop(context);
                _showPlayerNameDialog();
              },
              child: const Text('Player vs Player'),
            ),
            TextButton(
              onPressed: () {
                setState(() => isPlayingWithRobot = true);
                Navigator.pop(context);
                _showPlayerNameDialog();
              },
              child: const Text('Player vs Robot'),
            ),
          ],
        );
      },
    );
  }

  void _showPlayerNameDialog() {
    TextEditingController playerXController = TextEditingController();
    TextEditingController playerOController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
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
                  playerXName = playerXController.text.isEmpty ? 'Player X' : playerXController.text;
                  playerOName = isPlayingWithRobot
                      ? 'Robot'
                      : (playerOController.text.isEmpty ? 'Player O' : playerOController.text);
                });
                Navigator.pop(context);
                _startTimer();
              },
              child: const Text('Start Game'),
            ),
          ],
        );
      },
    );
  }

  void _startTimer() {
    timer?.cancel();
    setState(() => timeLeft = 30);
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        timeLeft--;
        if (timeLeft == 0) _handleTimeout();
      });
    });
  }

  void _handleTimeout() {
    if (!gameOver) {
      setState(() {
        currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
        if (isPlayingWithRobot && currentPlayer == 'O') _robotMove();
        _startTimer();
      });
    }
  }

  void _handleTap(int index) {
    if (board[index] == '' && !gameOver) {
      setState(() {
        board[index] = currentPlayer;
        if (_checkWinner()) {
          gameOver = true;
          String winner = currentPlayer == 'X' ? playerXName : playerOName;
          widget.matchHistory.add('$winner won!');
          _showWinnerScreen(winner);
          timer?.cancel();
        } else if (!board.contains('')) {
          gameOver = true;
          widget.matchHistory.add('It\'s a draw!');
          _showDrawScreen();
          timer?.cancel();
        } else {
          currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
          if (isPlayingWithRobot && currentPlayer == 'O') _robotMove();
          _startTimer();
        }
      });
    }
  }

  void _robotMove() {
    Future.delayed(const Duration(milliseconds: 500), () {
      List<int> emptyCells = [];
      for (int i = 0; i < board.length; i++) {
        if (board[i] == '') emptyCells.add(i);
      }
      if (emptyCells.isNotEmpty) {
        int randomIndex = emptyCells[Random().nextInt(emptyCells.length)];
        _handleTap(randomIndex);
      }
    });
  }

  bool _checkWinner() {
    List<List<int>> winningCombinations = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6],
    ];
    for (var combo in winningCombinations) {
      if (board[combo[0]] == currentPlayer &&
          board[combo[1]] == currentPlayer &&
          board[combo[2]] == currentPlayer) {
        return true;
      }
    }
    return false;
  }

  void _showWinnerScreen(String winner) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => WinnerScreen(winnerName: winner)))
        .then((_) => _resetGame());
  }

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

  void _resetGame() {
    setState(() {
      board = List.filled(9, '');
      currentPlayer = 'X';
      gameOver = false;
    });
    _startTimer();
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
              MaterialPageRoute(builder: (context) => HistoryScreen(history: widget.matchHistory)),
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

            // Grille de jeu
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
