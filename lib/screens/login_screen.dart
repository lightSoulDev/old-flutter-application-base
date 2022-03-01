import 'dart:async';
import 'dart:math';
import 'package:appbase/app_localizations.dart';
import 'package:appbase/screens/net_splash.dart';
import 'package:appbase/support/app_info.dart';
import 'package:appbase/support/constants.dart';
import 'package:appbase/tcp/client_tcp.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:appbase/screens/home_page.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  AnimationController animationController;
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  var maskFormatter = new MaskTextInputFormatter(mask: '+# (###) ###-##-##', filter: { "#": RegExp(r'[0-9]') });
  bool obscure = true;
  String errorStatus = "";

  @override
  void initState() {
    ClientTCP.setCallback(this.onServerData);
    super.initState();
    print("SID: ${AppInfo.sid}");
    animationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500)
    );
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  void login() {
    if (animationController.value != 0) return;

    print("Login: ${phoneController.text}\nPass: ${passController.text}");

    if (phoneController.text.length < 18) {
      setState(() {
        errorStatus = NetProtocol.LOGIN_ERROR_PHONE;
      });
      return;
    } else if (passController.text.length == 0) {
      setState(() {
        errorStatus = NetProtocol.LOGIN_ERROR_DATA;
      });
      return;
    } else {
      setState(() {
        errorStatus = "";
      });
    }

    FocusScope.of(context).unfocus();
    openLogin();

    Timer(Duration(seconds: 1), () => {
      ClientTCP.sendData({
        "LOGIN": sha256.convert(utf8.encode(phoneController.text)).toString(),
        "PWD": sha256.convert(utf8.encode(passController.text)).toString()
      }, NetProtocol.CODE[NetProtocol.LOGIN])
    });
  }

  void openLogin() {
    animationController.forward();
  }

  void closeLogin() {
    animationController.reverse();
  }

  void toggleLogin() => animationController.isCompleted ? closeLogin() : openLogin();

  void toggleObscure() {
    setState(() {
      obscure = !obscure;
    });
  }

  void onServerData(data) async {
    print("onServerData: $data");
    if (data == NetProtocol.CONNECTION_ERROR) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NetworkSplashScreen()));
    } else if (data["CODE"] == NetProtocol.CODE[NetProtocol.LOGIN]) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          GestureDetector(
              onDoubleTap: this.login,
              onTap: () => FocusScope.of(context).unfocus(),
              child: Container(color: Colors.blueAccent)
          ),
          AnimatedBuilder(
            animation: animationController,
            builder: (context, snapshot) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: Column(
                      children: <Widget>[
                        Text("Login",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(pi * (animationController.value)),
                          child: Padding(
                            padding: EdgeInsets.all(30.0),
                            child: Stack(
                              children: <Widget>[
                                Opacity(
                                  opacity: animationController.value > 0.5
                                      ? 0
                                      : 1 - animationController.value * 2,
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Color.fromARGB(143, 148, 251, 1)
                                              )
                                            ]
                                        ),
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 10),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(7.5),
                                                border:  Border.all(
                                                    color: errorStatus == NetProtocol.LOGIN_ERROR_PHONE
                                                          ? Colors.redAccent
                                                          : Colors.blueAccent,
                                                    width: 1.5
                                                ),
                                              ),
                                              child: TextField(
                                                  controller: phoneController,
                                                  showCursor: false,
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    icon: IconButton(
                                                      icon: Icon(
                                                        Icons.phone_iphone,
                                                      ),
                                                      onPressed: () => print("Test"),
                                                    ),
                                                    hintText: "+7 (---) --- -- --",
                                                    hintStyle: TextStyle(color: Colors.grey),
                                                  ),
                                                  style: TextStyle(
                                                      color: Colors.blueAccent,
                                                      fontWeight: FontWeight.w500,
                                                      letterSpacing: 0.5,
                                                      fontSize: 18
                                                  ),
                                                  inputFormatters: [
                                                    maskFormatter
                                                  ],
                                                  enabled: animationController.value == 0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 5,),
                                      Container(
                                        padding: EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Color.fromARGB(143, 148, 251, 1)
                                              )
                                            ]
                                        ),
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 10),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(7.5),
                                                border:  Border.all(
                                                    color: errorStatus == NetProtocol.LOGIN_ERROR_DATA
                                                        ? Colors.redAccent
                                                        : Colors.blueAccent,
                                                    width: 1.5
                                                ),
                                              ),
                                              child: TextField(
                                                controller: passController,
                                                showCursor: false,
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  icon: IconButton(
                                                    icon: Icon(
                                                      Icons.lock_outline,
                                                    ),
                                                    onPressed: () => print("Test"),
                                                  ),
                                                  hintText: "****",
                                                  hintStyle: TextStyle(color: Colors.grey),
                                                  suffixIcon: IconButton(
                                                    icon: Icon(
                                                      Icons.remove_red_eye,
                                                      color: obscure
                                                          ? Colors.grey
                                                          : Colors.blueAccent,
                                                    ),
                                                    onPressed: this.toggleObscure,
                                                  ),
                                                ),
                                                obscureText: obscure,
                                                style: TextStyle(
                                                  color: Colors.blueAccent,
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: 0.5,
                                                  fontSize: 18,
                                                ),
                                                enabled: animationController.value == 0
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 15,),
                                      Container(
                                          child: Row(
                                            children: <Widget>[
                                              Visibility(
                                                visible: errorStatus != "",
                                                child: Row (
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.error_outline,
                                                      color: Colors.white.withAlpha(180),
                                                    ),
                                                    SizedBox(width: 10,),
                                                    Text(
                                                      AppLocalizations.of(context).translate(errorStatus),
                                                      style: TextStyle(
                                                        color: Colors.white.withAlpha(180),
                                                        fontWeight: FontWeight.w700,
                                                        letterSpacing: 0.5,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ),
                                              Expanded(child: Container(),),
                                              Text(
                                                "double tap",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.5,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              SizedBox(width: 9,),
                                              Icon(
                                                Icons.keyboard_arrow_down,
                                                color: Colors.white,
                                                size: 30,
                                              ),
                                              SizedBox(width: 2,)
                                            ],
                                          )
                                      )
                                    ],
                                  ),
                                ),
                                Opacity(
                                  opacity: animationController.value < 0.5
                                      ? 0
                                      : (animationController.value - 0.5) * 2,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox(height: 35,),
                                      Center(
                                        child: CircularProgressIndicator(
                                          valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              );
            },
          )
        ],
      ),
    );
  }
}
