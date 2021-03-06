import 'package:fluro/fluro.dart';

class TheNextDevRoute {
  final FluroRouter fluroRouter;
  TheNextDevRoute._(this.fluroRouter);

  static late final FluroRouter router;

  factory TheNextDevRoute.create() {
    final fluroRouter = FluroRouter();
    router = fluroRouter;
    return TheNextDevRoute._(router);
  }

  void defineRoutes(Map<String, Handler> routes) {
    for (final itemRoute in routes.keys){
      router.define(itemRoute, handler: routes[itemRoute]);
    }
  }
}