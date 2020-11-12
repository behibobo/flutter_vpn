import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:MyVPN/services/api.dart';
import 'package:MyVPN/services/auth.dart';
import 'package:MyVPN/utils/ad_manager.dart';
import 'package:MyVPN/utils/server_item.dart';
import 'package:flutter/material.dart';
import 'package:MyVPN/models/server.dart';
import 'package:MyVPN/utils/utils.dart';
import 'package:flutter_vpn/flutter_vpn.dart';
import 'package:animator/animator.dart';
import 'package:MyVPN/widgets/main_drawer.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_admob/firebase_admob.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  AuthService appAuth = new AuthService();
  bool loggedIn;
  final GlobalKey _menuKey = new GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  final bgColorDisconnected = [Color(0xFF000000), Color(0xFFDD473D)];
  final bgColorConnected = [Color(0xFF000000), Color(0xFF37AC53)];
  final bgColorConnecting = [Color(0xFF000000), Color(0xFFCCAD00)];

  var state = FlutterVpnState.disconnected;
  List<Server> _allServers = new List<Server>();
  Server selectedSerever = new Server(
      id: 0,
      country: "AutoSelect",
      ip: "",
      flag: "",
      password: "",
      username: "",
      premium: false);
  bool flag = true;
  Stream<int> timerStream;
  StreamSubscription<int> timerSubscription;
  String hoursStr = '00';
  String minutesStr = '00';
  String secondsStr = '00';

  Stream<int> stopWatchStream() {
    StreamController<int> streamController;
    Timer timer;
    Duration timerInterval = Duration(seconds: 1);
    int counter = 0;

    void stopTimer() {
      if (timer != null) {
        timer.cancel();
        timer = null;
        counter = 0;
        streamController.close();
      }
    }

    void tick(_) {
      counter++;
      streamController.add(counter);
      if (!flag) {
        stopTimer();
      }
    }

    void startTimer() {
      timer = Timer.periodic(timerInterval, tick);
    }

    streamController = StreamController<int>(
      onListen: startTimer,
      onCancel: stopTimer,
      onResume: startTimer,
      onPause: stopTimer,
    );

    return streamController.stream;
  }

  Widget setupAlertDialoadContainer() {
    return Container(
      height: 300.0, // Change as per your requirement
      width: 300.0, // Change as per your requirement
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _allServers.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                (_allServers[index].id == 0)
                    ? Icon(Icons.gps_fixed)
                    : Image.network(
                        "https://vpn.coding-lodge.com/" +
                            _allServers[index].flag,
                        width: 20,
                      ),
                Text(_allServers[index].country),
                Row(
                  children: [
                    Icon(Icons.equalizer, color: Colors.green),
                    SizedBox(
                      width: 2,
                    ),
                    Text("233"),
                  ],
                )
              ],
            ),
            onTap: () {
              setState(() {
                selectedSerever = _allServers[index];
                Navigator.of(context).pop();
              });
            },
          );
        },
      ),
    );
  }

  _displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: setupAlertDialoadContainer(),
          );
        });
  }

  _getservers() {
    API.getServers().then((response) {
      Iterable list = json.decode(response.body);
      var servers = list.map((model) => Server.fromJson(model)).toList();
      servers.insert(
          0,
          new Server(
              id: 0,
              country: "AutoSelect",
              ip: "",
              flag: "",
              password: "",
              username: "",
              premium: false));
      setState(() {
        _allServers = servers;
      });
    });
  }

  BannerAd _bannerAd;

  void _loadBannerAd() {
    _bannerAd
      ..load()
      ..show(anchorType: AnchorType.top);
  }

  InterstitialAd myInterstitial;

  InterstitialAd buildInterstitialAd() {
    return InterstitialAd(
      adUnitId: AdManager.interstitialAdUnitId,
      listener: (MobileAdEvent event) {
        if (event == MobileAdEvent.failedToLoad) {
          myInterstitial..load();
        } else if (event == MobileAdEvent.closed) {
          myInterstitial = buildInterstitialAd()..load();
        }
        print(event);
      },
    );
  }

  void showInterstitialAd() {
    myInterstitial..show();
  }

  @override
  void initState() {
    _getservers();
    checkAuth();
    FlutterVpn.prepare();
    FlutterVpn.onStateChanged.listen((s) {
      if (s == FlutterVpnState.connected) {
        // Device Connected
      }
      if (s == FlutterVpnState.disconnected) {
        // Device Disconnected
      }
      setState(() {
        state = s;
      });
    });

    // selectedSerever = _allServers.first;

    _bannerAd = BannerAd(
      adUnitId: AdManager.bannerAdUnitId,
      size: AdSize.banner,
    );

    _loadBannerAd();
    myInterstitial = buildInterstitialAd()..load();
    super.initState();
  }

  void checkAuth() async {
    bool _res = await appAuth.login();
    setState(() {
      loggedIn = _res;
    });
  }

  @override
  void dispose() async {
    _bannerAd?.dispose();
    myInterstitial.dispose();
    super.dispose();
  }

  void connectVpn() {
    if (state == FlutterVpnState.connected) {
      showInterstitialAd();
      FlutterVpn.disconnect();
      timerSubscription.cancel();
      timerStream = null;
      setState(() {
        hoursStr = '00';
        minutesStr = '00';
        secondsStr = '00';
      });
    } else {
      showInterstitialAd();
      // RewardedVideoAd.instance.show();
      timerStream = stopWatchStream();
      timerSubscription = timerStream.listen((int newTick) {
        setState(() {
          hoursStr =
              ((newTick / (60 * 60)) % 60).floor().toString().padLeft(2, '0');
          minutesStr = ((newTick / 60) % 60).floor().toString().padLeft(2, '0');
          secondsStr = (newTick % 60).floor().toString().padLeft(2, '0');
        });
      });
      FlutterVpn.simpleConnect("vpn.nessom.ir", "behzad", "1234@qwerB");
    }
  }

  void changeServer() {}

  void _showModalBottomSheet(BuildContext context) {
    log("serevr select");
  }

  Widget serverConnection(context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: DropdownButton(
        elevation: 2,
        style: TextStyle(fontSize: 15),
        isDense: true,
        iconSize: 20.0,
        value: selectedSerever,
        underline: SizedBox(),
        items: _allServers.map((Server server) {
          return DropdownMenuItem(
              value: server,
              child: Row(
                children: [
                  Image.network("https://vpn.coding-lodge.com/" + server.flag,
                      width: 30.0),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    server.country,
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Icon(
                    Icons.person,
                    size: 15,
                  ),
                  Text(
                    "122",
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ));
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedSerever = value;
          });
        },
      ),
    );
  }

  Widget buildUi(BuildContext context) {
    if (state == FlutterVpnState.connected) {
      //bağlı
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "TAP TO\nTURN OFF VPN",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Montserrat-SemiBold",
                    fontSize: 16.0),
              ),
              SizedBox(height: screenAwareSize(35.0, context)),
              SizedBox(
                width: screenAwareSize(130.0, context),
                height: screenAwareSize(130.0, context),
                child: FloatingActionButton(
                  elevation: 0,
                  backgroundColor: Colors.green,
                  onPressed: connectVpn,
                  child: new Icon(Icons.power_settings_new,
                      size: screenAwareSize(100.0, context)),
                ),
              ),
              SizedBox(height: screenAwareSize(50.0, context)),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                child: Text(
                  "$hoursStr:$minutesStr:$secondsStr",
                  style: TextStyle(fontSize: 25.0, color: Colors.white),
                ),
              ),
              SizedBox(height: screenAwareSize(40.0, context)),
            ],
          ))
        ],
      );
    } else if (state == FlutterVpnState.connecting) {
      // bağlanıyor
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Animator(
                duration: Duration(seconds: 2),
                repeats: 0,
                builder: (anim) => FadeTransition(
                  opacity: anim,
                  child: Text(
                    "CONNECTING",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: "Montserrat-SemiBold",
                        fontSize: 20.0),
                  ),
                ),
              ),
              SizedBox(height: screenAwareSize(35.0, context)),
              SpinKitRipple(
                color: Colors.white,
                size: 190.0,
              ),
              SizedBox(height: screenAwareSize(50.0, context)),
              // serverConnection(context),
              SizedBox(height: screenAwareSize(30.0, context)),
              Text(
                "CONNECTING VPN SERVER",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Montserrat-SemiBold",
                    fontSize: 12.0),
              ),
              SizedBox(height: screenAwareSize(40.0, context)),
            ],
          ))
        ],
      );
    } else {
      // bağlı değil
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "TAP TO\nTURN ON VPN",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Montserrat-SemiBold",
                    fontSize: 16.0),
              ),
              SizedBox(height: screenAwareSize(35.0, context)),
              SizedBox(
                width: screenAwareSize(130.0, context),
                height: screenAwareSize(130.0, context),
                child: FloatingActionButton(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  onPressed: connectVpn,
                  child: new Icon(Icons.power_settings_new,
                      color: Colors.green,
                      size: screenAwareSize(100.0, context)),
                ),
              ),
              SizedBox(height: screenAwareSize(50.0, context)),
              // serverConnection(context),
              RaisedButton(
                  onPressed: () {
                    _displayDialog(context);
                  },
                  child: (selectedSerever.id == 0)
                      ? defaultServer(context)
                      : otherServer(context, selectedSerever)),
              SizedBox(height: screenAwareSize(30.0, context)),
              Text(
                "YOUR INTERNET CONNECTION\nISN'T PROTECTED",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Montserrat-SemiBold",
                    fontSize: 12.0),
              ),
              SizedBox(height: screenAwareSize(40.0, context)),
            ],
          ))
        ],
      );
    }
  }

  Widget defaultServer(BuildContext context) {
    return Container(
        child: Row(
      children: [
        Icon(Icons.gps_fixed),
        SizedBox(
          width: 10,
        ),
        Text("AutoSelect")
      ],
    ));
  }

  Widget otherServer(BuildContext context, Server s) {
    return Container(
        child: Row(
      children: [
        Image.network(
          "https://vpn.coding-lodge.com/" + s.flag,
          width: 20,
        ),
        SizedBox(
          width: 10,
        ),
        Text(s.country)
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          image: new DecorationImage(
            image: new AssetImage("assets/map-pattern.png"),
            fit: BoxFit.contain,
          ),
          gradient: LinearGradient(
              colors: state == FlutterVpnState.connected
                  ? bgColorConnected
                  : (state == FlutterVpnState.connecting
                      ? bgColorConnecting
                      : bgColorDisconnected),
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              tileMode: TileMode.clamp)),
      child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.transparent,
          drawer: MainDrawer(),
          appBar: AppBar(
            iconTheme: new IconThemeData(color: Colors.white),
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            title: Text("MyVPN",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: screenAwareSize(18.0, context),
                    fontFamily: "Montserrat-Bold")),
            centerTitle: true,
          ),
          body: buildUi(context)),
    );
  }
}
