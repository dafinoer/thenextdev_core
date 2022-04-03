import 'package:dio/dio.dart';
import '../../service_setup.dart';
import 'dio_transform.dart';

class DioService {
  final Dio _dio;

  DioService._(this._dio);

  static late final Dio service;

  factory DioService.create(ServiceSetup setup) {
    final option = BaseOptions(
        baseUrl: setup.baseUrl,
        connectTimeout: setup.connectTimeOut,
        receiveTimeout: setup.receiveTimeOut);
    service = Dio(option);
    service.transformer = TheNextDevTransform();
    return DioService._(service);
  }

  void addInterceptors(List<Interceptor> interceptors) =>
      _dio.interceptors.addAll(interceptors);
}
