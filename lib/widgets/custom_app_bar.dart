import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final bool centerTitle;
  final bool isLight;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.centerTitle = false,
    this.isLight = false,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
  }) : assert(title != null || titleWidget != null);

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor =
        textColor ?? (isLight ? Colors.black87 : Colors.white);
    final effectiveIconColor =
        iconColor ?? (isLight ? Colors.black87 : Colors.white);
    final effectiveBgColor =
        backgroundColor ?? (isLight ? Colors.white : Colors.transparent);

    return AppBar(
      title:
          titleWidget ??
          Text(
            title!,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              color: effectiveTextColor,
              fontSize: 20, // Reduced from 24 for more modern feel
            ),
          ),
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: effectiveBgColor,
      elevation: 0,
      centerTitle: centerTitle,
      flexibleSpace: isLight ? null : _buildAbstractBackground(),
      actions: actions,
      iconTheme: IconThemeData(color: effectiveIconColor),
      bottom:
          isLight
              ? PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.shade100,
                ),
              )
              : null,
    );
  }

  Widget _buildAbstractBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade700, Colors.indigo.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -20,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 100,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(isLight ? kToolbarHeight + 1 : kToolbarHeight);
}
