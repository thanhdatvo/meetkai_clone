import 'package:flutter_meet_kai_clone/streams/built_single_stream/suggest_movies_stream.dart';
import 'package:flutter_meet_kai_clone/modals/grpc_protos/advice_service.pbgrpc.dart';
import 'package:flutter_meet_kai_clone/predefined/local_config.dart';
import 'package:grpc/grpc.dart';

class SuggestedMoviesGRPCProvider {
  final channelOption =
      const ChannelOptions(credentials: ChannelCredentials.insecure());
  Future<Answer> readMultiple(SuggestMoviesParams params) async {
    final channel = ClientChannel(LocalConfig.gRPCHost,
        port: LocalConfig.gRPCPort, options: channelOption);
    final stub = AdviceServiceClient(channel);
    final answer = await stub.ask(Question()
      ..content = params.movieTitle
      ..userId = params.userId);
    return answer;
  }
}
