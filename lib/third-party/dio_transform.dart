import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

class TheNextDevTransform extends DefaultTransformer {
  @override
  Future transformResponse(
      RequestOptions options, ResponseBody response) async {
    if (options.responseType == ResponseType.stream) return response;
    final completer = Completer();
    final chunks = <Uint8List>[];
    int finalSize = 0;
    final _subscription = _onListenProgressResponse(options, response).listen(
      (event) {
        finalSize += event.length;
        chunks.add(event);
      },
      onError: (error, stackTrace) => completer.completeError(error),
      cancelOnError: true,
      onDone: () => completer.complete(),
    );
    options.cancelToken?.whenCancel.then((value) => _subscription.cancel());

    if (options.receiveTimeout > 0) {
      await _timeOutResponse(completer, options, response, _subscription);
    } else {
      return completer.future;
    }

    if (options.responseType == ResponseType.bytes) {
      return _createResponseByte(finalSize, chunks);
    }

    String? responseBody;
    final responseDecoder = options.responseDecoder;
    if (responseDecoder != null) {
      responseBody = responseDecoder(
        _createResponseByte(finalSize, chunks),
        options,
        response..stream = const Stream.empty(),
      );
    } else {
      responseBody = utf8.decode(
        _createResponseByte(finalSize, chunks),
        allowMalformed: true,
      );
    }
    if (responseBody.isNotEmpty &&
        options.responseType == ResponseType.json &&
        _isJsonMime(response.headers[Headers.contentTypeHeader]?.first)) {
      final resultDecode = await _parsingToJson(responseBody);
      return resultDecode;
    }
    return responseBody;
  }

  Future<void> _timeOutResponse(Completer completer, RequestOptions options,
      ResponseBody response, StreamSubscription<Uint8List> subscription) async {
    try {
      await completer.future.timeout(const Duration(milliseconds: 60000));
    } on TimeoutException {
      await subscription.cancel();
      throw DioError(
        requestOptions: options,
        error: 'Receiving data timeout[${options.receiveTimeout}ms]',
        type: DioErrorType.receiveTimeout,
      );
    }
    return;
  }

  Stream<Uint8List> _onListenProgressResponse(
    RequestOptions options,
    ResponseBody response,
  ) async* {
    int length = 0;
    int receive = 0;
    final isShowProgress = options.onReceiveProgress != null;
    length = isShowProgress
        ? int.parse(
            response.headers[Headers.contentLengthHeader]?.first ?? '-1')
        : 0;

    yield* response.stream.map((event) {
      receive += event.length;
      if (isShowProgress) options.onReceiveProgress?.call(receive, length);
      return event;
    });
  }

  Uint8List _createResponseByte(int size, List<Uint8List> chunks) {
    final response = Uint8List(size);
    int offset = 0;
    for (final chunk in chunks) {
      response.setAll(offset, chunk);
      offset++;
    }
    return response;
  }

  bool _isJsonMime(String? contentType) {
    if (contentType == null) return false;
    return MediaType.parse(contentType).mimeType ==
        Headers.jsonMimeType.mimeType;
  }

  Future<String?> _parsingToJson(String? jsonString) async {
    final receivePort = ReceivePort();
    await Isolate.spawn((SendPort sendPort) {
      String? resultDecode;
      final resultJson = jsonString;
      if (resultJson != null) resultDecode = json.decode(resultJson);
      Isolate.exit(sendPort, resultDecode);
    }, receivePort.sendPort);
    final String? resultFromIsolate = await receivePort.first;
    return resultFromIsolate;
  }
}
