import 'dart:async';
import 'package:appbase/app_localizations.dart';
import 'package:appbase/screens/login_screen.dart';
import 'package:appbase/support/app_info.dart';
import 'package:appbase/support/constants.dart';
import 'package:appbase/tcp/client_tcp.dart';
import 'package:appbase/screens//home_page.dart';
import 'package:flutter/material.dart';

class NetworkSplashScreen extends StatefulWidget {
  @override
  _NetworkSplashScreenState createState() => _NetworkSplashScreenState();
}

class _NetworkSplashScreenState extends State<NetworkSplashScreen> {
  String state = "{l|NET_SPLASH_CONNECTING}";
  bool loading = true;

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () => {
      ClientTCP.open(this.onServerData)
    });
  }

  void onServerData(data) async {
    print("onServerData: $data");
    if (data == NetProtocol.INIT) {
      // Send init data to ged Session ID and Server data
      DeviceInfo deviceInfo = await AppInfo.getDeviceInfo();
      Object query = {
        "LANG": Localizations.localeOf(context).toString(),
        "PLATFORM": deviceInfo.platform,
        "DEVICE": "${deviceInfo.name} | ${deviceInfo.version} | ${deviceInfo.id}"
      };
      ClientTCP.sendData(query, NetProtocol.CODE[NetProtocol.INIT]);
    } else if (data == NetProtocol.CONNECTION_ERROR) {
      setState(() {
        state = "{l|NET_SPLASH_CONNECTING}";
        loading = true;
      });
    } else {
      if (data["CODE"] == NetProtocol.CODE[NetProtocol.INIT]) {
        var response = data["DATA"];
        int time = new DateTime.now().millisecondsSinceEpoch;
        int ping = time - ClientTCP.lastTimeStamp;
        String info = "${response['INFO']} (${ping}ms)";
        setState(() {
          state = info;
          loading = false;
        });
        Timer(Duration(seconds: 1), () => {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()))
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.blueAccent
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          CircleAvatar(
                            backgroundColor: Colors.black38,
                            radius: 60,
                            child: Icon(
                              Icons.wifi,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                          AnimatedOpacity(
                            opacity: loading ? 1: 0,
                            duration: Duration(milliseconds: 500),
                            child: SizedBox(
                              width: 120,
                              height: 120,
                              child: CircularProgressIndicator(
                                valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 5,
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Text(
                        AppLocalizations.of(context).translate(state),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          "Copyright © 2020 justpd Tomsk Russia, Inc. All rights reserved.",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          )
        ],
      )
    );
  }
}
