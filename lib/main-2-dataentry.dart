import 'package:flutter/material.dart';

void main() {
  runApp(new FriendlychatApp());
}

class FriendlychatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Friendlychat",
      home: new ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  State createState() => new ChatScreenState();
}


class ChatScreenState extends State<ChatScreen> {

  final TextEditingController _textController = new TextEditingController();

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
                      decoration: new InputDecoration.collapsed(hintText: "Send a message"),
                    )
                ),
                new Container(
                  margin: new EdgeInsets.all(8.0),
                  child: new IconButton(
                      icon: new Icon(Icons.send),
                      onPressed: () => _handleSubmitted(_textController.text)),
                )
              ]
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Text("Friendlychat")
      ),
      body: _buildTextComposer(),
    );
  }

  void _handleSubmitted(String value) {
    _textController.clear();
  }
}
