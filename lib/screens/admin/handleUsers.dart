import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:grroom/models/user.dart';

class HandleUsersScreen extends StatefulWidget {
  @override
  _HandleUsersScreenState createState() => _HandleUsersScreenState();
}

class _HandleUsersScreenState extends State<HandleUsersScreen> {
  String token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjVmYjBmODc3M2NiOTgzMDAxNzA0MDM5OCIsImlhdCI6MTYwNTg1MTQ3MiwiZXhwIjoxNjEzNjI3NDcyfQ.vDCEocYHHUxtYlwy7mF0Las5gASDkTE0xU02yp2xbH0";
//  eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjVmYjBmODc3M2NiOTgzMDAxNzA0MDM5OCIsImlhdCI6MTYwNTg1MTQ3MiwiZXhwIjoxNjEzNjI3NDcyfQ.vDCEocYHHUxtYlwy7mF0Las5gASDkTE0xU02yp2xbH0
  List<UserModel> users = [];
  @override
  void initState() { 
    super.initState();
    final storage = FlutterSecureStorage();
    // storage.read(key: "token").then((val) => setState(() => token = val));

    http.get("https://groombackend.herokuapp.com/api/v1/user", headers: {
      HttpHeaders.authorizationHeader: "Bearer $token"
    }).then((value) {
      var resp = jsonDecode(value.body);
      print(resp);
      List<UserModel> tempUsers = [];
      if(resp["status"] == "success"){
        List data = resp["data"];
        data.forEach((_user) {
          if(_user["role"] != "admin"){
            tempUsers.add(UserModel.fromResp(_user));
          }
        });
        setState(() => users = tempUsers);
      }else {
        print("Oops! some error occured");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index){
          return Dismissible(
            key: Key(index.toString()),
            child: Card(
              child: ListTile(
                title: Text("${users[index].firstName} ${users[index].lastName}"),
                subtitle: Text("${users[index].email}"),
              ),
            ),
            onDismissed: (dir) => activateUser(dir, users[index].id, index),

            background: Container(
              alignment: Alignment.centerLeft,
              color: Colors.green,
              child: Icon(Icons.check, color: Colors.white,),
            ),

            secondaryBackground: Container(
              alignment: Alignment.centerRight,
              child: Icon(Icons.cancel, color: Colors.white,),
              color: Colors.red,
            )
          );
        },
      )
    );
  }

  Future<void> activateUser(DismissDirection dir, String id, int index) async {
    if(dir == DismissDirection.startToEnd){
      var resp = await http.patch("https://groombackend.herokuapp.com/api/v1/user/$id", headers: {
        HttpHeaders.authorizationHeader: "Bearer $token"
      });

      print(resp.body);
      var data = jsonDecode(resp.body);
      if(data["status"] == "success"){
        print("success");
      }else{
        print(data);
      }
    }
  }
}