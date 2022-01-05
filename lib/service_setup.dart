abstract class ServiceSetup {
  final String baseUrl;
  final int connectTimeOut;
  final int receiveTimeOut;

  const ServiceSetup({
    required this.baseUrl,
    this.receiveTimeOut = 5000,
    this.connectTimeOut = 3000,
  });
}