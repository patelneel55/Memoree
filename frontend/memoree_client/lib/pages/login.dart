import 'package:flutter/material.dart';
import 'package:memoree_client/app/services/firebase_auth.dart';
import 'package:memoree_client/app_scaffold.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FlutterLogo(size: 150),
                SizedBox(height: 50,),
                OutlineButton(
                  splashColor: Colors.grey,
                  onPressed: () {
                    FirebaseAuthService().signInWithGoogle().then((user) {
                      if (user != null) {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) {
                            return AppScaffold(page: 'videos');
                          },
                        ),);
                      }
                    });
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                  highlightElevation: 0,
                  borderSide: BorderSide(color: Colors.grey),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image(image: AssetImage("logos/google_logo.png"), height: 30.0),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text("Sign in with Google")
                        ),
                      ],
                    ),
                  ),
                ),
              ]
            ),
          ),
        ),
      ),
    );
  }
}
