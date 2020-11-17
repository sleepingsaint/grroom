import 'package:flutter/material.dart';

class AddAlbumScreen extends StatefulWidget {
  @override
  _AddAlbumScreenState createState() => _AddAlbumScreenState();
}

class _AddAlbumScreenState extends State<AddAlbumScreen> {
  final _albumFormKey = new GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Form(
        key: _albumFormKey,
        child: Column(
          children: [
            // name
            // instagram handle
            // instagram link
            // influencer code
            
          ],
        ),
      ),
    );
  }
}