import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grroom/data/remote_fetch.dart';
import 'package:grroom/features/stylist/widgets/simple_dialog.dart';
import 'package:grroom/main.dart';
import 'package:grroom/models/influencer.dart';
import 'package:http/http.dart' as http;

import 'influencer_details_page.dart';
import 'influencer_page.dart';

class HandleInfluencersPage extends StatefulWidget {
  const HandleInfluencersPage({Key key}) : super(key: key);
  @override
  _HandleInfluencersPageState createState() => _HandleInfluencersPageState();
}

class _HandleInfluencersPageState extends State<HandleInfluencersPage> {
  bool isAdmin = false;
  ScrollController _controller;
  final ValueNotifier<int> _pageNotifier = ValueNotifier<int>(1);
  final ValueNotifier<List<Influencer>> _influencerNotifier =
      ValueNotifier<List<Influencer>>([]);
  final ValueNotifier<bool> _loadingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _endListNotifier = ValueNotifier<bool>(false);
  @override
  void initState() {
    _loadFirst20();
    _controller = ScrollController()
      ..addListener(() {
        if (_controller.position.pixels ==
            _controller.position.maxScrollExtent) {
          if (!_endListNotifier.value) {
            _loadMore();
          }
        }
      });

    FlutterSecureStorage().read(key: 'role').then((value) {
      isAdmin = value == 'admin';
    });
    super.initState();
  }

  Future _loadFirst20() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final List<Influencer> inf = await RemoteFetch.getAllInfluencers(
        pageNumber: _pageNotifier.value, limit: 20);
    _influencerNotifier.value.addAll(inf);
    _pageNotifier.value = 4;
    _pageNotifier.value++;
  }

  Future _loadMore() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final List<Influencer> inf = await RemoteFetch.getAllInfluencers(
        pageNumber: _pageNotifier.value, limit: 5);
    if (inf.isNotEmpty) {
      _influencerNotifier.value.addAll(inf);
      _pageNotifier.value++;
    } else {
      _endListNotifier.value = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('///////////////////////////////rebuild');
    Future<void> deleteInfluencer(String id) async {
      _loadingNotifier.value = true;
      String headerToken = await FlutterSecureStorage().read(key: "token");
      String _endpoint = "http://134.209.158.65/api/v1/influencer/$id";
      await http.delete(_endpoint,
          headers: {HttpHeaders.authorizationHeader: "Bearer $headerToken"});
      _loadingNotifier.value = false;
      showDialog(context: context, child: MySimpleDialog(isSuccess: true));
    }

    return AnimatedBuilder(
      animation: Listenable.merge([
        _pageNotifier,
        _loadingNotifier,
        _influencerNotifier,
        _endListNotifier
      ]),
      builder: (BuildContext context, Widget child) {
        return SafeArea(
          child: Stack(
            children: [
              Scaffold(
                body: CustomScrollView(
                  controller: _controller,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                      elevation: 1,
                      leading: IconButton(
                        icon: Transform.rotate(
                          angle: pi,
                          child: FaIcon(
                            FontAwesomeIcons.signOutAlt,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () async {
                          showCupertinoDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CupertinoAlertDialog(
                                content: Text(
                                  'Are you sure you want to logout',
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                                title: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    'Warning',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                  ),
                                ),
                                actions: <Widget>[
                                  CupertinoButton(
                                      child: Text('No'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      }),
                                  CupertinoButton(
                                      child: Text('Yes'),
                                      onPressed: () async {
                                        await FlutterSecureStorage()
                                            .delete(key: 'token');
                                        await FlutterSecureStorage()
                                            .delete(key: 'role');
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            maintainState: false,
                                            builder: (_) => MyHomePage(),
                                          ),
                                        );
                                      }),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      backgroundColor: Colors.white,
                      automaticallyImplyLeading: false,
                      stretch: true,
                      floating: true,
                      expandedHeight: 60,
                      flexibleSpace: FlexibleSpaceBar(
                        centerTitle: true,
                        title: null,
                        background: InkWell(
                          onTap: () {
                            showSearch(
                                context: context,
                                delegate: InfluencerSearch(
                                    _influencerNotifier.value,
                                    contextPage: context));
                          },
                          child: Container(
                            height: 40,
                            alignment: Alignment.center,
                            width: double.maxFinite,
                            decoration: const BoxDecoration(
                              color: Colors.black87,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Spacer(),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.search,
                                      color: Colors.white54,
                                      size: 16,
                                    ),
                                    SizedBox(
                                      width: 4,
                                    ),
                                  ],
                                ),
                                Text(
                                  'Search influencers',
                                  style: TextStyle(
                                      color: Colors.white54,
                                      letterSpacing: 0.5,
                                      fontWeight: FontWeight.w400),
                                ),
                                Spacer(),
                                IconButton(
                                  icon: Icon(
                                    Icons.refresh,
                                    color: Colors.white30,
                                  ),
                                  onPressed: () async {
                                    _loadingNotifier.value = true;
                                    await _loadMore();
                                    _loadingNotifier.value = false;
                                  },
                                )
                              ],
                            ),
                          ),
                        ),
                        stretchModes: [
                          StretchMode.zoomBackground,
                        ],
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          ListView.builder(
                              padding:
                                  const EdgeInsets.only(top: 20, bottom: 100),
                              physics: const BouncingScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: _endListNotifier.value
                                  ? _influencerNotifier.value.length
                                  : _influencerNotifier.value.length + 1,
                              itemBuilder: (BuildContext context, int index) {
                                if (index == _influencerNotifier.value.length) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CupertinoActivityIndicator(),
                                  );
                                } else
                                  return Card(
                                    elevation: 5,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                    shadowColor:
                                        Image.asset('assets/designer.jpg')
                                            .color,
                                    child: ListTile(
                                      isThreeLine: true,
                                      trailing: !isAdmin
                                          ? null
                                          : IconButton(
                                              icon: FaIcon(
                                                Icons.delete,
                                                size: 16,
                                              ),
                                              onPressed: () => deleteInfluencer(
                                                  _influencerNotifier
                                                      .value[index].id),
                                            ),
                                      leading: CircleAvatar(
                                        radius: 26,
                                        backgroundColor: Colors.black87,
                                        child: _influencerNotifier
                                                .value[index].image.isEmpty
                                            ? ClipRRect(
                                                child: Image.asset(
                                                  "assets/no_image.jpg",
                                                  height: 50,
                                                  width: 50,
                                                  fit: BoxFit.cover,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                              )
                                            : ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                child: Image.network(
                                                  _influencerNotifier
                                                      .value[index].image,
                                                  height: 50,
                                                  width: 50,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                      ),
                                      title: Text(_influencerNotifier
                                          .value[index].igUsername),
                                      subtitle: Text(
                                          "${_influencerNotifier.value[index].firstName} ${_influencerNotifier.value[index].lastName}"),
                                      onTap: () => Navigator.of(context)
                                          .push(PageRouteBuilder(
                                        maintainState: false,
                                        pageBuilder: (BuildContext context,
                                            Animation<double> animation,
                                            Animation<double>
                                                secondaryAnimation) {
                                          return InfluencerDetailsPage(
                                            influencer: _influencerNotifier
                                                .value[index],
                                          );
                                        },
                                        transitionsBuilder:
                                            (BuildContext context,
                                                Animation<double> animation,
                                                Animation<double>
                                                    secondaryAnimation,
                                                Widget child) {
                                          return FadeTransition(
                                            opacity: animation,
                                            child: SlideTransition(
                                              position: new Tween<Offset>(
                                                begin: const Offset(1.0, 0.0),
                                                end: Offset.zero,
                                              ).animate(CurvedAnimation(
                                                  parent: animation,
                                                  curve: Curves.easeIn)),
                                              child: child,
                                            ),
                                          );
                                        },
                                      )),
                                    ),
                                  );
                              })
                        ],
                      ),
                    )
                  ],
                ),
                floatingActionButton: isAdmin
                    ? FloatingActionButton(
                        heroTag: UniqueKey(),
                        mini: true,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        backgroundColor: Colors.black87,
                        child: FaIcon(
                          FontAwesomeIcons.plus,
                          size: 12,
                        ),
                        onPressed: () =>
                            Navigator.of(context).push(PageRouteBuilder(
                              pageBuilder: (BuildContext context,
                                  Animation<double> animation,
                                  Animation<double> secondaryAnimation) {
                                return InfluencerPage();
                              },
                              maintainState: false,
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
              ),
              _loadingNotifier.value
                  ? Container(
                      color: Colors.black38,
                      child: SpinKitPouringHourglass(
                        color: Colors.black87,
                        size: 20,
                      ),
                    )
                  : SizedBox.shrink(),
            ],
          ),
        );
      },
    );
  }
}

