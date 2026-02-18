import 'package:flutter/material.dart';

/// A reusable widget that provides a responsive, centered layout scaffold.
///
/// Encapsulates the common pattern of:
/// `SafeArea → LayoutBuilder → SingleChildScrollView → ConstrainedBox(minHeight)
///  → IntrinsicHeight → Center → ConstrainedBox(maxWidth)`
///
/// Used by verification pages, registration pages, and other centered-content
/// screens to avoid duplicating the responsive layout boilerplate.
class ResponsiveScaffoldBody extends StatelessWidget {
  /// The content to display inside the responsive layout.
  final Widget child;

  /// Maximum width for the content on tablet/desktop. Defaults to 600.
  final double maxWidth;

  /// Optional padding around the child.
  final EdgeInsetsGeometry? padding;

  const ResponsiveScaffoldBody({
    super.key,
    required this.child,
    this.maxWidth = 600,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: padding != null
                        ? Padding(padding: padding!, child: child)
                        : child,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
