import 'package:flutter/material.dart';
import 'package:personal_prod/pages/home_page.dart';

class Login extends StatelessWidget {
  const Login({super.key});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Good to see you sir!", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 24),),
            ElevatedButton(onPressed: () {
Navigator.push(context, MaterialPageRoute(builder: (ctx) => HomePage()));

            }, child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Sign in with google"),
                Icon(Icons.sports_soccer)
              ],
            )),
          ],
        ),
      ),
    );
  }
}
