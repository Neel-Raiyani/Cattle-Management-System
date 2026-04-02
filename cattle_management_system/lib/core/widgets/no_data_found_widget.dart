import 'package:flutter/material.dart';
import '../localization/localized_ui.dart';

class NoDataFoundWidget extends StatelessWidget {
  final double imageWidth;
  final double imageHeight;

  const NoDataFoundWidget({
    super.key,
    this.imageWidth = 175,
    this.imageHeight = 175,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:EdgeInsets.only(bottom: 80),
        child: Image.asset(
          context.ui.noDataFoundImage,
          width: imageWidth,
          height: imageHeight,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
