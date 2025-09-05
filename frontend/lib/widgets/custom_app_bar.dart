import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final Widget? leading;
  final double? elevation;
  final Color? backgroundColor;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.leading,
    this.elevation,
    this.backgroundColor,
    this.centerTitle = true,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo that adapts to theme
          Image.asset(
            isDarkMode
                ? 'assets/logo/logo_white.png'
                : 'assets/logo/logo_black.png',
            height: 32,
            fit: BoxFit.contain,
          ),
          if (title != null) ...[
            const SizedBox(width: 12),
            Text(title!),
          ],
        ],
      ),
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      elevation: elevation,
      backgroundColor: backgroundColor,
      centerTitle: centerTitle,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );
}

/// A variant of CustomAppBar that only shows the logo without any title text
class LogoOnlyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final Widget? leading;
  final double? elevation;
  final Color? backgroundColor;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;

  const LogoOnlyAppBar({
    super.key,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.leading,
    this.elevation,
    this.backgroundColor,
    this.centerTitle = true,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      title: Image.asset(
        isDarkMode
            ? 'assets/logo/logo_white.png'
            : 'assets/logo/logo_black.png',
        height: 36,
        fit: BoxFit.contain,
      ),
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      elevation: elevation,
      backgroundColor: backgroundColor,
      centerTitle: centerTitle,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );
}
