import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) {
  const customStaticFilePath = 'api/static';
  final cascade = Cascade()
      .add(createStaticFileHandler(path: customStaticFilePath))
      .add(handler);
  return serve(cascade.handler, ip, port);
}
