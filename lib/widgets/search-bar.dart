import 'package:flutter/material.dart';

class SearchProductBar extends StatelessWidget {
  const SearchProductBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white
            .withOpacity(0.1), // Light background for the search bar
        borderRadius: BorderRadius.circular(20), // Rounded corners
      ),
      child: Row(
        children: [
          // Search Icon
          const Icon(
            Icons.search, // Flutter's search icon
            color: Colors.white, // Yellow color for the icon
            size: 24,
          ),
          const SizedBox(width: 8), // Spacing between icon and text field
          // Text Input Field
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Perfumes', // Placeholder text
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.7), // Light text color
                  fontSize: 16,
                ),
                border: InputBorder.none, // Remove the default underline
              ),
              style: const TextStyle(
                color: Colors.white, // Text color
                fontSize: 16,
              ),
              cursorColor: const Color(0xFFF5D57A), // Yellow cursor color
            ),
          ),
        ],
      ),
    );
  }
}
