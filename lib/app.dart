import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:MyVPN/pages/main_page.dart';
import 'package:MyVPN/pages/notfound/notfound_page.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "MyVPN - Unlimited, A Fast, Free VPN Proxy",
        theme: ThemeData(
            primaryColor: Colors.blue[600], primarySwatch: Colors.blue),
        debugShowCheckedModeBanner: false,
        showPerformanceOverlay: false,
        home: MainPage(),
        routes: <String, WidgetBuilder>{},
        onUnknownRoute: (RouteSettings rs) =>
            new MaterialPageRoute(builder: (context) => new NotFoundPage()));
    ;
  }
}
