import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Rounded pill dropdown used for Region / Duration / Difficulty filters.
/// Turns turquoise when an active (non-default) value is selected.
class FilterPill extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const FilterPill({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // First item in each list is the "default/unset" label.
    final isActive = value != items.first;

    return Expanded(
      child: PopupMenuButton<String>(
        onSelected: onChanged,
        position: PopupMenuPosition.under,
        color: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        itemBuilder: (_) => items
            .map((item) => PopupMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(
                      color: item == value ? AppColors.brand : AppColors.dark,
                      fontWeight:
                          item == value ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ))
            .toList(),
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.brand : AppColors.fieldFill,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : AppColors.dark,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Icon(Icons.keyboard_arrow_down,
                  size: 18,
                  color: isActive ? Colors.white : AppColors.textGrey),
            ],
          ),
        ),
      ),
    );
  }
}