class InfluencerSearch extends SearchDelegate<String> {
  InfluencerSearch(this.list, {this.contextPage});

  final BuildContext contextPage;
  final List<Influencer> list;

  @override
  String get searchFieldLabel => "Search for influencer";

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final igUserNameList = list.map((e) => e.igUsername).toList();
    final suggestions = query.isEmpty
        ? igUserNameList
        : igUserNameList
            .where((element) => element
                .trim()
                .toLowerCase()
                .contains(query.trim().toLowerCase()))
            .toList();
    if (suggestions.isEmpty)
      return Center(
        child: Text(
          'No influencer found with \'$query\'',
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w300),
        ),
      );
    else {
      return ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (content, index) => InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => InfluencerDetailsPage(
                influencer: list[list.indexWhere(
                    (element) => element.igUsername == suggestions[index])],
              ),
            ),
          ),
          child: ListTile(
              leading: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Icon(
                  Icons.verified_user,
                  color: Colors.blue[200],
                  size: 14,
                ),
              ),
              title: Text(suggestions[index])),
        ),
      );
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final igUserNameList = list.map((e) => e.igUsername).toList();
    final suggestions = query.isEmpty
        ? igUserNameList
        : igUserNameList
            .where((element) => element
                .trim()
                .toLowerCase()
                .contains(query.trim().toLowerCase()))
            .toList();
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (content, index) => InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => InfluencerDetailsPage(
              influencer: list[list.indexWhere(
                  (element) => element.igUsername == suggestions[index])],
            ),
          ),
        ),
        child: ListTile(
            leading: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Icon(
                Icons.verified_user,
                color: Colors.blue[200],
                size: 14,
              ),
            ),
            title: Text(suggestions[index])),
      ),
    );
  }
}
