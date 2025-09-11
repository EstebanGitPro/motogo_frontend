import 'package:flutter/material.dart';

class CustomButtonWidget extends StatefulWidget {
  const CustomButtonWidget({
    super.key,
    required this.onPressed,
    required this.title,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.borderRadius = 16.0,
    this.elevation = 2.0,
    this.minimumSize,
    this.padding,
    this.loadingIndicatorColor,
    this.loadingIndicatorSize = 24.0,
    this.loadingStrokeWidth = 2.5,
    this.icon,
    this.iconSpacing = 8.0,
    this.fontSize,
    this.fontWeight,
    this.borderSide,
    this.shadowColor,
    this.splashColor,
    this.highlightColor,
  });

  final VoidCallback? onPressed;
  final String title;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? disabledBackgroundColor;
  final Color? disabledForegroundColor;
  final double borderRadius;
  final double elevation;
  final Size? minimumSize;
  final EdgeInsets? padding;
  final Color? loadingIndicatorColor;
  final double loadingIndicatorSize;
  final double loadingStrokeWidth;
  final Widget? icon;
  final double iconSpacing;
  final double? fontSize;
  final FontWeight? fontWeight;
  final BorderSide? borderSide;
  final Color? shadowColor;
  final Color? splashColor;
  final Color? highlightColor;

  @override
  State<CustomButtonWidget> createState() => _CustomButtonWidgetState();
}

class _CustomButtonWidgetState extends State<CustomButtonWidget> {
  bool _isProcessing = false;

  void _handlePressed() async {
    if (_isProcessing || widget.isLoading || widget.onPressed == null) return;

    setState(() {
      _isProcessing = true;
    });

    // Ejecutar la función
    widget.onPressed!();

    // Esperar un poco antes de permitir otro clic
    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled =
        widget.isLoading || _isProcessing || widget.onPressed == null;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.backgroundColor ?? Colors.blue[600],
        foregroundColor: widget.foregroundColor ?? Colors.white,
        disabledBackgroundColor:
            widget.disabledBackgroundColor ?? Colors.grey[300],
        disabledForegroundColor:
            widget.disabledForegroundColor ?? Colors.grey[600],
        minimumSize: widget.minimumSize ?? const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          side: widget.borderSide ?? BorderSide.none,
        ),
        elevation: widget.elevation,
        shadowColor:
            widget.shadowColor ??
            widget.backgroundColor?.withAlpha(75) ??
            Colors.blue[600]!.withAlpha(75),
        padding: widget.padding ?? const EdgeInsets.symmetric(vertical: 16),
        splashFactory: InkRipple.splashFactory,
      ),
      onPressed: isDisabled ? null : _handlePressed,
      child: _buildButtonContent(),
    );
  }

  Widget _buildButtonContent() {
    if (widget.isLoading || _isProcessing) {
      return SizedBox(
        height: widget.loadingIndicatorSize,
        width: widget.loadingIndicatorSize,
        child: CircularProgressIndicator(
          strokeWidth: widget.loadingStrokeWidth,
          color:
              widget.loadingIndicatorColor ??
              widget.foregroundColor ??
              Colors.white,
        ),
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.icon!,
          SizedBox(width: widget.iconSpacing),
          Text(
            widget.title,
            style: TextStyle(
              fontSize: widget.fontSize,
              fontWeight: widget.fontWeight,
            ),
          ),
        ],
      );
    }

    return Text(
      widget.title,
      style: TextStyle(
        fontSize: widget.fontSize,
        fontWeight: widget.fontWeight,
      ),
    );
  }
}
