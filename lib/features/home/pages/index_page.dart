import 'dart:async';

import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grroom/features/admin/pages/handle_users_page.dart';
import 'package:grroom/features/influencer/pages/handle_influencers_page.dart';
import 'package:grroom/features/stylist/pages/handle_stylist_page.dart';
import 'package:grroom/utils/all_provider.dart';
import 'package:provider/provider.dart';

class IndexPage extends StatefulWidget {
  const IndexPage();
  @override
  IndexPageState createState() => IndexPageState();
}

class IndexPageState extends State<IndexPage> {
  final ValueNotifier<int> pageNumberNotifier = ValueNotifier<int>(0);
  bool isAdmin = false;

  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    FlutterSecureStorage().read(key: 'role').then((value) {
      isAdmin = value == 'admin';
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
    pageNumberNotifier.dispose();
  }

  void _selectedTab(int index) {
    pageNumberNotifier.value = index;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniStartFloat,
        floatingActionButton: isAdmin
            ? FloatingActionButton(
                heroTag: UniqueKey(),
                mini: true,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                backgroundColor: Colors.black87,
                child: FaIcon(
                  FontAwesomeIcons.userGraduate,
                  size: 12,
                ),
                onPressed: () => Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (BuildContext context,
                          Animation<double> animation,
                          Animation<double> secondaryAnimation) {
                        return HandleUsersPage();
                      },
                      transitionsBuilder: (BuildContext context,
                          Animation<double> animation,
                          Animation<double> secondaryAnimation,
                          Widget child) {
                        return SlideTransition(
                          position: new Tween<Offset>(
                            begin: const Offset(0.0, 1.0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                              parent: animation, curve: Curves.easeIn)),
                          child: child,
                        );
                      },
                    )))
            : null,
        body: ValueListenableBuilder(
          valueListenable: pageNumberNotifier,
          builder: (BuildContext context, int value, Widget child) {
            return Stack(
              alignment: Alignment.bottomCenter,
              children: [
                IndexedStack(
                  index: pageNumberNotifier.value,
                  children: [
                    HandleInfluencersPage(),
                    HandleStylistPage(),
                  ],
                ),
                Container(
                  height: kBottomNavigationBarHeight,
                  margin: const EdgeInsets.symmetric(horizontal: 80)
                      .copyWith(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(500),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(500),
                    child: BottomNavigationBar(
                      backgroundColor: Colors.black87,
                      items: <BottomNavigationBarItem>[
                        BottomNavigationBarItem(
                          backgroundColor: Colors.white,
                          icon: FaIcon(
                            FontAwesomeIcons.userCircle,
                            size: 18,
                            color: pageNumberNotifier.value == 0
                                ? Colors.white
                                : Colors.grey,
                          ),
                          title: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Influencer',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: pageNumberNotifier.value == 0
                                    ? Colors.white
                                    : Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        BottomNavigationBarItem(
                          backgroundColor: Colors.white,
                          icon: FaIcon(
                            FontAwesomeIcons.userAlt,
                            size: 18,
                            color: pageNumberNotifier.value == 1
                                ? Colors.white
                                : Colors.grey,
                          ),
                          title: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Data',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: pageNumberNotifier.value == 1
                                    ? Colors.white
                                    : Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                      currentIndex: pageNumberNotifier.value,
                      fixedColor: Colors.redAccent,
                      onTap: _selectedTab,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
