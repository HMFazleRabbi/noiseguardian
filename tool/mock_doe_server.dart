import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

/// Optional desktop HTTP mock DoE portal for manual HttpSyncService testing.
///
/// Run: `dart run tool/mock_doe_server.dart`
Future<void> main(List<String> args) async {
  final port = int.tryParse(
        args.isNotEmpty ? args.first : Platform.environment['PORT'] ?? '',
      ) ??
      8080;
  int seq = 0;

  final router = Router()
    ..post('/api/v1/evidence', (Request request) async {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final hash = json['hash_sha256'] as String? ?? '';
      if (hash.isEmpty) {
        return Response(400, body: '{"error":"invalid packet"}');
      }
      seq += 1;
      final now = DateTime.now().toUtc();
      final date =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
      final receiptId =
          '#DOE-DHK-$date-${seq.toString().padLeft(4, '0')}';
      final serverSig = sha256
          .convert(utf8.encode('$receiptId:$hash:mock-doe-http'))
          .toString();
      return Response(
        201,
        headers: {'content-type': 'application/json'},
        body: jsonEncode({
          'receipt_id': receiptId,
          'server_signature': serverSig,
        }),
      );
    });

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(router.call);

  final server = await shelf_io.serve(handler, InternetAddress.loopbackIPv4, port);
  // ignore: avoid_print
  print('Mock DoE server listening on http://${server.address.host}:${server.port}');
}
