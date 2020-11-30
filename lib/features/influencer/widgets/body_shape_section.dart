import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:grroom/utils/all_provider.dart';
import 'package:provider/provider.dart';

class BodyShapeSection extends StatefulWidget {
  final List<Map<String, dynamic>> bodyShape;
  final String gender;
  const BodyShapeSection({Key key, this.bodyShape, this.gender})
      : super(key: key);
  @override
  _BodyShapeSectionState createState() => _BodyShapeSectionState();
}

class _BodyShapeSectionState extends State<BodyShapeSection> {
  bool isExpanded = false;
  String selectedGender;
  String selectedFirstShape = '';
  String selectedSecondShape = '';
  List<Map<String, dynamic>> bodyShape = [];

  @override
  void initState() {
    if (widget.bodyShape != null && widget.gender != null) {
      if (widget.gender != 'Others') {
        selectedGender = widget.bodyShape[0]["gender"];
        selectedFirstShape = widget.bodyShape[0]["shape"];
        bodyShape = [
          {
            "gender": selectedGender,
            "shape": selectedFirstShape,
          },
          {}
        ];
      } else {
        selectedGender = "Others";
        selectedFirstShape = widget.bodyShape[0]["shape"];
        selectedSecondShape = widget.bodyShape[1]["shape"];
        bodyShape = [
          {
            "gender": widget.bodyShape[0]["gender"],
            "shape": selectedFirstShape,
          },
          {
            "gender": widget.bodyShape[1]["gender"],
            "shape": selectedSecondShape,
          },
        ];
      }

      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        Provider.of<AllProvider>(context, listen: false)
            .updateBodyShape(bodyShape);
      });
    } else {}

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<String>> _styleOptions = {};
    Provider.of<AllProvider>(context).baseBodyShape.forEach((key, value) {
      List<String> list = [];

      value.forEach((e) {
        list.add(e);
      });
      _styleOptions[key] = list;
    });
    List<Widget> genderSelection() {
      return [
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Divider(
                    endIndent: 10,
                  ),
                ),
                Text(
                  'Male',
                  style: TextStyle(
                      color: Colors.black54, fontWeight: FontWeight.w200),
                ),
                Expanded(
                  child: Divider(
                    indent: 10,
                    color: Colors.black12,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            GridView.count(
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20)
                  .copyWith(bottom: 20),
              crossAxisSpacing: 20,
              childAspectRatio: 2.5,
              children: _styleOptions['male']
                  .map((e) => GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedFirstShape = e;

                            bodyShape = [
                              {
                                "gender": "male",
                                "shape": selectedFirstShape,
                              },
                              {
                                "gender": "female",
                                "shape": selectedSecondShape,
                              },
                            ];
                            Provider.of<AllProvider>(context, listen: false)
                                .updateBodyShape(bodyShape);
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            e,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: selectedFirstShape == e
                                  ? Colors.white
                                  : Colors.black54,
                            ),
                          ),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1, color: Colors.black12),
                              color: selectedFirstShape == e
                                  ? Colors.black87
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(2)),
                        ),
                      ))
                  .toList(),
            ),
            Row(
              children: [
                Expanded(
                  child: Divider(
                    endIndent: 10,
                  ),
                ),
                Text(
                  'Female',
                  style: TextStyle(
                      color: Colors.black54, fontWeight: FontWeight.w200),
                ),
                Expanded(
                  child: Divider(
                    indent: 10,
                    color: Colors.black12,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            GridView.count(
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20)
                  .copyWith(bottom: 20),
              crossAxisSpacing: 20,
              childAspectRatio: 2.5,
              children: _styleOptions['female']
                  .map((e) => GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedSecondShape = e;

                            bodyShape = [
                              {
                                "gender": "male",
                                "shape": selectedFirstShape,
                              },
                              {
                                "gender": "female",
                                "shape": selectedSecondShape,
                              },
                            ];
                            Provider.of<AllProvider>(context, listen: false)
                                .updateBodyShape(bodyShape);

                            print(
                                Provider.of<AllProvider>(context, listen: false)
                                    .bodyShape);
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            e,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: selectedSecondShape == e
                                  ? Colors.white
                                  : Colors.black54,
                            ),
                          ),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1, color: Colors.black12),
                              color: selectedSecondShape == e
                                  ? Colors.black87
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(2)),
                        ),
                      ))
                  .toList(),
            ),
          ],
        )
      ];
    }

    List<Widget> children() {
      return _styleOptions[selectedGender.toLowerCase()]
          .map((e) => GestureDetector(
                onTap: () {
                  setState(() {
                    selectedFirstShape = e;

                    bodyShape = [
                      {
                        "gender": selectedGender,
                        "shape": selectedFirstShape,
                      },
                      {}
                    ];
                    Provider.of<AllProvider>(context, listen: false)
                        .updateBodyShape(bodyShape);
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    e,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: selectedFirstShape == e
                          ? Colors.white
                          : Colors.black54,
                    ),
                  ),
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.black12),
                      color: selectedFirstShape == e
                          ? Colors.black87
                          : Colors.white,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ))
          .cast<Widget>()
          .toList();
    }

    return Consumer<AllProvider>(
      builder: (context, provider, child) {
        selectedGender = provider.gender;
        if (selectedGender == "Others") {
          selectedFirstShape = provider.bodyShape[0]["shape"];
          selectedSecondShape = provider.bodyShape[1]["shape"];
        } else {
          selectedFirstShape = provider.bodyShape[0]["shape"] ?? '';
          selectedSecondShape = provider.bodyShape[1]["shape"] ?? '';
        }
        return Card(
          shape: RoundedRectangleBorder(
              borderRadius: isExpanded
                  ? BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    )
                  : BorderRadius.zero),
          child: ExpansionTileCard(
            onExpansionChanged: (value) {
              setState(() {
                isExpanded = value;
              });
            },
            animateTrailing: selectedGender == null,
            trailing: selectedGender == null
                ? Icon(Icons.arrow_drop_down)
                : Text(
                    '$selectedGender',
                    style: TextStyle(
                        color: Colors.black54, fontWeight: FontWeight.w300),
                  ),
            baseColor: Colors.white,
            expandedColor: Colors.white,
            elevation: 0,
            title: Text(
              'Body Shape',
              style: TextStyle(fontSize: 14),
            ),
            children: selectedGender == 'Others'
                ? genderSelection()
                : [
                    selectedGender == null
                        ? SizedBox(height: 0)
                        : GridView.count(
                            physics: NeverScrollableScrollPhysics(),
                            crossAxisCount: 3,
                            mainAxisSpacing: 10,
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(horizontal: 20)
                                .copyWith(bottom: 20),
                            crossAxisSpacing: 20,
                            childAspectRatio: 2.5,
                            children: children(),
                          ),
                  ],
          ),
        );
      },
    );
  }
}
