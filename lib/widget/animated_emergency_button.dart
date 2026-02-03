import 'package:flutter/material.dart';

class AnimatedEmergencyButton extends StatefulWidget {
  final bool isActive;
  final bool isSending;
  final VoidCallback onPressed;

  const AnimatedEmergencyButton({
    super.key,
    required this.isActive,
    required this.isSending,
    required this.onPressed,
  });

  @override
  State<AnimatedEmergencyButton> createState() =>
      _AnimatedEmergencyButtonState();
}

class _AnimatedEmergencyButtonState extends State<AnimatedEmergencyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _colorAnimation = ColorTween(
      begin: Colors.red[700],
      end: Colors.red[400],
    ).animate(_pulseController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isActive ? widget.onPressed : null,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow effect
            if (widget.isActive && !widget.isSending)
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(
                            _glowAnimation.value * 0.5,
                          ),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  );
                },
              ),

            // Main button
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: widget.isActive ? _scaleAnimation.value : 1.0,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: widget.isActive
                          ? RadialGradient(
                              colors: [
                                _colorAnimation.value!,
                                const Color(0xFF8B0000),
                              ],
                              radius: 0.8,
                            )
                          : const RadialGradient(
                              colors: [Colors.grey, Color(0xFF4A4A4A)],
                              radius: 0.8,
                            ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.isActive
                              ? Colors.red.withOpacity(
                                  _glowAnimation.value * 0.8,
                                )
                              : Colors.grey.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Pulsing rings
                        if (widget.isActive && !widget.isSending)
                          ...List.generate(3, (index) {
                            return TweenAnimationBuilder(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: Duration(
                                milliseconds: 2000 + (index * 500),
                              ),
                              builder: (context, value, child) {
                                return Container(
                                  width: 200 + (100 * value),
                                  height: 200 + (100 * value),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.red.withOpacity(1 - value),
                                      width: 2,
                                    ),
                                  ),
                                );
                              },
                            );
                          }),

                        // Button content
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.isSending)
                              const SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                ),
                              )
                            else
                              const Icon(
                                Icons.emergency_rounded,
                                color: Colors.white,
                                size: 48,
                              ),
                            const SizedBox(height: 8),
                            Text(
                              widget.isSending ? 'SENDING...' : 'SOS',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.isSending
                                  ? 'Alerting contacts...'
                                  : 'Press in Emergency',
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
              },
            ),
          ],
        ),
      ),
    );
  }
}
