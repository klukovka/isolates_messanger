import 'dart:async';
import 'dart:isolate';

void main() async {
  SendPort mainToIsolateStream = await initIsolate();

  mainToIsolateStream.send('This is from main()');

  for (int i = 0; i < 10; i++) {
    mainToIsolateStream.send('This is from main() $i');
  }
}

Future<SendPort> initIsolate() async {
  Completer completer = Completer<SendPort>();
  ReceivePort isolateToMainStream = ReceivePort();

  isolateToMainStream.listen((data) {
    if (data is SendPort) {
      SendPort mainToIsolateStream = data;
      completer.complete(mainToIsolateStream);
    } else {
      print('[isolateToMainStream] $data');
    }
  });

  await Isolate.spawn(
    myIsolate,
    isolateToMainStream.sendPort,
  );
  return completer.future as Future<SendPort>;
}

void myIsolate(SendPort isolateToMainStream) {
  ReceivePort mainToIsolateStream = ReceivePort();
  isolateToMainStream.send(mainToIsolateStream.sendPort);

  mainToIsolateStream.listen((data) {
    print('[mainToIsolateStream] $data');
  });

  isolateToMainStream.send('This is from myIsolate()');
  for (int i = 0; i < 10; i++) {
    isolateToMainStream.send('This is from myIsolate() $i');
  }
}
