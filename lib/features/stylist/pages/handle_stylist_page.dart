import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grroom/data/remote_fetch.dart';
import 'package:grroom/features/stylist/pages/stylist_page.dart';
import 'package:grroom/features/stylist/widgets/stylist_card.dart';
import 'package:grroom/models/stylist.dart';

const int kStylistLimit = 25;

class HandleStylistPage extends StatefulWidget {
  final String userId;

  const HandleStylistPage({
    Key key,
    this.userId,
  }) : super(key: key);
  @override
  _HandleStylistPageState createState() => _HandleStylistPageState();
}

class _HandleStylistPageState extends State<HandleStylistPage> {
  final storage = FlutterSecureStorage();
  String token;
  final ValueNotifier<int> _pageNotifier = ValueNotifier<int>(1);
  final ValueNotifier<int> _lengthNotifier = ValueNotifier<int>(0);
  final ValueNotifier<List<Stylist>> _stylistNotifier =
      ValueNotifier<List<Stylist>>([]);
  final ValueNotifier<bool> _loadingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _endListNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    _loadFirst100();
    super.initState();
  }

  Future _loadFirst100() async {
    _pageNotifier.value = 1;
    _loadingNotifier.value = true;
    _stylistNotifier.value = [];
    _lengthNotifier.value = await RemoteFetch.getStylistCount();

    await Future.delayed(const Duration(milliseconds: 100));
    final List<Stylist> inf = await RemoteFetch.getAllStylists(
        pageNumber: _pageNotifier.value, limit: kStylistLimit);
    _stylistNotifier.value.addAll(inf);
    _loadingNotifier.value = false;
  }

  Future _loadMore() async {
    _loadingNotifier.value = true;
    _stylistNotifier.value = [];
    await Future.delayed(const Duration(milliseconds: 100));
    final List<Stylist> inf = await RemoteFetch.getAllStylists(
        pageNumber: _pageNotifier.value, limit: kStylistLimit);
    if (inf.isNotEmpty) {
      _stylistNotifier.value.addAll(inf);
    } else {
      print('end of list');
      _endListNotifier.value = true;
    }
    _loadingNotifier.value = false;
  }

  Future _loadPrev() async {
    _loadingNotifier.value = true;
    _stylistNotifier.value = [];
    await Future.delayed(const Duration(milliseconds: 100));
    final List<Stylist> inf = await RemoteFetch.getAllStylists(
        pageNumber: _pageNotifier.value, limit: kStylistLimit);
    if (inf.isNotEmpty) {
      _stylistNotifier.value.addAll(inf);
    } else {
      print('end of list');
      _endListNotifier.value = true;
    }
    _loadingNotifier.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _pageNotifier,
        _loadingNotifier,
        _stylistNotifier,
        _endListNotifier,
        _lengthNotifier
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
                            (widget.userId != null)
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
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          _appBar(context),
                          SliverList(
                            delegate: SliverChildListDelegate(
                              [
                                ListView.builder(
                                    padding: const EdgeInsets.only(
                                        top: 20, bottom: 100),
                                    physics: const BouncingScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount:
                                        _stylistNotifier.value.length + 1,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      if (index == 0) {
                                        return pageNumberWidget();
                                      } else {
                                        return StylistCard(
                                          stylistNotifier: _stylistNotifier,
                                          index: index - 1,
                                          loadingNotifier: _loadingNotifier,
                                        );
                                      }
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

  SliverAppBar _appBar(BuildContext context) {
    return SliverAppBar(
      elevation: 1,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      stretch: true,
      floating: true,
      expandedHeight: 60,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: null,
        background: Container(
          height: 40,
          alignment: Alignment.center,
          width: double.maxFinite,
          decoration: const BoxDecoration(
            color: Colors.black87,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
        stretchModes: [
          StretchMode.zoomBackground,
        ],
      ),
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
