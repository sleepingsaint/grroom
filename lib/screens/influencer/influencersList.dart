import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:grroom/models/influencer.dart';
import 'package:grroom/screens/influencer/addInfluencer2.dart';
import 'package:grroom/screens/influencer/influencerScreen.dart';
import 'package:http/http.dart' as http;

class InfluencersList extends StatefulWidget {
  @override
  _InfluencersListState createState() => _InfluencersListState();
}

class _InfluencersListState extends State<InfluencersList> {
 
  final storage = FlutterSecureStorage();
  String token;

  @override
  void initState() { 
    super.initState();
    storage.read(key: "token").then((val) => setState(() => token = val));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: FutureBuilder(
          future: _getInfluencersList(),
          builder: (BuildContext context, AsyncSnapshot snapshot){
            if(snapshot.hasData){
              var data = snapshot.data;
              if(data["status"] == "error"){
                return Column(
                  children: [
                    Text("Ooops! Some error occured"),
                    RaisedButton.icon(
                      icon: Icon(Icons.refresh),
                      label: Text("Refresh"),
                      onPressed: () => setState(() {}),
                    )
                  ],
                );
              }
              List<Influencer> influencers = <Influencer>[];
              data["data"].forEach((inf) => influencers.add(Influencer.fromResp(inf)));

              return ListView.builder(
                itemCount: influencers.length,
                itemBuilder: (BuildContext context, int index){
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Hero(
                          tag: influencers[index].id, 
                          child: influencers[index].image.isEmpty ? Image.asset("assets/designer.jpg") : Image.network(influencers[index].image),
                        ),
                      ),
                      title: Text(influencers[index].igUsername),
                      subtitle: Text("${influencers[index].firstName} ${influencers[index].lastName}"),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            appBar: AppBar(
                              title: Text("data"),
                            ),
                            body: InfluencerScreen(influencer: influencers[index],),
                          )
                        )
                      ),
                    ),
                  );
                }
              );
            }else if(snapshot.hasError){
              return Text("error");
            }
            return SpinKitDoubleBounce(color: Colors.redAccent);
          }
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => Scaffold(
              appBar: AppBar(
                title: Text("Add Influencer"),
              ),
              body: AddInfluencerScreen(),
            )
          )
        )
      ),
    );
  }

  Future<dynamic> _getInfluencersList() async {
    String _endpoint = "https://groombackend.herokuapp.com/api/v1/influencer";
    var resp = await http.get(_endpoint, headers: {HttpHeaders.authorizationHeader : "Bearer $token"});
    return json.decode(resp.body);
  }
}