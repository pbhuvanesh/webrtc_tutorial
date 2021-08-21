import 'package:event_bus/event_bus.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketUtil {
  IO.Socket socket;
  EventBus? _eventBus;
  //'http://3.15.208.130:3030'
  static final SocketUtil _socketUtil =
      SocketUtil._internal(IO.io('http://3.15.208.130:3030', <String, dynamic>{
    'transports': ['websocket'],
  }));

  factory SocketUtil() {
    return _socketUtil;
  }

  SocketUtil._internal(this.socket) {
    _eventBus = EventBus();
  }

  void emitEvent({required String event, required Map<String, dynamic> data}) {
    socket.emit('create', [event, data]);
  }

  Stream<T> listenTo<T>(
      {required String collectionName, required Function deserializeFunction}) {
    socket.on('$collectionName created', (newData) {
      try {
        T object = deserializeFunction(newData);
        print('NEW $collectionName: $object');
        _eventBus!.fire(object);
      } catch (e) {
        print('Failed $e');
      }
    });
    print(socket.hasListeners('$collectionName created'));
    return _eventBus!.on<T>();
  }
}
