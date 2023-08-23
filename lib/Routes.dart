import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'id_selection_screen .dart';


class AppRouter {
  static final FluroRouter router = FluroRouter();

  static void setupRouter() {
    router.define(
      '/',
      handler: _splashHandler,
    );

    // Добавляем маршрут для IdSelectionScreen
    router.define(
      '/idSelection/:display_id',
      handler: _idSelectionHandler,
    );
  }

  static Handler _splashHandler = Handler(
    handlerFunc: (context, Map<String, dynamic> params) {
      String? displayId = params['display_id']?.first;
      return IdSelectionScreen(displayId: displayId);
    },
  );

  static Handler _idSelectionHandler = Handler(
    handlerFunc: (context, Map<String, dynamic> params) {
      String? displayId = params['display_id']?.first;
      return IdSelectionScreen(displayId: displayId);
    },
  );
}
