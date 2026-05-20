import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';

class BodyWidget extends StatefulWidget {
  final Widget body;
  final AppBarWidget? appBar;
  final bool isFromHomeScreen;
  final double topMargin;
  /// When true, body fills the area under the app bar (no grey rounded shell).
  final bool fullBleed;
  const BodyWidget(
      {super.key,
      required this.body,
      this.appBar,
      this.topMargin = 10,
      this.isFromHomeScreen = false,
      this.fullBleed = false});

  @override
  State<BodyWidget> createState() => _BodyWidgetState();
}

class _BodyWidgetState extends State<BodyWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      widget.isFromHomeScreen
          ? SizedBox.shrink()
          : widget.appBar ?? SizedBox.shrink(),
      Expanded(
          child: widget.fullBleed
              ? widget.body
              : Container(
                  margin: EdgeInsets.only(top: widget.topMargin),
                  width: Dimensions.webMaxWidth,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(25),
                      topLeft: Radius.circular(25),
                    ),
                    color: Color.fromARGB(255, 246, 248, 248),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(25),
                        topLeft: Radius.circular(25)),
                    child: widget.body,
                  ),
                )),
    ]);
  }
}
