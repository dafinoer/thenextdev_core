import 'package:dio/dio.dart';
import 'package:thenextdev_core/service_setup.dart';

class DioService {
  static late final Dio service;
  final Dio dio;
  DioService._(this.dio);

  factory DioService.create(ServiceSetup setup) {
    final option = BaseOptions(
      baseUrl: setup.baseUrl,
      connectTimeout: setup.connectTimeOut,
      receiveTimeout: setup.receiveTimeOut
    );
    service = Dio(option);
    
    return DioService._(service);
  }

  void addInterceptors(List<Interceptor> interceptors) =>
      dio.interceptors.addAll(interceptors);
}
