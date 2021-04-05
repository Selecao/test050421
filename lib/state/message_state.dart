import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:localstorage/localstorage.dart';

part 'message_state.g.dart';

class MessageData extends ChangeNotifier {
  late String _messageFromStorage = '';
  String get messageFromStorage => _messageFromStorage;

  late MessageState _state;
  final String _stateKey = 'state';
  final _storage = LocalStorage('message_data.json');

  /// Initial Message data state
  void initMessageState() async {
    await _storage.ready;

    final _data = _storage.getItem(_stateKey);
    print('data is : $_data');

    try {
      if (_data != null) {
        _state = await _fetchState(_data).then((value) {
          _messageFromStorage = value.text;
          return value;
        });
      }
    } catch (e) {
      print("Error Loading Message State: $e");
    }

    if (_data == null) {
      _state = MessageState(
        text: '',
      );
      _messageFromStorage = _state.text;
    }
    notifyListeners();
  }

  void _saveState() async {
    _state.text = _messageFromStorage;
    return await _storage.setItem(_stateKey, _state.toJson());
  }

  void saveState() async {
    _saveState();
  }

  void setMessage(String text) {
    _messageFromStorage = text;
    _saveState();
    notifyListeners();
  }
}

Future<MessageState> _fetchState(Map<String, dynamic> data) async {
  final _data = json.encode(data);

  /// [compute] create an isolate and parse data that may take long computation
  return compute(_parseState, _data);
}

MessageState _parseState(String data) {
  final map = json.decode(data);

  return MessageState.fromJson(map);
}

@JsonSerializable(explicitToJson: true)
class MessageState {
  String text;
  MessageState({required this.text});

  factory MessageState.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}
