import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jabchaho/core/widgets/liquid_glass.dart';
import 'package:jabchaho/main.dart';

void main() {
  Future<void> setViewport(WidgetTester tester, Size size) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
  }

  testWidgets('shows the smart super-app home', (tester) async {
    await tester.pumpWidget(const JabChahoApp());

    expect(find.text('JABCHAHO'), findsOneWidget);
    expect(find.textContaining('What can we handle?'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Grocery'), findsOneWidget);
    expect(find.text('Laundry'), findsOneWidget);
    expect(find.text('Pharmacy'), findsOneWidget);
    expect(find.text('Synced'), findsOneWidget);
  });

  testWidgets('opens AI assistant and accepts a smart prompt', (tester) async {
    await tester.pumpWidget(const JabChahoApp());
    await tester.tap(find.text('Say it. Consider it done.'));
    await tester.pumpAndSettle();

    expect(find.text('What should I handle?'), findsOneWidget);
    await tester.tap(find.text('Plan dinner for 4'));
    await tester.pump();
    expect(find.text('Plan dinner for 4'), findsNWidgets(2));
  });

  testWidgets('bottom navigation changes sections', (tester) async {
    await tester.pumpWidget(const JabChahoApp());
    final initialPosition = tester
        .widget<AnimatedPositioned>(find.byType(AnimatedPositioned))
        .left;
    await tester.tap(find.text('Orders'));
    await tester.pumpAndSettle();

    expect(find.text('Your orders'), findsOneWidget);
    expect(find.byIcon(Icons.receipt_long_rounded), findsWidgets);
    final selectedPosition = tester
        .widget<AnimatedPositioned>(find.byType(AnimatedPositioned))
        .left;
    expect(selectedPosition, greaterThan(initialPosition!));
  });

  testWidgets('narrow phone layout stays usable without overflow', (
    tester,
  ) async {
    await setViewport(tester, const Size(320, 700));
    await tester.pumpWidget(const JabChahoApp());
    await tester.pump();

    expect(find.textContaining('What can we handle?'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tablet layout uses additional service columns', (tester) async {
    await setViewport(tester, const Size(820, 1180));
    await tester.pumpWidget(const JabChahoApp());
    await tester.pump();

    expect(find.text('More'), findsOneWidget);
    expect(find.text('Picked for your day'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('expanded layout replaces bottom bar with navigation rail', (
    tester,
  ) async {
    await setViewport(tester, const Size(1280, 900));
    await tester.pumpWidget(const JabChahoApp());
    await tester.pump();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.text('Happening now'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Food')).dy,
      tester.getTopLeft(find.text('More')).dy,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('desktop AI opens as a centered dialog with readable prompts', (
    tester,
  ) async {
    await setViewport(tester, const Size(1440, 900));
    await tester.pumpWidget(const JabChahoApp());
    await tester.tap(find.text('Say it. Consider it done.'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.text('Repeat last grocery'), findsOneWidget);
    expect(find.text('Plan dinner for 4'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('compact header appears after scrolling', (tester) async {
    await setViewport(tester, const Size(390, 844));
    await tester.pumpWidget(const JabChahoApp());

    expect(find.byKey(const ValueKey('collapsed-home-header')), findsNothing);
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('collapsed-home-header')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('interactive glass supports pointer and accessibility modes', (
    tester,
  ) async {
    await setViewport(tester, const Size(500, 500));
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(500, 500),
            highContrast: true,
            disableAnimations: true,
          ),
          child: const Center(
            child: LiquidGlass(
              key: ValueKey('interactive-glass'),
              interactive: true,
              child: SizedBox(width: 160, height: 64),
            ),
          ),
        ),
      ),
    );

    final center = tester.getCenter(
      find.byKey(const ValueKey('interactive-glass')),
    );
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: center);
    await mouse.moveTo(center + const Offset(20, 4));
    await mouse.down(center + const Offset(20, 4));
    await tester.pump();
    await mouse.up();
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
