import 'package:MyVPN/pages/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:MyVPN/pages/about_page.dart';
import 'package:MyVPN/pages/setting_page.dart';

class MainDrawer extends StatelessWidget {
  final bgColorDisconnected = [Color(0xFF000000), Color(0xFFDD473D)];

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Container(
      width: double.infinity,
      decoration: BoxDecoration(
          image: new DecorationImage(
        image: new AssetImage("assets/map-pattern.png"),
        fit: BoxFit.contain,
      )),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            child: DrawerHeader(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                padding: EdgeInsets.all(15),
                child: Stack(children: <Widget>[
                  Center(
                      child: Container(child: Image.asset("assets/icon.png"))),
                  Positioned(left: 8.0, bottom: 8.0, child: Text("MyVPN"))
                ])),
          ),
          new ListTile(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => LoginScreen()));
            },
            title: Text(
              "Buy Premium",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.0),
            ),
            leading: Icon(
              Icons.verified_user,
              color: Colors.black,
            ),
          ),
          new ListTile(
            onTap: () {},
            title: Text(
              "Feedback",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.0),
            ),
            leading: Icon(
              Icons.feedback,
              color: Colors.black,
            ),
          ),
          new ListTile(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => SettingPage()));
            },
            title: Text(
              "setting",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.0),
            ),
            leading: Icon(
              Icons.settings,
              color: Colors.black,
            ),
          ),
          new ListTile(
            onTap: () {},
            title: Text(
              "Help",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.0),
            ),
            leading: Icon(
              Icons.help,
              color: Colors.black,
            ),
          ),
          new ListTile(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => AboutPage()));
            },
            title: Text(
              "About",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.0),
            ),
            leading: Icon(
              Icons.info,
              color: Colors.black,
            ),
          )
        ],
      ),
    ));
  }
}
