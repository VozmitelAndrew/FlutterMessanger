import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import '../patternTemplates/ViewerPattern.dart';

enum WSConnectionState { disconnected, connecting, connected, error }

abstract class WebsocketService {
  Future<void> connect();
  Future<void> disconnect();
  bool send(String? msg);
  void listen();
  void translateData(String? message);
  void dispose();
  WSConnectionState get connectionState;
  Stream<String?> get messages;
}

class WebSocketServiceImpl extends Teller implements WebsocketService {
  static final WebSocketServiceImpl _instance = WebSocketServiceImpl._internal();
  factory WebSocketServiceImpl() => _instance;
  WebSocketServiceImpl._internal();

  late final String _url =  'ws://localhost:8080/ws';
  IOWebSocketChannel? _channel;
  final StreamController<String?> _messageController = StreamController.broadcast();
  WSConnectionState _state = WSConnectionState.disconnected;

  @override
  WSConnectionState get connectionState => _state;

  @override
  Stream<String?> get messages => _messageController.stream;

  Future<void> init() async {
    await connect();
  }

  @override
  Future<void> connect() async {
    _state = WSConnectionState.connecting;
    try {
      _channel = IOWebSocketChannel.connect(_url);
      _state = WSConnectionState.connected;
      listen();
    } catch (e) {
      _state = WSConnectionState.error;
      _scheduleReconnect();
    }
  }

  @override
  Future<void> disconnect() async {
    _state = WSConnectionState.disconnected;
    _channel?.sink.close();
    _reconnectTimer?.cancel();
  }

  @override
  bool send(String? msg) {
    if (msg != null && _state == WSConnectionState.connected) {
      _channel?.sink.add(msg);
      return true;
    }
    return false;
  }

  @override
  void listen() {
    _channel?.stream.listen(
          (message) {
        _messageController.add(message);
        //translateData(message);
        _handleEvent(message!);
      },
      onDone: () {
        _state = WSConnectionState.disconnected;
        _scheduleReconnect();
      },
      onError: (error) {
        _state = WSConnectionState.error;
        _scheduleReconnect();
      },
    );
  }

  @override
  void translateData(String? message) {
    for (final viewer in subscribersList) {
      viewer.notice(message);
    }
  }

  void _handleEvent(String message) {
    final data = jsonDecode(message) as Map<String, dynamic>;
    final eventType = data['eventType'];
    final payload = data['payload'];
    print('EventType: $eventType');
    print('Payload: $payload');
  }

  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;

  void _scheduleReconnect() {
    _reconnectAttempts++;
    final delay = Duration(seconds: 1 << (_reconnectAttempts.clamp(0, 5)));
    _reconnectTimer = Timer(delay, () => connect());
  }

  @override
  void dispose() {
    _messageController.close();
    disconnect();
  }
}
