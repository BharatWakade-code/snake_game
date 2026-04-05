import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_game/utils/routes_services/routes_name.dart';

final navigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final GoRouter router = GoRouter(
  debugLogDiagnostics: true,
  navigatorKey: navigatorKey,
  initialLocation: RoutesNames.gameScreen,
  routes: routesList(),
  redirect: (context, state) {
    return null;
  },
);
