import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:grroom/data/remote_fetch.dart';
import 'package:grroom/features/stylist/pages/stylist_details_page.dart';
import 'package:grroom/features/stylist/pages/stylist_page.dart';
import 'package:grroom/models/stylist.dart';

class HandleStylistPage extends StatefulWidget {
  final List<Stylist> stylists;
  HandleStylistPage({
    Key key,
    this.stylists,
  }) : super(key: key);
  @override
  _HandleStylistPageState createState() => _HandleStylistPageState();
}

class _HandleStylistPageState extends State<HandleStylistPage> {
  final storage = FlutterSecureStorage();
  String token;
  ScrollController _controller;
  final ValueNotifier<int> _pageNotifier = ValueNotifier<int>(1);
  final ValueNotifier<List<Stylist>> _stylistNotifier =
      ValueNotifier<List<Stylist>>([]);
  final ValueNotifier<bool> _loadingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _endListNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    _controller = ScrollController();
    if (widget.stylists == null) {
      _loadFirst20();
      _controller
        ..addListener(() async {
          if (_controller.position.pixels ==
              _controller.position.maxScrollExtent) {
            if (!_endListNotifier.value) {
              await _loadMore();
            }
          }
        });
    } else {
      _loadFirst20FromList();
      _controller
        ..addListener(() async {
          if (_controller.position.pixels ==
              _controller.position.maxScrollExtent) {
            if (!_endListNotifier.value) {
              await _loadMoreFromList();
            }
          }
        });
    }
    super.initState();
  }

  Future _loadFirst20() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final List<Stylist> inf = await RemoteFetch.getAllStylists(
        pageNumber: _pageNotifier.value, limit: 20);
    _stylistNotifier.value.addAll(inf);
    _pageNotifier.value = 4;
    _pageNotifier.value++;
  }

  Future _loadFirst20FromList() async {
    await Future.delayed(const Duration(milliseconds: 100));
    List<Stylist> inf;
    if (widget.stylists.length > 20) {
      inf = widget.stylists.sublist(0, 20);
      _stylistNotifier.value.addAll(inf);
      _pageNotifier.value = 20;
      _pageNotifier.value += 5;
    } else {
      _stylistNotifier.value = widget.stylists;
      _endListNotifier.value = true;
    }
  }

  Future _loadMore() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final List<Stylist> inf = await RemoteFetch.getAllStylists(
        pageNumber: _pageNotifier.value, limit: 5);
    if (inf.isNotEmpty) {
      _stylistNotifier.value.addAll(inf);
      _pageNotifier.value++;
    } else {
      _endListNotifier.value = true;
    }
  }

  Future _loadMoreFromList() async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      final List<Stylist> inf =
          widget.stylists.sublist(_pageNotifier.value, _pageNotifier.value + 20);
      _stylistNotifier.value.addAll(inf);
      _pageNotifier.value += 20;
    } catch (e) {
      final List<Stylist> inf =
          widget.stylists.sublist(_pageNotifier.value, widget.stylists.length);
      _stylistNotifier.value.addAll(inf);
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
    return AnimatedBuilder(
      animation: Listenable.merge([
        _pageNotifier,
        _loadingNotifier,
        _stylistNotifier,
        _endListNotifier
      ]),
      builder: (BuildContext context, Widget child) {
        return SafeArea(
          child: Stack(
            children: [
              Scaffold(
                body: _stylistNotifier.value.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('List is empty'),
                            SizedBox(
                              height: 10,
                            ),
                            (widget.stylists != null && widget.stylists.isEmpty)
                                ? SizedBox.shrink()
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      RaisedButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      StylistPage()));
                                        },
                                        color: Colors.black87,
                                        child: Text(
                                          'Create new meta',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      RaisedButton(
                                        onPressed: () async {
                                          await _loadMore();
                                        },
                                        color: Colors.black87,
                                        child: Text(
                                          'Refresh',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                          ],
                        ),
                      )
                    : CustomScrollView(
                        controller: _controller,
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverAppBar(
                            elevation: 1,
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
                                      delegate: StylistSearch(
                                          _stylistNotifier.value,
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
                                      Icon(
                                        Icons.search,
                                        color: Colors.white54,
                                        size: 16,
                                      ),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        'Search stylists',
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
                                    padding: const EdgeInsets.only(
                                        top: 20, bottom: 100),
                                    physics: const BouncingScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: _endListNotifier.value
                                        ? _stylistNotifier.value.length
                                        : _stylistNotifier.value.length + 1,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      if (index ==
                                          _stylistNotifier.value.length) {
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: CupertinoActivityIndicator(),
                                        );
                                      } else
                                        return InkWell(
                                          child: Card(
                                            elevation: 5,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            shadowColor: Image.asset(
                                                    'assets/designer.jpg')
                                                .color,
                                            child: ListTile(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 10),
                                              onTap: () => Navigator.of(context)
                                                  .push(PageRouteBuilder(
                                                pageBuilder: (BuildContext
                                                        context,
                                                    Animation<double> animation,
                                                    Animation<double>
                                                        secondaryAnimation) {
                                                  return StylistDetailsPage(
                                                    stylist: _stylistNotifier
                                                        .value[index],
                                                  );
                                                },
                                                transitionsBuilder:
                                                    (BuildContext context,
                                                        Animation<double>
                                                            animation,
                                                        Animation<double>
                                                            secondaryAnimation,
                                                        Widget child) {
                                                  return FadeTransition(
                                                    opacity: animation,
                                                    child: SlideTransition(
                                                      position:
                                                          new Tween<Offset>(
                                                        begin: const Offset(
                                                            1.0, 0.0),
                                                        end: Offset.zero,
                                                      ).animate(CurvedAnimation(
                                                              parent: animation,
                                                              curve: Curves
                                                                  .easeIn)),
                                                      child: child,
                                                    ),
                                                  );
                                                },
                                              )),
                                              leading: CircleAvatar(
                                                  radius: 26,
                                                  backgroundColor:
                                                      Colors.black87,
                                                  child: ClipRRect(
                                                    child: CachedNetworkImage(
                                                      imageUrl: _stylistNotifier
                                                          .value[index].image,
                                                      errorWidget: (context,
                                                          url, error) {
                                                        return Image.asset(
                                                            'assets/no_image.jpg');
                                                      },
                                                      height: 50,
                                                      width: 50,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100),
                                                  )),
                                              title: Text(_stylistNotifier
                                                  .value[index].id),
                                              subtitle: _stylistNotifier
                                                          .value[index].place ==
                                                      ''
                                                  ? null
                                                  : Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        FaIcon(
                                                          FontAwesomeIcons
                                                              .locationArrow,
                                                          size: 12,
                                                          color: _stylistNotifier
                                                                      .value[
                                                                          index]
                                                                      .place ==
                                                                  null
                                                              ? Colors.white
                                                              : Colors.black26,
                                                        ),
                                                        SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(_stylistNotifier
                                                            .value[index]
                                                            .place),
                                                      ],
                                                    ),
                                            ),
                                          ),
                                        );
                                    })
                              ],
                            ),
                          )
                        ],
                      ),
                floatingActionButton: FloatingActionButton(
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
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => StylistPage(),
                        ))),
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

class StylistSearch extends SearchDelegate<String> {
  StylistSearch(this.list, {this.contextPage});

  final BuildContext contextPage;
  final List<Stylist> list;

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
    final igUserNameList = list.map((e) => e.influencerId).toList();
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
          'No stylist found with \'$query\'',
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w300),
        ),
      );
    else {
      return ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (content, index) => InkWell(
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
    final igUserNameList = list.map((e) => e.id).toList();
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
