import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grroom/features/influencer/pages/influencer_details_page.dart';
import 'package:grroom/features/stylist/widgets/simple_dialog.dart';
import 'package:grroom/models/influencer.dart';
import 'package:http/http.dart';

class InfluencerCard extends StatelessWidget {
  final int index;
  final ValueNotifier<bool> loadingNotifier;
  const InfluencerCard({
    Key key,
    @required this.isAdmin,
    @required ValueNotifier<List<Influencer>> influencerNotifier,
    this.index,
    this.loadingNotifier,
  })  : _influencerNotifier = influencerNotifier,
        super(key: key);

  final bool isAdmin;
  final ValueNotifier<List<Influencer>> _influencerNotifier;

  @override
  Widget build(BuildContext context) {
    Future<void> deleteInfluencer(String id) async {
      loadingNotifier.value = true;
      String headerToken = await FlutterSecureStorage().read(key: "token");
      String _endpoint = "http://134.209.158.65/api/v1/influencer/$id";
      await delete(_endpoint,
          headers: {HttpHeaders.authorizationHeader: "Bearer $headerToken"});
      _influencerNotifier.value.removeWhere((element) => element.id == id);
      loadingNotifier.value = false;
      showDialog(context: context, child: MySimpleDialog(isSuccess: true));
    }

    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      shadowColor: Image.asset('assets/designer.jpg').color,
      child: ListTile(
        isThreeLine: true,
        trailing: !isAdmin
            ? null
            : IconButton(
                icon: FaIcon(
                  Icons.delete,
                  size: 16,
                ),
                onPressed: () =>
                    deleteInfluencer(_influencerNotifier.value[index].id),
              ),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: Colors.black87,
          child: _influencerNotifier.value[index].image.isEmpty
              ? ClipRRect(
                  child: Image.asset(
                    "assets/no_image.jpg",
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(100),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.network(
                    _influencerNotifier.value[index].image,
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
        title: Text(_influencerNotifier.value[index].igUsername),
        subtitle: Text(
            "${_influencerNotifier.value[index].firstName} ${_influencerNotifier.value[index].lastName}"),
        onTap: () => Navigator.of(context).push(PageRouteBuilder(
          maintainState: false,
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return InfluencerDetailsPage(
              influencer: _influencerNotifier.value[index],
            );
          },
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: new Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeIn)),
                child: child,
              ),
            );
          },
        )),
      ),
    );
  }
}
