import 'package:flutter/material.dart';

// Basic circular loading spinner
class LoadingSpinner extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;

  const LoadingSpinner({
    Key? key,
    this.size = 40.0,
    this.color = Colors.blue,
    this.strokeWidth = 4.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

// Full screen loading overlay
class LoadingOverlay extends StatelessWidget {
  final Color spinnerColor;
  final double size;

  const LoadingOverlay({
    Key? key,
    this.spinnerColor = Colors.blue,
    this.size = 48.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 4.0,
          valueColor: AlwaysStoppedAnimation<Color>(spinnerColor),
        ),
      ),
    );
  }
}

// Loading button widget
class LoadingButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;

  const LoadingButton({
    Key? key,
    required this.text,
    this.isLoading = false,
    this.onPressed,
    this.backgroundColor = Colors.blue,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: isLoading
          ? Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16.0,
            height: 16.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          ),
          const SizedBox(width: 8.0),
          Text(text),
        ],
      )
          : Text(text),
    );
  }
}

// Demo page showing different loading states
