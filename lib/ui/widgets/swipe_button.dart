import 'package:flutter/material.dart';

class SwipeButton extends StatefulWidget {
  final String text;
  final Color backgroundColor;
  final Color swipeColor;
  final double height;
  final double width;
  final Function onSwipe;
  final IconData icon;

  const SwipeButton({
    super.key,
    required this.text,
    required this.onSwipe,
    this.backgroundColor = const Color(0xFFEEEEEE),
    this.swipeColor = Colors.blue,
    this.height = 60,
    this.width = 300,
    this.icon = Icons.arrow_forward_ios,
  });

  @override
  State<SwipeButton> createState() => _SwipeButtonState();
}

class _SwipeButtonState extends State<SwipeButton> {
  double _dragPosition = 0.0;
  bool _isCompleted = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (_isCompleted) return;

        setState(() {
          _dragPosition += details.delta.dx;
          _dragPosition = _dragPosition.clamp(0, widget.width - widget.height);
        });
      },
      onHorizontalDragEnd: (details) {
        if (_isCompleted) return;

        if (_dragPosition > widget.width * 0.6) {
          setState(() {
            _dragPosition = widget.width - widget.height;
            _isCompleted = true;
          });
          Future.delayed(const Duration(milliseconds: 300), () {
            widget.onSwipe();
          });
        } else {
          setState(() {
            _dragPosition = 0;
          });
        }
      },
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
       
          Container(
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(widget.height / 2),
            ),
            alignment: Alignment.center,
            child: Text(
              _isCompleted ? "SOS Mode" : widget.text,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

    
          AnimatedPositioned(
            duration: const Duration(milliseconds: 100),
            left: _dragPosition,
            child: Container(
              height: widget.height,
              width: widget.height,
              decoration: BoxDecoration(
                color: widget.swipeColor,
                shape: BoxShape.circle,
              ),
              child: Icon(widget.icon, color: Colors.white, size: 26),
            ),
          ),
        ],
      ),
    );
  }
}
