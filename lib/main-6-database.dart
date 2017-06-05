import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'dart:async';

const String _name = "Mike Traverso";

final googleSignIn = new GoogleSignIn();

// Keep track of FirebaseAuth instance globally
final auth = FirebaseAuth.instance;

final ThemeData kIOSTheme = new ThemeData(
  primarySwatch: Colors.orange,
  primaryColor: Colors.blue[500],
  primaryColorBrightness: Brightness.light,
);

final ThemeData kDefaultTheme = new ThemeData(
  primarySwatch: Colors.purple,
  accentColor: Colors.orangeAccent[400],
);

void main() {
  runApp(new FriendlychatApp());
}

class FriendlychatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Friendlychat",
      theme: defaultTargetPlatform == TargetPlatform.iOS
          ? kIOSTheme
          : kDefaultTheme,
      home: new ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  State createState() => new ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
//  final List<ChatMessage> _messages = <ChatMessage>[];
  final TextEditingController _textController = new TextEditingController();
  final reference = FirebaseDatabase.instance.reference().child('messages');

  Future<Null> _ensureLoggedIn() async {
    GoogleSignInAccount user = googleSignIn.currentUser;
    if (user == null)
      user = await googleSignIn.signInSilently();
    if (user == null) {
      await googleSignIn.signIn();
    }

    // Check the current user. Sign in if null
    if (auth.currentUser == null) {
      GoogleSignInAuthentication credentials = await googleSignIn.currentUser.authentication;
      await auth.signInWithGoogle(
        idToken: credentials.idToken,
        accessToken: credentials.accessToken,
      );
    }
  }

  Future<Null> _handleSubmitted(String text) async {
    _textController.clear();
    await _ensureLoggedIn();
    _sendMessage(text: text);
  }


  void _sendMessage({ String text }) {

    reference.push().set({
      'text': text,
      'senderName': googleSignIn.currentUser.displayName,
      'senderPhotoUrl': googleSignIn.currentUser.photoUrl,
    });

//    ChatMessage message = new ChatMessage(
//      snapshot: ,
//      animationController: new AnimationController(
//        duration: new Duration(milliseconds: 700),
//      ),
//    );
//    setState(() {
//      _messages.insert(0, message);
//    });
//    message.animationController.forward();
  }

//  @override dispose() {
//    for (ChatMessage message in _messages) {
//      message.animationController.dispose();
//    }
//    super.dispose();
//  }

  Widget _buildTextComposer() {
    return new IconTheme(
        data: new IconThemeData(color: Theme.of(context).accentColor),
        child: new Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: new Row(
              children: <Widget>[
                new Flexible(
                  child: new TextField(
                    controller: _textController,
                    onSubmitted: _handleSubmitted,
                    decoration: new InputDecoration.collapsed(
                        hintText: "Send a message"),
                  ),
                ),
                new Container(
                  margin: new EdgeInsets.symmetric(horizontal: 4.0),
                  child: new IconButton(
                      icon: new Icon(Icons.send),
                      onPressed: () => _handleSubmitted(_textController.text)),
                ),
              ]
          ),
        )
    );
  }

  @override Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text("Friendlychat",
        style: new TextStyle(
            color: new Color(0xFFFFFFFF),
            fontSize: 24.0),
        )
      ),
      body: new Column(children: <Widget>[
        new Flexible(
        child: new FirebaseAnimatedList(
          query: reference,
          sort: (a, b) => b.key.compareTo(a.key),
          padding: new EdgeInsets.all(8.0),
          reverse: true,
          itemBuilder: (_, DataSnapshot snapshot, Animation<double> animation) {
            return new ChatMessage(
                snapshot: snapshot,
                animation: animation
            );
          },
        ),
      ),


//    body: new Column(
//          children: <Widget>[
//            new Flexible(
//                child: new ListView.builder(
//                  padding: new EdgeInsets.all(8.0),
//                  reverse: true,
//                  itemBuilder: (_, int index) => _messages[index],
//                  itemCount: _messages.length,
//                )
//            ),
            new Divider(height: 1.0),
            new Container(
              decoration: new BoxDecoration(color: Theme.of(context).cardColor),
              child: _buildTextComposer(),
            ),
          ]
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
//  final String text;
  final Animation animation;
  final DataSnapshot snapshot;

  ChatMessage({this.snapshot, this.animation});
//  ChatMessage({this.text, this.animationController});

//  String _getInitials() {
//    if (_name.indexOf(" ") > 0) {
//      return _name[0] + _name[_name.indexOf(" ") + 1];
//    } else {
//      return _name[0];
//    }
//  }

  @override
  Widget build(BuildContext context) {
    return new SizeTransition(
      sizeFactor: new CurvedAnimation(parent: animation, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: new Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
              margin: const EdgeInsets.only(right: 16.0),
//            child: new GoogleUserCircleAvatar(googleSignIn.currentUser.photoUrl),
              child: new GoogleUserCircleAvatar(snapshot.value['senderPhotoUrl']),
            ),
            new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
//              new Text(googleSignIn.currentUser.displayName,
                new Text(snapshot.value['senderName'],
                    style: Theme.of(context).textTheme.subhead),
                new Container(
                  margin: const EdgeInsets.only(top: 5.0),
//                child: new Text(text),
                  child: new Text(snapshot.value['text']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}