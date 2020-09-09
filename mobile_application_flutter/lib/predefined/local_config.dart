// const String HOST = "192.168.0.204";
const String HOST = "localhost";

class LocalConfig {
  static String backendAPI = "http://$HOST:5000/api";
  static String gRPCHost = HOST;
  static int gRPCPort = 50051;
}
