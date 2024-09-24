import 'package:flutter/material.dart';

class IconOnlyNavigation extends StatelessWidget {
  final Icon icon;
  final Icon selectedIcon;
  final bool isSelected;
  final void Function()? onTap;

  const IconOnlyNavigation({
    Key? key,
    required this.icon,
    required this.selectedIcon,
    this.isSelected = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: isSelected ? selectedIcon : icon,
      ),
    );
  }
}
