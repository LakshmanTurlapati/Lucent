import 'package:flutter/material.dart';
import 'dart:ui';

class GolfWidget extends StatefulWidget {
  const GolfWidget({super.key});

  @override
  State<GolfWidget> createState() => _GolfWidgetState();
}

class _GolfWidgetState extends State<GolfWidget> {
  // Flag to show tooltip
  bool _showTooltip = false;

  @override
  Widget build(BuildContext context) {
    // Define gold color and variations
    const Color goldColor = Color(0xFFD4AF37);
    final Color goldAccent = goldColor.withOpacity(0.7);
    const Color goldLight = Color(0xFFF5E7A0);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;
        final double availableHeight = constraints.maxHeight;
        
        // Calculate responsive sizes
        final double titleSize = 16.0;
        final double iconSize = availableWidth * 0.25; // Slightly larger single icon
        final double buttonHeight = 40.0;
        final double buttonWidth = availableWidth * 0.65;
        
        return Container(
          decoration: BoxDecoration(
            // Rich dark background
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF212121),
                const Color(0xFF1A1A1A),
              ],
            ),
            // Gold border
            border: Border.all(
              color: goldColor,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Stack(
            children: [
              // Main content - moved to bottom of stack (lower z-index)
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title aligned to the left
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Golf Connect',
                        style: TextStyle(
                          color: goldColor,
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    // Spacer
                    SizedBox(height: availableHeight * 0.12),
                    
                    // Only golf course icon - no sports_golf icon
                    Icon(
                      Icons.golf_course,  // Only golf course icon
                      color: goldColor,
                      size: iconSize,
                    ),
                    
                    // Spacer
                    SizedBox(height: availableHeight * 0.12),
                    
                    // Connection button
                    Container(
                      width: buttonWidth,
                      height: buttonHeight,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [goldColor, Color(0xFFAA8C2C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(buttonHeight / 2),
                        boxShadow: [
                          BoxShadow(
                            color: goldColor.withOpacity(0.3),
                            blurRadius: 8.0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: MaterialButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(buttonHeight / 2),
                        ),
                        onPressed: () {
                          // Connect to golf apps functionality here
                        },
                        child: const Text(
                          'Connect',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Info icon in top right corner with proper padding - higher z-index than content
              Positioned(
                top: 16.0,
                right: 16.0,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _showTooltip = !_showTooltip;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: goldColor, width: 1.0),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: goldColor,
                      size: 14.0,
                    ),
                  ),
                ),
              ),
              
              // Tooltip content with internal blur effect - highest z-index
              if (_showTooltip)
                Positioned(
                  top: 46.0,
                  right: 16.0,
                  child: Material(
                    elevation: 16.0, // Add elevation for higher visual z-index
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        width: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: goldColor.withOpacity(0.7), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: goldColor.withOpacity(0.2),
                              blurRadius: 5.0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Solid background to ensure opacity
                            Positioned.fill(
                              child: Container(
                                color: Colors.black.withOpacity(0.95),
                              ),
                            ),
                            
                            // Blurred background inside the container
                            Positioned.fill(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                                child: Container(
                                  color: Colors.black.withOpacity(0.85),
                                ),
                              ),
                            ),
                            
                            // Glass-like overlay with higher opacity
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withOpacity(0.15),
                                      Colors.black.withOpacity(0.5),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            
                            // Content
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Click to connect to:',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    '• 18Birdies\n• Hole19\n• GolfNow',
                                    style: TextStyle(
                                      color: goldLight,
                                      fontSize: 10.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
} 