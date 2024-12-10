import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(PokemonApp());
}

class PokemonApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokémon TCG HP Battle',
      theme: ThemeData(primarySwatch: Colors.green),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool showPlayNowButton = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        showPlayNowButton = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[700],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.jpg', height: 450),
            SizedBox(height: 20),
            Text(
              'Pokémon TCG HP Battle',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 20),
            if (showPlayNowButton)
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => GameOptionScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow, foregroundColor: Colors.black, padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
                child: Text('Play Now', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              )
            else
              CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
          ],
        ),
      ),
    );
  }
}

class GameOptionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Game Mode'),
        backgroundColor: Colors.green[700],
      ),
       body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),



      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
                  
            Text(
              'Choose Best of',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[800]),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => CardBattleScreen(bestOfRounds: 3)),
                );
              },
              style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.green[600], padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
              child: Text('Best of 3', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => CardBattleScreen(bestOfRounds: 5)),
                );
              },
              style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.green[600], padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
              child: Text('Best of 5', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => CardBattleScreen(bestOfRounds: 10)),
                );
              },
              style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.green[600], padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
              child: Text('Best of 10', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
       ),
    );
    
  }
}

class CardBattleScreen extends StatefulWidget {
  final int bestOfRounds;
  CardBattleScreen({required this.bestOfRounds});

  @override
  _CardBattleScreenState createState() => _CardBattleScreenState();
}

class _CardBattleScreenState extends State<CardBattleScreen> {
  Map<String, dynamic>? card1;
  Map<String, dynamic>? card2;
  int player1HP = 0;
  int player2HP = 0;
  int roundsPlayed = 0;
  int totalRounds = 0;
  bool player1HasThrown = false;
  bool player2HasThrown = false;

  @override
  void initState() {
    super.initState();
    totalRounds = widget.bestOfRounds;
  }

  





  Future<void> loadRandomCardForUser(int user) async {
    try {
      final response = await http.get(Uri.parse('https://api.pokemontcg.io/v2/cards'));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<Map<String, dynamic>> allCards = List<Map<String, dynamic>>.from(jsonData['data']);

        if (allCards.isNotEmpty) {
          Random random = Random();
          int index = random.nextInt(allCards.length);

          setState(() {
            if (user == 1) {
              card1 = allCards[index];
              player1HP += int.tryParse(card1?['hp'] ?? '0') ?? 0;
              player1HasThrown = true;
            } else {
              card2 = allCards[index];
              player2HP += int.tryParse(card2?['hp'] ?? '0') ?? 0;
              player2HasThrown = true;
            }

            if (player1HasThrown && player2HasThrown) {
              roundsPlayed++;
              player1HasThrown = false;
              player2HasThrown = false;

              if (roundsPlayed == totalRounds) {
                declareWinner();
              }
            }
          });
        }
      } else {
        throw Exception('Failed to load cards');
      }
    } catch (error) {
      print('Error fetching cards: $error');
    }
  }

  void declareWinner() {
    String message;
    if (player1HP > player2HP) {
      message = "Winner: Player 1 with HP: $player1HP!";
    } else if (player2HP > player1HP) {
      message = "Winner: Player 2 with HP: $player2HP!";
    } else {
      message = "It's a tie! Both have HP: $player1HP!";
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Center(
            child: Text(
              'Game Over',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[700]),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'Congratulations!',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.green[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                resetGame();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
              ),
              child: Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  void resetGame() {
    setState(() {
      card1 = null;
      card2 = null;
      player1HP = 0;
      player2HP = 0;
      roundsPlayed = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokémon TCG HP Battle'),
        backgroundColor: Colors.green[700],
      ),
       body: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
           image: AssetImage('assets/background.jpg'), // Replace with your image URL
          fit: BoxFit.cover, // Makes sure the image covers the entire screen
        ),

      ),


      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (roundsPlayed < totalRounds)
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildCardWidget(card1, "Player 1", player1HP),
                      buildCardWidget(card2, "Player 2", player2HP),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text('Rounds Played: $roundsPlayed / $totalRounds', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => loadRandomCardForUser(1),
                        child: Text('Throw Player 1'),
                      ),
                      ElevatedButton(
                        onPressed: () => loadRandomCardForUser(2),
                        child: Text('Throw Player 2'),
                      ),
                    ],
                  ),
                ],
              )
            else
              Text('Game Over', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red)),
          ],
        ),
      ),
      ),
    );
  }

  Widget buildCardWidget(Map<String, dynamic>? card, String playerName, int totalHP) {
    if (card != null) {
      return Column(
        children: [
          Text(playerName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Image.network(card['images']['small'], height: 250),
          Text('HP: ${card['hp']}', style: TextStyle(fontSize: 18)),
        ],
      );
    } else {
      return Column(
        children: [
          Text(playerName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Container(
            height: 150,
            width: 100,
            color: Colors.grey[300],
            child: Center(child: Text('No Card')),
          ),
        ],
      );
    }
  }
}