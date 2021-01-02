import 'package:flutter/material.dart';

import 'package:memoree_client/app/pages/login.dart';
import 'package:memoree_client/app/services/firebase_auth.dart';

class AccountInfo extends StatefulWidget {
  @override
  _AccountInfoState createState() => _AccountInfoState();
}

class _AccountInfoState extends State<AccountInfo> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseAuthService().currentUser(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(child: CircularProgressIndicator()), 
            ); 
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 35,
                      child: ClipOval(
                        child: Image.network(snapshot.data.photoUrl, fit: BoxFit.cover)
                      ),
                    ),
                    SizedBox(height: 20,),
                    Text(snapshot.data.displayName, textScaleFactor: 1.25),
                    Text(snapshot.data.email, style: TextStyle(color: Colors.black54,)),
                    SizedBox(height: 20,),
                    Divider(thickness: 1,),
                    SizedBox(height: 15,),
                    OutlineButton(
                      // padding: const EdgeInsets.only(top: 20.0),
                      splashColor: Colors.grey,
                      onPressed: () async {
                        await FirebaseAuthService().signOut();
                        Navigator.of(context).pop();
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) {
                            return LoginPage();
                          }));
                      },
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                      highlightElevation: 0,
                      borderSide: BorderSide(color: Colors.grey),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text("Sign out", textScaleFactor: 1.1,)
                      ),
                    ),
                  ],
              ),
            );
            break;
        }
        return Center();
      }
    );
  }
}