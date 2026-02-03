import 'package:flutter/material.dart';

class EmergencyButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onPressed;

  const EmergencyButton({
    super.key,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          gradient: isActive
              ? const RadialGradient(
                  colors: [Colors.red, Color(0xFF8B0000)],
                  radius: 0.8,
                )
              : const RadialGradient(
                  colors: [Colors.grey, Color(0xFF4A4A4A)],
                  radius: 0.8,
                ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? Colors.red.withOpacity(0.4)
                  : Colors.grey.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pulsing animation
            if (isActive)
              TweenAnimationBuilder(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(seconds: 2),
                builder: (context, value, child) {
                  return Container(
                    width: 200 * value,
                    height: 200 * value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.red.withOpacity(1 - value),
                        width: 2,
                      ),
                    ),
                  );
                },
              ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.emergency_rounded,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 8),
                Text(
                  'SOS',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Press in Emergency',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
