import 'package:flutter/material.dart';

class BrandDivider extends StatelessWidget {
  final double indent;
  final double endIndent;

  const BrandDivider({
    this.indent = 0.0,
    this.endIndent = 0.0,
    Key key,
  }) : super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) {
    return Divider(
      height: 32.0,
      color: Color(0xFFe2e2e2),
      thickness: 1.0,
      endIndent: endIndent,
      indent: indent,
    );
  }
}
