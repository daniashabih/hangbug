import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangbug/core/theme/app_theme.dart';
import 'package:hangbug/widgets/floating_bottom_nav.dart';

void main() {
  group('FloatingBottomNav Widget Tests', () {
    testWidgets('renders all 4 default navigation items', (WidgetTester tester) async {
      int selectedIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: FloatingBottomNav(
                    selectedIndex: selectedIndex,
                    onItemSelected: (index) => selectedIndex = index,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Explore'), findsOneWidget);
      expect(find.text('Certificates'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Verify BackdropFilter and ClipRRect are used for glassmorphism
      expect(find.byType(BackdropFilter), findsOneWidget);
      expect(find.byType(ClipRRect), findsOneWidget);
    });

    testWidgets('triggers onItemSelected callback when tab tapped', (WidgetTester tester) async {
      int tappedIndex = -1;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: FloatingBottomNav(
                    selectedIndex: 0,
                    onItemSelected: (index) => tappedIndex = index,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Tap on Explore (index 1)
      await tester.tap(find.text('Explore'));
      expect(tappedIndex, equals(1));

      // Tap on Certificates (index 2)
      await tester.tap(find.text('Certificates'));
      expect(tappedIndex, equals(2));

      // Tap on Profile (index 3)
      await tester.tap(find.text('Profile'));
      expect(tappedIndex, equals(3));
    });

    testWidgets('supports dynamic items such as Admin tab', (WidgetTester tester) async {
      final itemsWithAdmin = [
        ...FloatingBottomNav.defaultItems,
        const FloatingNavItem(
          icon: Icons.admin_panel_settings_outlined,
          activeIcon: Icons.admin_panel_settings_rounded,
          label: 'Admin',
        ),
      ];

      int tappedIndex = -1;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: FloatingBottomNav(
                    selectedIndex: 4,
                    items: itemsWithAdmin,
                    onItemSelected: (index) => tappedIndex = index,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Admin'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);

      await tester.tap(find.text('Admin'));
      expect(tappedIndex, equals(4));
    });

    testWidgets('applies active styling to the selected item', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: FloatingBottomNav(
                    selectedIndex: 2, // Certificates active
                    onItemSelected: (_) {},
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Verify Certificates active icon is displayed
      expect(find.byIcon(Icons.workspace_premium_rounded), findsOneWidget);
      // Verify inactive icons are displayed with outline variants
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
      expect(find.byIcon(Icons.explore_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
    });
  });
}
