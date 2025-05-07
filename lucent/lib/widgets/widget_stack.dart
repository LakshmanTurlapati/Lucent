import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'music_player_widget.dart';
import 'vehicle_controls_widget.dart';
import 'golf_widget.dart';

class WidgetStack extends StatefulWidget {
  const WidgetStack({super.key});

  @override
  State<WidgetStack> createState() => _WidgetStackState();
}

class _WidgetStackState extends State<WidgetStack> with SingleTickerProviderStateMixin {
  // Animation controller for managing transitions
  late AnimationController _controller;
  late Animation<double> _animation;
  
  // Current card index in the stack
  int _currentIndex = 0;
  
  // Tracks drag offset for manual swiping
  double _dragOffset = 0.0;
  
  // Whether we're currently in a drag operation
  bool _isDragging = false;
  
  // Whether we're currently animating
  bool _isAnimating = false;
  
  // List of widgets to display in the stack
  final List<Widget> _stackItems = [
    // Music player is the first card (will be on top)
    const MusicPlayerWidget(),
    
    // Vehicle controls widget
    const VehicleControlsWidget(),
    
    // Golf widget
    const GolfWidget(),
    
    // Navigation widget (placeholder)
    _buildPlaceholderCard(
      "Navigation",
      Icons.navigation,
      const Color(0xFF1F7A8C), // Teal
      "Home → UTD",
      "15 minutes - 5.2 miles",
    ),
  ];

  // Define colors and styling
  final Color backgroundColor = const Color(0xFF171717);
  final BorderRadius cornerRadius = BorderRadius.circular(16.0);
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    
    _controller.addListener(() {
      if (_controller.isCompleted) {
        _isAnimating = false;
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;
        
        // We want the stack to overflow outside its bounds, so we don't use a Container
        // that might clip its contents. Instead, use a plain Stack with Clip.none
        return Stack(
          clipBehavior: Clip.none, // Critical to allow cards to extend beyond the stack
          // Use alignment to center the stack within the available space
          alignment: Alignment.center,
          children: [
            // Background layer
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: cornerRadius,
                ),
              ),
            ),
            
            // Interactive stack that responds to gestures
            GestureDetector(
              onVerticalDragStart: _onDragStart,
              onVerticalDragUpdate: _onDragUpdate,
              onVerticalDragEnd: _onDragEnd,
              // Use another Stack for the actual cards
              child: SizedBox(
                width: width,
                height: height,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Stack(
                      // This is critical to allow cards to overflow
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: _buildCardStack(width, height),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  // Build the stack of cards with 3D transforms
  List<Widget> _buildCardStack(double width, double height) {
    final List<Widget> stackItems = [];
    final int cardsCount = _stackItems.length;
    
    // Calculate animation progress (0.0 to 1.0)
    final animProgress = _isAnimating ? _animation.value : 0.0;
    
    // Show multiple cards in the stack
    for (int i = 0; i < math.min(4, cardsCount); i++) {
      // Calculate the index for each card in the stack (circular)
      final int cardIndex = (_currentIndex + i) % cardsCount;
      
      // Only the top card responds to dragging directly
      final bool isTopCard = i == 0;
      
      // Further reduced 3D effect with smaller offsets
      double verticalOffset = i * 12.0; // Reduced from 20.0 to 12.0
      double horizontalOffset = 0.0; // Removed horizontal offset for centering
      double scale = 1.0 - (i * 0.03); // Reduced from 0.05 to 0.03
      double zOffset = 30.0 - (i * 10.0); // Reduced from 50.0-20.0 to 30.0-10.0
      double rotationAngle = 0.0;
      
      // Apply drag offset only to the top card
      if (isTopCard && _isDragging) {
        verticalOffset += _dragOffset;
        
        // Add some rotation effect during drag, but further reduced
        rotationAngle = _dragOffset / 800.0; // Reduced from 600.0 to 800.0 for subtler rotation
      }
      
      if (_isAnimating) {
        if (i == 0) {
          // Top card animates off the top or bottom
          verticalOffset = _dragOffset > 0 
              ? height * animProgress  // Animate down and off screen
              : -height * animProgress; // Animate up and off screen
          
          // Further reduced rotation effect during animation
          rotationAngle = (_dragOffset > 0 ? 1 : -1) * 0.15 * animProgress; // Reduced from 0.2 to 0.15
        } else {
          // Other cards animate up as the top card moves off screen
          verticalOffset = 12.0 * (i - 1) + (12.0 * (1.0 - animProgress)); // Reduced from 20.0 to 12.0
          horizontalOffset = 0.0; // Centered horizontally
          scale = 1.0 - ((i - 1) * 0.03) - (0.03 * (1.0 - animProgress)); // Reduced from 0.05 to 0.03
          zOffset = 30.0 - ((i - 1) * 10.0) - (10.0 * (1.0 - animProgress)); // Reduced from 50.0-20.0 to 30.0-10.0
        }
      }
      
      // Calculate the effective size of the card
      double cardWidth = width * scale;
      double cardHeight = height * scale;
      
      // Position the card
      // Using negative positions allows cards to extend outside their container
      stackItems.add(
        Positioned(
          // Center cards horizontally by explicitly setting both left and right
          left: (width - cardWidth) / 2,
          right: (width - cardWidth) / 2,
          // Position from the top with reduced vertical offset
          top: verticalOffset,
          // Use an animated transform for the 3D effect
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0005) // Reduced perspective from 0.001 to 0.0005
              ..rotateX(rotationAngle)
              ..translate(0.0, 0.0, zOffset),
            alignment: Alignment.center,
            child: SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: _stackItems[cardIndex],
            ),
          ),
        ),
      );
    }
    
    return stackItems.reversed.toList(); // Reverse for correct z-order
  }
  
  // Build an individual card with enhanced 3D effects
  Widget _buildEnhancedCard(int index, {required int stackPosition}) {
    // Subtle drop shadows for a more subtle 3D appearance
    final boxShadows = [
      BoxShadow(
        color: Colors.black.withOpacity(0.4), // Reduced opacity from 0.6 to 0.4
        spreadRadius: 1, // Reduced from 2 to 1
        blurRadius: 12, // Reduced from 20 to 12
        offset: const Offset(0, 8), // Reduced from 15 to 8
      ),
      // Subtle inner shadow for depth
      BoxShadow(
        color: Colors.black.withOpacity(0.2), // Reduced opacity from 0.3 to 0.2
        spreadRadius: 0,
        blurRadius: 3, // Reduced from 5 to 3
        offset: const Offset(0, 3), // Reduced from 5 to 3
      ),
    ];
    
    // Different styling for each card in the stack
    final bool isTopCard = stackPosition == 0;
    
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: cornerRadius,
        boxShadow: isTopCard ? boxShadows : boxShadows,
        border: Border.all(
          color: Colors.white.withOpacity(isTopCard ? 0.1 : 0.03), // Reduced opacity
          width: isTopCard ? 0.5 : 0.3,
        ),
      ),
      margin: EdgeInsets.all(isTopCard ? 0 : 4), // Add margin to lower cards
      child: ClipRRect(
        borderRadius: cornerRadius,
        child: _stackItems[index],
      ),
    );
  }
  
