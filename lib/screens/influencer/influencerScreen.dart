import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:grroom/models/influencer.dart';
import 'package:grroom/screens/influencer/addInfluencer2.dart';

class InfluencerScreen extends StatefulWidget {
  final Influencer influencer;
  InfluencerScreen({@required this.influencer});

  @override
  _InfluencerScreenState createState() => _InfluencerScreenState();
}

class _InfluencerScreenState extends State<InfluencerScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ListView(
          children: [
            Hero(
              tag: widget.influencer.id,
              child: Image.asset("assets/designer.jpg"),
            ),
            Text(widget.influencer.igUsername),
            Text(widget.influencer.igProfileLink),
            Text(widget.influencer.firstName),
            Text(widget.influencer.lastName),
            Text(widget.influencer.speciality),
            Text(widget.influencer.country),
            Text(widget.influencer.undertone),
            Text(widget.influencer.bodySize),
            Text(widget.influencer.bodyShape),
          ],
        )
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.edit),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text("Edit Influencer Details"),
            ),
            body: AddInfluencerScreen(
              influencer: widget.influencer,
            ),
          ))
        ),
      ),
    );
  }
}