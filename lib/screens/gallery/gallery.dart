import 'package:flutter/material.dart';
import 'package:grroom/screens/influencer.dart';

class GalleryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => Scaffold(
                appBar: AppBar(
                  title: Text("Add Influencer album"),
                ),
                body: InfluencerScreen(),
              )
            )
          )
        },
      ),
    );
  }
}