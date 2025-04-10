import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:socket_setup/socket_manager/socket_manager.dart';

import 'chat_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isConnected = false;

  void handleLocalBroadcast(String message) {
    if (message == 'connected') {
      setState(() {
        _isConnected = true;
      });
    } else if (message == 'disconnected') {
      setState(() {
        _isConnected = false;
      });
    }
  }

  void _addBroadcastObservers() {
    FBroadcast.instance().register(
      "message_received",
      context: this,
      (value, callback) {
        handleLocalBroadcast(value as String);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _addBroadcastObservers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            OutlinedButton(
              onPressed: () {
                SocketManager.shared.connect();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Connect'),
            ),
            Visibility(
              visible: _isConnected,
              child: Column(
                children: [
                  SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ChatScreen()));
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Lets Chat'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                SocketManager.shared.disconnect();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Disconnect'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    FBroadcast.instance().unregister(this);
  }
}
