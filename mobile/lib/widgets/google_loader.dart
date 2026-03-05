import 'package:flutter/material.dart';

class GoogleLoader extends StatelessWidget {
  final double size;
  final Color? color;

  const GoogleLoader({
    super.key,
    this.size = 40.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? Theme.of(context).primaryColor;
    
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 3.0,
          strokeCap: StrokeCap.round,
          valueColor: AlwaysStoppedAnimation<Color>(themeColor),
          backgroundColor: themeColor.withOpacity(0.1),
        ),
      ),
    );
  }
}
