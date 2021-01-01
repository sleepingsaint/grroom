import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grroom/data/remote_fetch.dart';
import 'package:grroom/features/influencer/widgets/influencer_card.dart';
import 'package:grroom/main.dart';
import 'package:grroom/models/influencer.dart';

import 'influencer_details_page.dart';
import 'influencer_page.dart';

const int kInfluencerLimit = 25;

class HandleInfluencersPage extends StatefulWidget {
  const HandleInfluencersPage({Key key}) : super(key: key);
  @override
  _HandleInfluencersPageState createState() => _HandleInfluencersPageState();
}

class _HandleInfluencersPageState extends State<HandleInfluencersPage> {
  ScrollController _controller;
  final ValueNotifier<int> _pageNotifier = ValueNotifier<int>(1);
  final ValueNotifier<int> _lengthNotifier = ValueNotifier<int>(0);
  final ValueNotifier<List<Influencer>> _influencerNotifier =
      ValueNotifier<List<Influencer>>([]);
  final ValueNotifier<bool> _loadingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _endListNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _adminNotifier = ValueNotifier<bool>(false);
  @override
  void initState() {
    _loadFirst100();
    FlutterSecureStorage().read(key: 'role').then((value) {
      _adminNotifier.value = value == 'admin';
    });
    super.initState();
  }

  Future _loadFirst100() async {
    _loadingNotifier.value = true;
    _pageNotifier.value = 1;
    _influencerNotifier.value = [];
    _lengthNotifier.value = await RemoteFetch.getInfluencersCount();

    await Future.delayed(const Duration(milliseconds: 100));
    final List<Influencer> inf = await RemoteFetch.getAllInfluencers(
        pageNumber: _pageNotifier.value, limit: kInfluencerLimit);
    _influencerNotifier.value.addAll(inf);
    _loadingNotifier.value = false;
  }

  Future _loadMore() async {
    _loadingNotifier.value = true;
    _influencerNotifier.value = [];
    await Future.delayed(const Duration(milliseconds: 100));
    final List<Influencer> inf = await RemoteFetch.getAllInfluencers(
        pageNumber: _pageNotifier.value, limit: kInfluencerLimit);
    if (inf.isNotEmpty) {
      _influencerNotifier.value.addAll(inf);
    } else {
      print('end of list');
      _endListNotifier.value = true;
    }
    _loadingNotifier.value = false;
  }

  Future _loadPrev() async {
    _loadingNotifier.value = true;
    _influencerNotifier.value = [];
    await Future.delayed(const Duration(milliseconds: 100));
    final List<Influencer> inf = await RemoteFetch.getAllInfluencers(
        pageNumber: _pageNotifier.value, limit: kInfluencerLimit);
    if (inf.isNotEmpty) {
      _influencerNotifier.value.addAll(inf);
    } else {
      print('end of list');
      _endListNotifier.value = true;
    }
    _loadingNotifier.value = false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _pageNotifier,
        _loadingNotifier,
        _influencerNotifier,
        _endListNotifier,
        _lengthNotifier,
        _adminNotifier
      ]),
      builder: (BuildContext context, Widget child) {
        return SafeArea(
          child: Stack(
            children: [
              Scaffold(
                body: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    _appbar(context),
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          ListView.builder(
                              padding:
                                  const EdgeInsets.only(top: 20, bottom: 100),
                              physics: const BouncingScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: _influencerNotifier.value.length + 1,
                              itemBuilder: (BuildContext context, int index) {
                                if (index == 0) {
                                  return pageNumberWidget();
                                } else
                                  return InfluencerCard(
                                    isAdmin: _adminNotifier.value,
                                    index: index - 1,
                                    influencerNotifier: _influencerNotifier,
                                    loadingNotifier: _loadingNotifier,
                                  );
                              })
                        ],
                      ),
                    )
                  ],
                ),
                floatingActionButton: _adminNotifier.value
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

  Widget pageNumberWidget() {
    String _count = "";
    if (_lengthNotifier.value > 25) {
      if (_pageNotifier.value * 25 > _lengthNotifier.value) {
        _count = "${_lengthNotifier.value}/${_lengthNotifier.value}";
      } else {
        _count = "${_pageNotifier.value * 25}/${_lengthNotifier.value}";
      }
    } else {
      _count = "${_pageNotifier.value}/${_lengthNotifier.value}";
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _pageNotifier.value <= 1
            ? IconButton(
                icon: Icon(
                  Icons.skip_previous,
                  color: Colors.transparent,
                ),
                onPressed: null,
              )
            : IconButton(
                icon: Icon(
                  Icons.skip_previous,
                  color: Colors.black,
                ),
                onPressed: () async {
                  _pageNotifier.value--;
                  await _loadPrev();
                },
              ),
        Chip(
          labelPadding: const EdgeInsets.symmetric(horizontal: 10),
          label: Text(
            _count,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black87,
        ),
        _pageNotifier.value * 25 >= _lengthNotifier.value
            ? IconButton(
                icon: Icon(
                  Icons.skip_previous,
                  color: Colors.transparent,
                ),
                onPressed: null,
              )
            : IconButton(
                icon: Icon(
                  Icons.skip_next,
                  color: Colors.black,
                ),
                onPressed: () async {
                  _pageNotifier.value++;
                  await _loadMore();
                },
              ),
      ],
    );
  }

  SliverAppBar _appbar(BuildContext context) {
    return SliverAppBar(
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
                        .copyWith(fontWeight: FontWeight.bold, fontSize: 15),
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
                        await FlutterSecureStorage().delete(key: 'token');
                        await FlutterSecureStorage().delete(key: 'role');
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
                delegate: InfluencerSearch(_influencerNotifier.value,
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
                    await _loadFirst100();
                    _loadingNotifier.value = false;
                  },
                )
              ],
            ),
          ),
        ),
        stretchModes: [StretchMode.fadeTitle],
      ),
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