  // Start dragging handler
  void _onDragStart(DragStartDetails details) {
    if (_isAnimating) return;
    
    setState(() {
      _isDragging = true;
      _dragOffset = 0.0;
    });
  }
  
  // Update drag position (vertical motion)
  void _onDragUpdate(DragUpdateDetails details) {
    if (_isAnimating) return;
    
    setState(() {
      // For vertical dragging, positive values mean dragging downward
      _dragOffset += details.delta.dy;
      
      // Limit dragging distance but allow enough for gesture recognition
      if (_dragOffset < -200) _dragOffset = -200; // Allow more upward drag for visual effect
      if (_dragOffset > 200) _dragOffset = 200; // Allow more downward drag for visual effect
    });
  }
  
  // End dragging and handle card transition
  void _onDragEnd(DragEndDetails details) {
    if (_isAnimating) return;
    
    final double velocity = details.velocity.pixelsPerSecond.dy;
    final double dragThreshold = 75.0;
    
    // Determine if we should change cards based on drag distance or velocity
    if (_dragOffset > dragThreshold || velocity > 500) {
      // Dragged down - go to previous card in circular fashion
      _animateCardTransition(-1);
    } else if (_dragOffset < -dragThreshold || velocity < -500) {
      // Dragged up - go to next card in circular fashion
      _animateCardTransition(1);
    } else {
      // Reset to original position with animation
      setState(() {
        _isDragging = false;
        _dragOffset = 0.0;
      });
    }
  }
  
  // Animate card transition with direction (1=next, -1=previous)
  void _animateCardTransition(int direction) {
    // Start animation
    setState(() {
      _isAnimating = true;
    });
    
    // Reset and run animation
    _controller.reset();
    _controller.forward().then((_) {
      // Update index after animation completes
      setState(() {
        // Move to the next/previous card in a circular fashion
        _currentIndex = (_currentIndex + direction) % _stackItems.length;
        if (_currentIndex < 0) _currentIndex += _stackItems.length; // Handle negative index
        
        _isDragging = false;
        _dragOffset = 0.0;
        _isAnimating = false;
      });
    });
  }
  
  // Helper to build placeholder cards for the stack
  static Widget _buildPlaceholderCard(
    String title,
    IconData icon,
    Color color,
    String primaryText,
    String secondaryText,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16.0), // Consistent border radius
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 48,
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),
            Text(
              primaryText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              secondaryText,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 