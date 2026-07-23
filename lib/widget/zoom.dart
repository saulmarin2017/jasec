import 'package:flutter/material.dart';

class ZoomListItem extends StatefulWidget {
  final Widget child;
  const ZoomListItem({super.key, required this.child});

  @override
  State<ZoomListItem> createState() => _ZoomListItemState();
}

class _ZoomListItemState extends State<ZoomListItem> {
  double _scale = 1.0;

  void _zoomIn() {
    setState(() => _scale = 1.1);
  }

  void _zoomOut() {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _zoomIn(),
      onTapUp: (_) => _zoomOut(),
      onTapCancel: _zoomOut,
      onTap: () {
        // Acción al hacer tap si querés
      },
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 200),
        child: widget.child,
      ),
    );
  }
}
