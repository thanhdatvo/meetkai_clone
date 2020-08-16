///
//  Generated code. Do not modify.
//  source: grpc_protos/advice_service.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:async' as $async;

import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'advice_service.pb.dart' as $0;
export 'advice_service.pb.dart';

class AdviceServiceClient extends $grpc.Client {
  static final _$ask = $grpc.ClientMethod<$0.Question, $0.Answer>(
      '/advice_service.AdviceService/Ask',
      ($0.Question value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Answer.fromBuffer(value));

  AdviceServiceClient($grpc.ClientChannel channel, {$grpc.CallOptions options})
      : super(channel, options: options);

  $grpc.ResponseFuture<$0.Answer> ask($0.Question request,
      {$grpc.CallOptions options}) {
    final call = $createCall(_$ask, $async.Stream.fromIterable([request]),
        options: options);
    return $grpc.ResponseFuture(call);
  }
}

abstract class AdviceServiceBase extends $grpc.Service {
  $core.String get $name => 'advice_service.AdviceService';

  AdviceServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.Question, $0.Answer>(
        'Ask',
        ask_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Question.fromBuffer(value),
        ($0.Answer value) => value.writeToBuffer()));
  }

  $async.Future<$0.Answer> ask_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Question> request) async {
    return ask(call, await request);
  }

  $async.Future<$0.Answer> ask($grpc.ServiceCall call, $0.Question request);
}
