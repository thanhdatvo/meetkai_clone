import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

enum HttpMethod { get, post, put, patch, delete }

class Network {
  static Network _instance = new Network._();
  final Dio _dio = Dio();
  Network._();

  factory Network() => _instance;

  Future<Response> request(HttpMethod method, String requestUrl,
      {String body}) async {
    Response response;
    _dio.options.headers[HttpHeaders.acceptHeader] = ContentType.json;
    switch (method) {
      case HttpMethod.get:
        response = await _dio.get(requestUrl);
        break;
      case HttpMethod.delete:
        response = await _dio.delete(requestUrl);
        break;
      case HttpMethod.post:
        response = await _dio.post(requestUrl, data: body);
        break;
      case HttpMethod.patch:
        response = await _dio.patch(requestUrl, data: body);
        break;
      case HttpMethod.put:
        response = await _dio.put(requestUrl, data: body);
        break;
    }
    return response;
  }
}
