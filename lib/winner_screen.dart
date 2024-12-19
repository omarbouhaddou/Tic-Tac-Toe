import 'package:flutter/material.dart';

class WinnerScreen extends StatelessWidget {
  final String winnerName;

  const WinnerScreen({Key? key, required this.winnerName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Winner!')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$winnerName Wins!',
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back to Game'),
            ),
          ],
        ),
      ),
    );
  }
}
