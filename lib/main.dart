import 'package:flutter/material.dart';
import 'package:grroom/screens/auth/changePassword.dart';
import 'package:grroom/screens/auth/forgotPassword.dart';
import 'package:grroom/screens/auth/login.dart';
import 'package:grroom/screens/home.dart';
// import 'package:grroom/screens/auth.dart';
import 'package:grroom/screens/stylist.dart';
import 'package:grroom/screens/influencer.dart';
import 'package:grroom/screens/auth/signup.dart';
import 'package:grroom/screens/gallery/gallery.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: <String, WidgetBuilder> {
        "/login": (BuildContext context) => LoginScreen(),
        "/signup": (BuildContext context) => SignupScreen(),
        "/changePassword": (BuildContext context) => ChangePasswordScreen(),
        "/forgotPassword": (BuildContext context) => ForgotPasswordScreen()
      },
      home: MyHomePage(),
    );
  }
}


class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomeScreen()
    );
    // return GalleryScreen();
  }
}