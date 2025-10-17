enum WsMessageType {
  startEventsStream,
  stopEventsStream,
  keepEventsStream;

  factory WsMessageType.fromJson(int val) {
    switch (val) {
      case 0:
        return WsMessageType.startEventsStream;
      case 1:
        return WsMessageType.stopEventsStream;
      case 4:
        return WsMessageType.keepEventsStream;
      default:
        throw Exception('Unknown WsMessageType value $val');
    }
  }
}

class WsMessage {
  final WsMessageType type;

  WsMessage({required this.type});

  factory WsMessage.fromJson(Map<String, dynamic> json) {
    return WsMessage(type: WsMessageType.fromJson(json['type']));
  }
}
