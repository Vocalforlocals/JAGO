import 'package:flutter/material.dart';

/// Wraps the Flutter application in a clean, responsive mobile viewport.
/// - On mobile phones (width <= 500): Edge-to-edge 100% native mobile UI.
/// - On desktop/tablets (width > 500): Elegantly centered mobile device view
///   (max-width 430px) that fills the screen height without overflowing,
///   giving the true look, feel, and ergonomics of a native mobile app.
class DeviceFrameWrapper extends StatelessWidget {
  final Widget child;
  final GlobalKey<NavigatorState>? navigatorKey;

  const DeviceFrameWrapper({
    Key? key,
    required this.child,
    this.navigatorKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    // Mobile phones: pure 100% native full-screen experience
    if (screenWidth <= 500) {
      return child;
    }

    // Desktop / Tablet: Centered authentic mobile phone view
    const double mobileMaxWidth = 430.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Sleek dark slate backdrop
      body: Center(
        child: Container(
          width: mobileMaxWidth,
          height: screenHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(screenWidth > 600 ? 28 : 0),
            border: screenWidth > 600
                ? Border.all(color: const Color(0xFF334155), width: 3)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 40,
                spreadRadius: 4,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: const Color(0xFF046A38).withOpacity(0.12),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(screenWidth > 600 ? 25 : 0),
            child: MediaQuery(
              data: mediaQuery.copyWith(
                size: Size(mobileMaxWidth, screenHeight),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
