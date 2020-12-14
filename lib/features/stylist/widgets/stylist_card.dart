import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grroom/features/stylist/pages/stylist_details_page.dart';
import 'package:grroom/features/stylist/widgets/simple_dialog.dart';
import 'package:grroom/models/stylist.dart';
import 'package:http/http.dart';

class StylistCard extends StatelessWidget {
  final int index;
  final ValueNotifier<bool> loadingNotifier;

  final ValueNotifier<List<Stylist>> stylistNotifier;
  const StylistCard(
      {Key key, this.index, this.loadingNotifier, this.stylistNotifier})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<void> deleteInfluencer(String id) async {
      loadingNotifier.value = true;
      String headerToken = await FlutterSecureStorage().read(key: "token");
      String _endpoint = "http://134.209.158.65/api/v1/meta/$id";
      await delete(_endpoint,
          headers: {HttpHeaders.authorizationHeader: "Bearer $headerToken"});
      stylistNotifier.value.removeWhere((element) => element.id == id);
      loadingNotifier.value = false;
      showDialog(context: context, child: MySimpleDialog(isSuccess: true));
    }

    return InkWell(
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        shadowColor: Image.asset('assets/designer.jpg').color,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          onTap: () => Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secondaryAnimation) {
              return StylistDetailsPage(
                stylist: stylistNotifier.value[index],
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
          leading: CircleAvatar(
              radius: 26,
              backgroundColor: Colors.black87,
              child: ClipRRect(
                child: Image.network(
                  stylistNotifier.value[index].image,
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(100),
              )),
          trailing: IconButton(
            icon: FaIcon(
              Icons.delete,
              size: 16,
            ),
            onPressed: () => deleteInfluencer(stylistNotifier.value[index].id),
          ),
          title: Text(stylistNotifier.value[index].id),
          subtitle: stylistNotifier.value[index].place == ''
              ? null
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.locationArrow,
                      size: 12,
                      color: stylistNotifier.value[index].place == null
                          ? Colors.white
                          : Colors.black26,
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(stylistNotifier.value[index].place),
                  ],
                ),
        ),
      ),
    );
  }
}
