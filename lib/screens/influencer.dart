import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ola_like_country_picker/ola_like_country_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:filesystem_picker/filesystem_picker.dart';

class InfluencerScreen extends StatefulWidget {
  @override
  _InfluencerScreenState createState() => _InfluencerScreenState();
}

class _InfluencerScreenState extends State<InfluencerScreen> {

  final _formKey = GlobalKey<FormState>();

  PickedFile _image;
  final _picker = ImagePicker();
  Future getImage() async {
    final _pickedImage = await _picker.getImage(source: ImageSource.gallery);
    setState(() {
      if(_pickedImage != null){
        _image = _pickedImage;
      }
    });
  }

  TextEditingController _instaHandleController = new TextEditingController();
  TextEditingController _instaLinkController = new TextEditingController();
  TextEditingController _followersController = new TextEditingController();
  TextEditingController _countryController = new TextEditingController();
  TextEditingController _occupationController = new TextEditingController();
  TextEditingController _albumController = new TextEditingController();

  String _selectedBodyTone;
  String _selectedBodyShape;
  String _selectedSpeciality;
  
  List<String> _bodyToneOptions = <String>["fair", "neutral", "dark"];
  List<String> _bodyShapeOptions = <String>["fat", "slim", "fit"];
  List<String> _specialityOptions = <String>["specail", "not special", "very special"];

  Future<void> _pickDirectory(BuildContext context) async {
    Directory _rootDir = await getExternalStorageDirectory();
    String path = await FilesystemPicker.open(
      title: 'Select Influencer album folder',
      context: context,
      rootDirectory: _rootDir,
      fsType: FilesystemType.folder,
      pickText: 'select folder',
      folderIconColor: Colors.teal,
    );
    if(path != null) {
      setState(() => _albumController.text = path);
    }
  } 
  @override
  Widget build(BuildContext context) {

    // Influencer Image
    Widget _imagePicker = RaisedButton.icon(
      onPressed: getImage, 
      icon: Icon(_image == null ? Icons.image : Icons.refresh), 
      label: Text(_image == null ? "Select Image" : "Select another image"),
    );

    Widget _imageWidget = _image != null ? Image.file(File(_image.path)) : null;

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

    // picking the album folder for influencer
    Widget _album = TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: "Select Album Folder",
        border: OutlineInputBorder(),
      ),
      controller: _albumController,
      onTap: () => _pickDirectory(context),
      validator: (val) => val.isEmpty ? "Please select a country" : null,
    );

    return Container(
      padding: EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: _imageWidget,
                color: Colors.red,
              ),
            ),
            _imagePicker,
            _instaHandle,
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
              padding: const EdgeInsets.all(8.0),
              child: _album,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 8.0),
              child: RaisedButton.icon(
                padding: EdgeInsets.all(8.0),
                color: Colors.blueGrey,
                onPressed: _handleSubmitInfluencer,
                icon: Icon(Icons.check, color: Colors.white,),
                label: Text("Add influencer", style: TextStyle(color: Colors.white),)
              ),
            )
          ],
        ),
        
      ),
    );
  }

  void _handleSubmitInfluencer(){
    if(_formKey.currentState.validate()){
      print("success");
    }
    print(_formKey.currentState);
  }
}