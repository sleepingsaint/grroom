import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:grroom/models/influencer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ola_like_country_picker/ola_like_country_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class AddInfluencerScreen extends StatefulWidget {
  final Influencer influencer;
  AddInfluencerScreen({this.influencer});

  @override
  _AddInfluencerScreenState createState() => _AddInfluencerScreenState();
}

class _AddInfluencerScreenState extends State<AddInfluencerScreen> {
  final Dio dio = new Dio();
  final _formKey = GlobalKey<FormState>();
  final storage = FlutterSecureStorage();
  String token;
  PickedFile _image;
  final _picker = ImagePicker();

  TextEditingController _instaHandleController = new TextEditingController();
  TextEditingController _instaLinkController = new TextEditingController();
  TextEditingController _followersController = new TextEditingController();
  TextEditingController _countryController = new TextEditingController();
  TextEditingController _occupationController = new TextEditingController();

  String _selectedBodyTone;
  String _selectedBodyShape;
  String _selectedSpeciality;
  
  List<String> _bodyToneOptions = <String>["fair", "neutral", "dark"];
  List<String> _bodyShapeOptions = <String>["fat", "slim", "fit"];
  List<String> _specialityOptions = <String>["specail", "not special", "very special"]; 

  @override
  void initState() { 
    super.initState();
    storage.read(key: "token").then((val) => setState(() => token = val));
    if(widget.influencer != null){
      _instaHandleController.text = widget.influencer.igUsername;
      _instaLinkController.text = widget.influencer.igProfileLink;
      _countryController.text = widget.influencer.country;
    }
  }
  @override
  Widget build(BuildContext context) {

    // Influencer Image
    Widget _imageWidget = _image == null ? 
      (widget.influencer.image == null || widget.influencer.image.isEmpty) ? 
        null : Image.network(widget.influencer.image ?? "") 
      : Image.file(File(_image.path));

    Widget _imagePicker = RaisedButton.icon(
      onPressed: getImage, 
      icon: Icon(_image == null ? Icons.image : Icons.refresh), 
      label: Text(_image == null ? "Select Image" : "Select another image"),
    );

    // Instagram Handle
    Widget _instaHandle = TextFormField(
      controller: _instaHandleController,
      decoration: InputDecoration(
        labelText: "Instagram Handle",
        border: OutlineInputBorder(),
      ),
      validator: (val){
        if(val.isEmpty){
          return "Please enter the insta handle";
        }else if(val.length < 3){
          return "Please enter valid insta handle";
        }

        return null;
      },
    );

    // Instagram Link
    Widget _instaLink = TextFormField(
      controller: _instaLinkController,
      decoration: InputDecoration(
        labelText: "Instagram Link",
        border: OutlineInputBorder(),
      ),
      validator: (val){
        if(val.isEmpty){
          return "Please enter the insta handle";
        }else if(val.length < 3){
          return "Please enter valid insta handle";
        }
        return null;
      },
    );

    // body tone
    Widget _bodyTone = DropdownButtonFormField(
      decoration: InputDecoration(
        hintText: "Select Body Tone",
        border: OutlineInputBorder(),
      ),
      value: _selectedBodyTone,
      items: _bodyToneOptions.map((_tone) => DropdownMenuItem(value: _tone, child: Text(_tone))).toList(),
      validator: (val) => val == null || val.isEmpty ? "Please select a option" : null,
      onChanged: (val) => setState(() => _selectedBodyTone = val),
    );

    // body shape
    Widget _bodyShape = DropdownButtonFormField(
      decoration: InputDecoration(
        hintText: "Select Body Shape",
        border: OutlineInputBorder(),
      ),
      value: _selectedBodyShape,
      items: _bodyShapeOptions.map((_shape) => DropdownMenuItem(value: _shape, child: Text(_shape))).toList(),
      validator: (val) => val.isEmpty ? "Please select a option" : null,
      onChanged: (val) => setState(() => _selectedBodyShape = val),
    );

    // Country
    CountryPicker _countryPicker = CountryPicker(
      onCountrySelected:(country){
        setState(() {
          _countryController.text = country.name;
        });
      },
    );

    Widget _country = TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: "Select Country",
        border: OutlineInputBorder(),
      ),
      controller: _countryController,
      onTap: () => _countryPicker.launch(context),
      validator: (val) => val.isEmpty ? "Please select a country" : null,
    );
    
    // no of followers
    Widget _numFollowers = TextFormField(
      controller: _followersController,
      decoration: InputDecoration(
        labelText: "Enter number of followers",
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      validator: (val) => val.isEmpty ? "Please enter a value" : null,
    );

    // Speciality
    Widget _speciality = DropdownButtonFormField(
      decoration: InputDecoration(
        hintText: "Select Speciality",
        border: OutlineInputBorder(),
      ),
      value: _selectedBodyShape,
      items: _specialityOptions.map((_shape) => DropdownMenuItem(value: _shape, child: Text(_shape))).toList(), 
      onChanged: (val) => setState(() => _selectedSpeciality = val),
      validator: (val) => val == null || val.isEmpty ? "Please select a option" : null,
    );

    // Occupations
    Widget _occupation = TextFormField(
      controller: _occupationController,
      decoration: InputDecoration(
        labelText: "Enter Occupation",
        border: OutlineInputBorder(),
      ),
      validator: (val) => val.isEmpty ? "Please enter a occupation" : null,
    );


    return Container(
      padding: EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: ListView(

          // image picker
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _imageWidget
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _imagePicker,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _instaHandle,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _instaLink,
            ),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: _bodyShape,
            // ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _bodyTone,
            ), 
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _country,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _numFollowers,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _speciality,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _occupation,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 8.0),
              child: RaisedButton.icon(
                padding: EdgeInsets.all(8.0),
                color: Colors.blueGrey,
                onPressed: _handleSubmitInfluencer,
                icon: Icon(Icons.check, color: Colors.white,),
                label: Text(widget.influencer == null ? "Add influencer" : "Sumbit", style: TextStyle(color: Colors.white),)
              ),
            )
          ],
        ),
        
      ),
    );
  }

  Future<void> _handleSubmitInfluencer() async {
    if(_formKey.currentState.validate()){
      const String endpoint = "https://groombackend.herokuapp.com/api/v1/influencer";
      FormData formData = new FormData.fromMap({
          "firstName": "salman katsdfasdrina",
          "lastName": "khasdfasdfan",
          "igUsername": _instaHandleController.text ?? "",
          "igProfileLink": _instaLinkController.text ?? "",
          "undertone": _selectedBodyTone ?? "",
          "bodyShape": _selectedBodyShape ?? "",
          "bodySize": "fat",
          "noOfFollower": _followersController.text ?? "",
          "country": _countryController.text ?? "",
          "speciality": _selectedSpeciality ?? "",
          "image": await MultipartFile.fromFile(_image.path, filename: _image.path.split('/').last)
        });
     
      var res = await dio.post(endpoint, data: formData, options: RequestOptions(
        headers: {HttpHeaders.authorizationHeader : "Bearer $token"},
      ));
      // var res = await http.post(
      //   endpoint,
      //   headers: {HttpHeaders.authorizationHeader : "Bearer $token"},
      //   body: {
      //     "firstName": "salman",
      //     "lastName": "khan",
      //     "igUsername": _instaHandleController.text ?? "",
      //     "igProfileLink": _instaLinkController.text ?? "",
      //     "undertone": _selectedBodyTone ?? "",
      //     "bodyShape": _selectedBodyShape ?? "",
      //     "bodySize": "fat",
      //     "noOfFollower": _followersController.text ?? "",
      //     "country": _countryController.text ?? "",
      //     "speciality": _selectedSpeciality ?? "",
      //     "image": _image
      //   }
      // );


      print(res.data);
    }

    print(_formKey.currentState);
  }

  Future getImage() async {
    final _pickedImage = await _picker.getImage(source: ImageSource.gallery);
    setState(() {
      if(_pickedImage != null){
        _image = _pickedImage;
        print(_image.path.split('/').last);
      }
    });
  }
}