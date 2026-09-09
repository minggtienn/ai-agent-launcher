import 'dart:io';

Future<void> main() async {
  final root = Directory.current;
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
  stdout.writeln('Serving ${root.path} on http://127.0.0.1:8080');
  await for (final request in server) {
    final relative = request.uri.path == '/'
        ? 'latest.json'
        : request.uri.path.substring(1);
    final file = File('${root.path}${Platform.pathSeparator}$relative');
    stdout.writeln('${request.method} ${request.uri.path}');
    if (!await file.exists()) {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      continue;
    }
    request.response.headers.contentType = relative.endsWith('.json')
        ? ContentType.json
        : ContentType.binary;
    request.response.contentLength = await file.length();
    if (request.method != 'HEAD') {
      await request.response.addStream(file.openRead());
    }
    await request.response.close();
  }
}
