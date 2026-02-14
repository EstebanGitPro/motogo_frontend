import 'package:flutter/material.dart';

/// A reusable navigation drawer with a customizable header and menu items.
///
/// The [header] widget is placed at the top (typically a [DrawerHeader]).
/// The [menuItems] list defines the drawer content below the header.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.header, required this.menuItems});

  /// The header widget displayed at the top of the drawer.
  final Widget header;

  /// The list of widgets (typically [ListTile], [Divider]) to display.
  final List<Widget> menuItems;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[header, ...menuItems],
      ),
    );
  }
}

/// Standard drawer header with blue gradient, icon, and title.
///
/// Provides a consistent look across all home pages.
class AppDrawerHeader extends StatelessWidget {
  const AppDrawerHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.blueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(icon, size: 60, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
        ],
      ),
    );
  }
}
