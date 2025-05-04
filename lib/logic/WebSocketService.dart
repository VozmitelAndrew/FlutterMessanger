import 'dart:async';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:p3/logic/AuthenticationService.dart';
import '../patternTemplates/ViewerPattern.dart';
// import 'chat_message.dart';

enum WSConnectionState { disconnected, connecting, connected, error }

abstract class MessengerConnectionProvider {}

class WebSocketService extends Teller implements MessengerConnectionProvider {
  // 1) Singleton
  static final WebSocketService _instance = WebSocketService._internal();

  factory WebSocketService() => _instance;

  WebSocketService._internal();

  // 2) Внешние зависимости
  //late final AuthenticationService _authService;
  late final String _url;

  // 3) Внутренние поля
  //канал вэбсокета - главная артерия
  IOWebSocketChannel? _channel;

  void init({required String url}) {
    //_authService = authService;
    _url = 'http://localhost:8080';
    //Стоит ли пытаться делать коннект при создании?
    connect();
  }

  /// Устанавливает соединение
  Future<void> connect() async {
    _channel = IOWebSocketChannel.connect(_url);
  }

  /// Отключает соединение и запрещает авто-переподключение
  Future<void> disconnect() async {
    _channel?.sink.close();
  }

  /// Отправляет сообщение, возможно стоит давать ResponceMessage? Пока просто буль
  bool send(String? msg) {
    if(msg != null){
      _channel?.sink.add(msg);
    }
    return true;
  }

  // === Обработка событий ===

  void listen() {
    _channel?.stream.listen(
      (message) {
        // Handle incoming message
        print('Received: $message');
      },
      onDone: () {
        // Handle WebSocket closing
        print('WebSocket closed');
      },
      onError: (error) {
        // Handle error
        print('Error: $error');
      },
    );
  }

  //через подписчиков
  @override
  void translateData(String? message) {
    print("HELLO! I am gonna translate SMH");
    for (final viewer in subscribersList) {
      viewer.notice(message);
    }
  }

  // === Логика переподключения ===
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;

  void _scheduleReconnect() {
    _reconnectAttempts++;
    final delay = Duration(
      seconds: (1 << (_reconnectAttempts.clamp(0, 5))),
    ); // 1,2,4,8,16,32
    _reconnectTimer = Timer(delay, () => connect());
  }

  @override
  void dispose() {
    //_channel?.sink.close();
    disconnect();
    //у чувака было по-другому :D
    // super.dispose();
  }
}
