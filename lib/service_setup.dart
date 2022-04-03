abstract class ServiceSetup {
  final String baseUrl;
  final int connectTimeOut;
  final int receiveTimeOut;

  const ServiceSetup({
    required this.baseUrl,
    this.receiveTimeOut = 50000,
    this.connectTimeOut = 30000,
  });
}