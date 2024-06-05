import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mashalla.ai',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mashalla.ai',
          style: TextStyle(
            color: Colors.white, // Text color
            fontSize: 35, // Text size
            fontWeight: FontWeight.bold, // Bold text
            fontStyle: FontStyle.italic, // Italic text
            fontFamily: 'ArabicCursive', // Optional: Choose a font that supports Arabic
          ),
        ),
        backgroundColor: Color(0xFF56596C), // Darker shade of purple
        centerTitle: true,
      ),
      body: Container(
        color: Color.fromARGB(255, 76, 10, 119), // Body background color to purple
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 800),
                  padding: EdgeInsets.all(16.0),
                  child: ChatScreen(),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              color: Color(0xFF56596C),
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Owned by Mennan Yelkenci (CEO of booked.ai)',
                style: TextStyle(
                  color: Colors.white, // Text color
                  fontSize: 16, // Font size
                  fontStyle: FontStyle.italic, // Italic text
                ),
                textAlign: TextAlign.center,
              ),
              
            ),
          ],
        ),
      ),
    );
  }
}

