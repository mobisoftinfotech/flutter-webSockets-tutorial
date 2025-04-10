import 'package:socket_setup/chat_screen.dart';
import 'package:socket_setup/socket_manager/socket_helper.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketManager {
  static final SocketManager _shared = SocketManager._();

  //Singleton accessor;
  static SocketManager get shared => _shared;

  SocketManager._();

  WebSocketChannel? webSocketChannel;

  //TODO: Connect to a server
  Future<void> connect() async {
    final wsUrl = Uri.parse('wss://echo.websocket.org');
    try {
      if (webSocketChannel != null) {
        webSocketChannel?.sink.close();
      }
      webSocketChannel = WebSocketChannel.connect(wsUrl);
      _listenToWebSocket();
      _listenToWebSocketClosure();
    } catch (exception) {
      print(exception);
    }
  }

  //TODO: Send messages to the server
  void sendMessage(String message) async {
    webSocketChannel?.sink.add(message);
  }

  //TODO: Receive messages from the server
  void _listenToWebSocket() {
    webSocketChannel?.stream.listen((message) {
      SocketHelper.handleSocketResponse(message);
      print(message);
    });
  }

  //TODO: Perform actions when the WebSocket is closed.
  void _listenToWebSocketClosure() {
    webSocketChannel?.sink.done.then((value) {
      //You receives callback here after connection closed.
      SocketHelper.handleSocketResponse('');
      print('closed');
    }).catchError((error) {
      print(error);
    });
  }

  //TODO: Close connection with the server.
  void disconnect() {
    webSocketChannel?.sink.close();
  }
}
