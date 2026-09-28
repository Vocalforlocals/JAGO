import 'package:flutter/material.dart';

class DeviceFrameWrapper extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState>? navigatorKey;

  const DeviceFrameWrapper({
    Key? key,
    required this.child,
    this.navigatorKey,
  }) : super(key: key);

  @override
  State<DeviceFrameWrapper> createState() => _DeviceFrameWrapperState();
}

class _DeviceFrameWrapperState extends State<DeviceFrameWrapper> {
  bool _forceMobileFrame = true;

  final List<Map<String, dynamic>> _quickNavItems = [
    {'title': '🏠 Landing', 'route': '/'},
    {'title': '🔑 Login', 'route': '/login'},
    {'title': '📊 Dashboard', 'route': '/dashboard'},
    {'title': '👤 Profile', 'route': '/profile'},
    {'title': '📁 Vault', 'route': '/documents'},
    {'title': '🎓 Schemes', 'route': '/scholarships'},
    {'title': '💳 DBT Pay', 'route': '/payments'},
    {'title': '🤖 JAGO AI', 'route': '/jago'},
    {'title': '🔔 Alerts', 'route': '/notifications'},
  ];

  void _navigateTo(String route) {
    if (widget.navigatorKey?.currentState != null) {
      widget.navigatorKey!.currentState!.pushNamed(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // On narrow screens (real mobile phone screen), render directly full screen
    if (screenWidth <= 500 || !_forceMobileFrame) {
      return widget.child;
    }

    // On desktop / tablet browsers, render inside an ultra-realistic smartphone mockup
    return Scaffold(
      backgroundColor: const Color(0xFF0B132B), // Premium midnight navy
      body: Stack(
        children: [
          // Background ambient gradient glow
          Positioned(
            top: -120,
            left: screenWidth / 2 - 300,
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF046A38).withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Top Info Banner & Screen Switcher
          Positioned(
            top: 10,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF046A38),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF046A38).withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.phone_android, size: 14, color: Colors.white),
                                SizedBox(width: 6),
                                Text(
                                  'JAGO National Student Mobile App',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Flexible(
                            child: Text(
                              'Ministry of Tribal Affairs • Government of India',
                              style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _forceMobileFrame = !_forceMobileFrame;
                            });
                          },
                          icon: Icon(
                            _forceMobileFrame ? Icons.fullscreen : Icons.stay_current_portrait,
                            size: 16,
                            color: Colors.white70,
                          ),
                          label: Text(
                            _forceMobileFrame ? 'Expand Fullscreen' : 'View in Phone Frame',
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Quick Navigation Carousel Pills
                SizedBox(
                  height: 30,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _quickNavItems.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final item = _quickNavItems[idx];
                      return ActionChip(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                        backgroundColor: const Color(0xFF1E293B),
                        side: const BorderSide(color: Color(0xFF334155), width: 1),
                        label: Text(
                          item['title'] as String,
                          style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => _navigateTo(item['route'] as String),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Centered Smartphone Frame with Hardware Details
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 80, bottom: 20),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Physical Left Buttons (Volume Up/Down)
                  Positioned(
                    left: -4,
                    top: 140,
                    child: Container(
                      width: 4,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF475569),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(2),
                          bottomLeft: Radius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -4,
                    top: 205,
                    child: Container(
                      width: 4,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF475569),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(2),
                          bottomLeft: Radius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  // Physical Right Button (Power Key)
                  Positioned(
                    right: -4,
                    top: 170,
                    child: Container(
                      width: 4,
                      height: 68,
                      decoration: BoxDecoration(
                        color: const Color(0xFF475569),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(2),
                          bottomRight: Radius.circular(2),
                        ),
                      ),
                    ),
                  ),

                  // Phone Chassis Container
                  Container(
                    width: 412,
                    height: 870,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: const Color(0xFF334155), width: 4.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.75),
                          blurRadius: 40,
                          spreadRadius: 8,
                          offset: const Offset(0, 18),
                        ),
                        BoxShadow(
                          color: const Color(0xFF046A38).withValues(alpha: 0.15),
                          blurRadius: 30,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(45),
                      child: Stack(
                        children: [
                          // Inner Flutter Application
                          Positioned.fill(
                            child: MediaQuery(
                              data: MediaQuery.of(context).copyWith(
                                size: const Size(412, 870),
                                padding: const EdgeInsets.only(top: 42, bottom: 20),
                              ),
                              child: widget.child,
                            ),
                          ),

                          // Simulated Phone Status Bar Header
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: 38,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 22),
                              color: Colors.transparent,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    '09:41',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  Row(
                                    children: const [
                                      Icon(Icons.signal_cellular_4_bar, size: 13, color: Color(0xFF0F172A)),
                                      SizedBox(width: 4),
                                      Icon(Icons.wifi, size: 13, color: Color(0xFF0F172A)),
                                      SizedBox(width: 4),
                                      Icon(Icons.battery_full, size: 14, color: Color(0xFF0F172A)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Dynamic Island / Camera Notch Pill with Speaker
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              margin: const EdgeInsets.only(top: 8),
                              width: 110,
                              height: 25,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Speaker Slit
                                  Container(
                                    width: 32,
                                    height: 3.5,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E293B),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  // Camera lens
                                  Container(
                                    width: 9,
                                    height: 9,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF0F172A),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Bottom Gesture Home Indicator Bar
                          Positioned(
                            bottom: 6,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                width: 134,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
