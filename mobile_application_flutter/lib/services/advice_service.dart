import 'package:flutter_meet_kai_clone/generated/grpc_protos/advice_service.pbgrpc.dart';
import 'package:grpc/grpc.dart';

class AdviceService {
  static final AdviceService _instance = AdviceService();
  factory AdviceService() => _instance;

  final channelOption =
      const ChannelOptions(credentials: ChannelCredentials.insecure());
  getAdvice(question, {handleSuccess, handleFailure}) async {
    final channel =
        ClientChannel('localhost', port: 50051, options: channelOption);
    final stub = AdviceServiceClient(channel);
    try {
      final answer = await stub.ask(Question()..content = question);
      handleSuccess(answer.content);
    } catch (e) {
      handleFailure(e);
    }
    await channel.shutdown();
  }
}
