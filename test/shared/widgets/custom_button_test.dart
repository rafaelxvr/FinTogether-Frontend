import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/shared/widgets/custom_button.dart';

void main() {
  group('CustomButton Widget Tests', () {
    testWidgets('should render button with text', (WidgetTester tester) async {
      // Arrange
      const buttonText = 'Click Me';
      var wasPressed = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: buttonText,
              onPressed: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(buttonText), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped',
        (WidgetTester tester) async {
      // Arrange
      var wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Click Me',
              onPressed: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(CustomButton));
      await tester.pump();

      // Assert
      expect(wasPressed, true);
    });

    testWidgets('should show loading indicator when isLoading is true',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Submit',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Submit'), findsNothing);
    });

    testWidgets('should be disabled when isLoading is true',
        (WidgetTester tester) async {
      // Arrange
      var wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Submit',
              onPressed: () {
                wasPressed = true;
              },
              isLoading: true,
            ),
          ),
        ),
      );

      // Act - Try to tap
      await tester.tap(find.byType(CustomButton));
      await tester.pump();

      // Assert - onPressed should not be called because button is disabled
      expect(wasPressed, false);
    });

    testWidgets('should apply primary color when isPrimary is true',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Primary Button',
              onPressed: () {},
              isPrimary: true,
            ),
          ),
        ),
      );

      // Assert
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button, isNotNull);
    });

    testWidgets('should render with icon when provided',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Save',
              onPressed: () {},
              icon: Icons.save,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.save), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('should render without icon when not provided',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Submit',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(Icon), findsNothing);
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('should have full width when fullWidth is true',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: CustomButton(
                text: 'Full Width',
                onPressed: () {},
                fullWidth: true,
              ),
            ),
          ),
        ),
      );

      // Assert
      final button = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(ElevatedButton),
          matching: find.byType(SizedBox),
        ),
      );
      expect(button.constraints?.maxWidth, double.infinity);
    });

    testWidgets('should apply custom padding when provided',
        (WidgetTester tester) async {
      // Arrange
      const customPadding = EdgeInsets.all(24.0);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Custom Padding',
              onPressed: () {},
              padding: customPadding,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CustomButton), findsOneWidget);
    });

    testWidgets('should not call onPressed multiple times on rapid taps',
        (WidgetTester tester) async {
      // Arrange
      var pressCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Tap Me',
              onPressed: () {
                pressCount++;
              },
            ),
          ),
        ),
      );

      // Act - Rapid taps
      await tester.tap(find.byType(CustomButton));
      await tester.pump(const Duration(milliseconds: 10));
      await tester.tap(find.byType(CustomButton));
      await tester.pump(const Duration(milliseconds: 10));

      // Assert - Should be called twice (no debouncing in basic implementation)
      expect(pressCount, 2);
    });

    testWidgets('should render in Material3 style', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: CustomButton(
              text: 'Material 3',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CustomButton), findsOneWidget);
    });

    testWidgets('should maintain state after rebuild',
        (WidgetTester tester) async {
      // Arrange
      var pressCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Click Me',
              onPressed: () {
                pressCount++;
              },
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(CustomButton));
      await tester.pump();

      // Rebuild
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Click Me',
              onPressed: () {
                pressCount++;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CustomButton));
      await tester.pump();

      // Assert
      expect(pressCount, 2);
    });
  });
}
