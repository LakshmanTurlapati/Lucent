import 'package:flutter/material.dart';
import 'placeholder_card.dart';

class LeftContentColumn extends StatelessWidget {
  // Use consistent styling from other widgets
  final Color placeholderColor = const Color(0xFF3A3A3C);
  final BorderRadius placeholderBorderRadius = const BorderRadius.all(Radius.circular(16.0));
  final double placeholderSpacing = 20.0;

  const LeftContentColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PlaceholderCard(
          height: 200.0,
          color: placeholderColor,
          borderRadius: placeholderBorderRadius,
        ),
        SizedBox(height: placeholderSpacing),
        PlaceholderCard(
          height: 200.0,
          color: placeholderColor,
          borderRadius: placeholderBorderRadius,
        ),
        SizedBox(height: placeholderSpacing),
        // Use Expanded for the last one to ensure it fits within available space
        // If fixed height 400 is strictly required and might overflow, 
        // the parent layout needs careful handling (e.g. SingleChildScrollView)
        // Using Expanded is generally safer for varying screen sizes.
        Expanded(
          child: PlaceholderCard(
            // Let the Expanded widget determine the height
            height: double.infinity, // PlaceholderCard needs a height, use infinity with Expanded
            color: placeholderColor,
            borderRadius: placeholderBorderRadius,
          ),
        ),
        // Or, if fixed height 400 is essential:
        // PlaceholderCard(
        //   height: 400.0, 
        //   color: placeholderColor,
        //   borderRadius: placeholderBorderRadius,
        // ),
      ],
    );
  }
} 