import 'package:appbase/support/constants.dart';
import 'package:logger/logger.dart';
import 'dart:io';
import 'dart:convert';

class ClientTCP {
  static const HOST = '192.168.1.111';
  static const PORT = 9090;
  static Logger _log = Logger();
  static late Socket _socket;
  static late Function _callback;
  static late int lastTimeStamp;

  static void setCallback(Function callback) {
    _callback = callback;
  }

  static void open(callback) async {
    print('Trying to connect');
    setCallback(callback);
    Socket.connect(HOST, PORT, timeout: Duration(seconds: 10)).then((Socket socket) {
      _socket = socket;
      _socket.listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: true
      );
      onConnection();
    }).catchError((Object  e) {
      print("Unable to connect: $e");
      open(_callback);
    });
  }

  static void sendData(Object data, int code) {
    lastTimeStamp = new DateTime.now().millisecondsSinceEpoch;
    _socket.write(jsonEncode({
      "DATA": jsonEncode(data),
      "CODE": code,
      "TIME": lastTimeStamp
    }));
  }

  static void onConnection() {
    _log.v('Connected');
    _callback(NetProtocol.INIT);
  }

  static void onData(data) {
    try {
      Map<String, dynamic> response = jsonDecode(new String.fromCharCodes(data).trim());
      _callback(response);
    } catch (e) {
      _log.e(e);
    }
  }

  static void onError(error) {
    print('Error');
    _callback(NetProtocol.CONNECTION_ERROR);
  }

  static void onDone() {
    print('Destroy socket');
    _socket.destroy();
  }
}