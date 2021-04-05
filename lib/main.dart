import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test_050421/state/message_state.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MyApp());
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MessageData>(
      // calling initialization methods, no needing of initState in the homeScreen
      create: (context) => MessageData()..initMessageState(),
      child: MaterialApp(
        title: 'Local storage',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MessageScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MessageScreen extends StatefulWidget {
  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _messageData = Provider.of<MessageData>(context);
    final String _messageFromStorage = _messageData.messageFromStorage;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                'Привет ${_messageFromStorage == '' ? 'Михаил' : _messageFromStorage}'),
            ElevatedButton(
              child: Text('Изменить'),
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      height: 200,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: _textController,
                              textAlign: TextAlign.center,
                            ),
                            ElevatedButton(
                              child: Text('Сохранить'),
                              onPressed: _textController.text.isEmpty
                                  ? null
                                  : () => _changeText(context),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _changeText(BuildContext context) {
    final _messageData = Provider.of<MessageData>(context, listen: false);

    _messageData.setMessage(_textController.text);
    Navigator.pop(context);
  }
}
