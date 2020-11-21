import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:grroom/screens/auth/changePassword.dart';
import 'package:grroom/screens/auth/forgotPassword.dart';
import 'package:grroom/screens/auth/login.dart';
import 'package:grroom/screens/home.dart';
import 'package:grroom/screens/influencer/influencersList.dart';
// import 'package:grroom/screens/auth.dart';
import 'package:grroom/screens/stylist.dart';
import 'package:grroom/screens/influencer/addInfluencer.dart';
import 'package:grroom/screens/auth/signup.dart';
import 'package:grroom/screens/admin/handleUsers.dart';

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
  String token;
  String role;
  bool screenLoaded = false;
  bool redirect = false;
  @override
  void initState(){ 
    super.initState();
    final storage = FlutterSecureStorage();
    storage.containsKey(key: "token").then((_contains) {
      if(_contains){
        storage.read(key: "token").then((value) => setState(() => token = value));
        storage.read(key: "role").then((value) => setState(() => role = value));        
      }else{
        setState(() => redirect = true);
      }

      setState(() {
        screenLoaded = true;
      });
    });
  }

  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          // child: screenLoaded ? 
          //   redirect ? LoginScreen() : Text("Home Page") 
          //   : SpinKitDoubleBounce(color: Colors.redAccent)
          child: StylistScreen(),
        ),
      ),
      bottomNavigationBar: screenLoaded && !redirect ? BottomNavigationBar(
        currentIndex: _selectedTab,
        showUnselectedLabels: false,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.supervised_user_circle_sharp),
            label: "Influencer"
          )
        ],
        onTap: (index) => setState(() => _selectedTab = index),
      ) : null,
    );
    // return GalleryScreen();
  }
}