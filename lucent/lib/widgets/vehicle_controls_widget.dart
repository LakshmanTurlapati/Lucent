import 'package:flutter/material.dart';

class VehicleControlsWidget extends StatefulWidget {
  const VehicleControlsWidget({super.key});

  @override
  State<VehicleControlsWidget> createState() => _VehicleControlsWidgetState();
}

class _VehicleControlsWidgetState extends State<VehicleControlsWidget> {
  // Track active state for each control
  final List<bool> _activeStates = List.generate(6, (_) => false);
  
  // Define the vehicle control icons and their labels
  final List<Map<String, dynamic>> _controls = [
    {'icon': Icons.door_front_door, 'label': 'Door Status'},
    {'icon': Icons.ac_unit, 'label': 'Front Defrost'},
    {'icon': Icons.air, 'label': 'Ventilation'},
    {'icon': Icons.lightbulb_outline, 'label': 'Parking Lights'},
    {'icon': Icons.flashlight_on, 'label': 'High Beams'},
    {'icon': Icons.airline_seat_recline_normal, 'label': 'Seat Controls'},
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate size based on available width
        final double availableWidth = constraints.maxWidth;
        
        // Fixed font size for labels
        const double labelFontSize = 9.0;
        
        // Calculate button size for 3 buttons per row with proper spacing
        // Make buttons smaller - reduce by 20%
        final double buttonDiameter = ((availableWidth - 80) / 3) * 0.8;
        
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E), // Dark grey background
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            children: [
              // Spacer to push content toward center
              const Spacer(flex: 1),
              
              // First row of controls - Centered layout
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  3, 
                  (index) => _buildControlButton(
                    index, 
                    buttonDiameter, 
                    labelFontSize
                  )
                ),
              ),
              
              // Fixed spacing between rows
              const SizedBox(height: 20.0),
              
              // Second row of controls - Centered layout
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  3, 
                  (index) => _buildControlButton(
                    index + 3, 
                    buttonDiameter, 
                    labelFontSize
                  )
                ),
              ),
              
              // Spacer to push content toward center
              const Spacer(flex: 1),
            ],
          ),
        );
      }
    );
  }

  Widget _buildControlButton(int index, double size, double fontSize) {
    final bool isActive = _activeStates[index];
    final Map<String, dynamic> control = _controls[index];
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Clickable area for the icon
        GestureDetector(
          onTap: () {
            setState(() {
              _activeStates[index] = !_activeStates[index];
            });
          },
          // Circular container with icon
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFFF9500) : const Color(0xFFE5E5EA), // Orange when active, light grey when inactive
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                control['icon'],
                // Change icon color to white when active
                color: isActive ? Colors.white : const Color(0xFF1C1C1E),
                size: size * 0.4,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6.0), // Fixed spacing
        // Label
        SizedBox(
          width: size,
          child: Text(
            control['label'],
            style: TextStyle(
              // Change text color based on active state
              color: isActive ? Colors.white : Colors.white70,
              fontSize: fontSize,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
} 