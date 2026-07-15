import 'package:flutter/material.dart';
import 'package:personal_prod/pages/credentials/login.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 5),
            Column(
              children: [
                Icon(Icons.book, size: 64, color: Colors.green),
                Text(
                  "Finch",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
                Text(
                  "Your AI personal assistant",
                  style: TextStyle(color: Colors.grey, fontSize: 24),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20),

              child: Column(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      boxShadow: [
                        // BoxShadow(
                        //   color: Colors.green.shade800,
                        //   spreadRadius: 1,
                        //   blurRadius: 2,
                        //   offset: const Offset(0, 2),
                        // ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (ctx) => Login()),
                        );
                        // Add your action here
                      },
                      style: ElevatedButton.styleFrom(
                        // side: BorderSide(
                        //   color: Colors.green.shade700,
                        //   width: 2,
                        // ),
                        minimumSize: Size(300, 30),
                        backgroundColor: Color(0xFF57b553),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 32.0,
                        ),

                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          // Smooth, fully rounded corners
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        'Add widget',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600, // Semi-bold font weight
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
