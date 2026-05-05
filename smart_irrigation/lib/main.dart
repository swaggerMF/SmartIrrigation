import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/irrigation_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/pump_control_screen.dart';
import 'screens/sensor_details_screen.dart';
import 'screens/logs_screen.dart';
import 'screens/mqtt_settings_screen.dart';
import 'screens/automation_settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartIrrigationApp());
}

class SmartIrrigationApp extends StatelessWidget {
  const SmartIrrigationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => IrrigationProvider(),
      child: MaterialApp(
        title: 'Smart Irrigation',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2E7D32),
            primary: const Color(0xFF2E7D32),
            secondary: const Color(0xFF1565C0),
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          cardTheme: CardTheme(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        home: const MainNavigation(),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  static const _screens = [
    DashboardScreen(),
    PumpControlScreen(),
    SensorDetailsScreen(),
    LogsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.power_settings_new_outlined),
            selectedIcon: Icon(Icons.power_settings_new),
            label: 'Pump',
          ),
          NavigationDestination(
            icon: Icon(Icons.sensors_outlined),
            selectedIcon: Icon(Icons.sensors),
            label: 'Sensors',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Logs',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF2E7D32)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.water_drop, size: 40, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'Smart Irrigation',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  Text('Control System',
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings_input_antenna),
              title: const Text('MQTT Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const MqttSettingsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.tune),
              title: const Text('Automation Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AutomationSettingsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
