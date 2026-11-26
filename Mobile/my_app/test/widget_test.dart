// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:my_app/main.dart';
import 'package:my_app/services/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App opens on login page', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Sign in Your Account'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
    expect(find.text('Facebook'), findsOneWidget);
  });

  testWidgets('social login button explains unavailable provider', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.widgetWithText(OutlinedButton, 'Google'));
    await tester.tap(find.widgetWithText(OutlinedButton, 'Google'));
    await tester.pumpAndSettle();

    expect(find.text('Login Google belum tersedia'), findsOneWidget);
  });

  testWidgets('saved token opens home on app startup', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'token': 'saved-token'});

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Selamat Datang'), findsNothing);
  });

  testWidgets('successful login saves token and opens home', (
    WidgetTester tester,
  ) async {
    ApiService.clientForTesting = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/api/auth/login');
      final requestBody = jsonDecode(request.body) as Map<String, dynamic>;
      expect(requestBody['email'], 'user@example.com');
      expect(requestBody['password'], 'secret123');
      return http.Response(
        jsonEncode({
          'success': true,
          'data': {
            'token': 'test-token',
            'user': {
              'id': 1,
              'username': 'tester',
              'email': 'user@example.com',
              'role': 'user',
            },
          },
        }),
        200,
      );
    });

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Sign In'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Beranda'), findsOneWidget);
    expect(await ApiService.getToken(), 'test-token');
  });

  testWidgets('failed login stays on login and does not save token', (
    WidgetTester tester,
  ) async {
    ApiService.clientForTesting = MockClient((_) async {
      return http.Response(
        jsonEncode({'success': false, 'message': 'Email atau password salah'}),
        401,
      );
    });

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Sign In'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Sign in Your Account'), findsOneWidget);
    expect(find.text('Email atau password salah'), findsOneWidget);
    expect(await ApiService.getToken(), isNull);
  });

  testWidgets('successful registration logs in, saves token, and opens home', (
    WidgetTester tester,
  ) async {
    ApiService.clientForTesting = MockClient((request) async {
      if (request.url.path == '/api/auth/register') {
        expect(request.method, 'POST');
        final requestBody = jsonDecode(request.body) as Map<String, dynamic>;
        expect(requestBody['username'], 'tester');
        expect(requestBody['email'], 'user@example.com');
        expect(requestBody['password'], 'secret123');
        return http.Response(
          jsonEncode({
            'success': true,
            'data': {
              'user': {
                'id': 1,
                'username': 'tester',
                'email': 'user@example.com',
                'role': 'user',
              },
            },
          }),
          201,
        );
      }

      expect(request.url.path, '/api/auth/login');
      return http.Response(
        jsonEncode({
          'success': true,
          'data': {
            'token': 'registered-user-token',
            'user': {
              'id': 1,
              'username': 'tester',
              'email': 'user@example.com',
              'role': 'user',
            },
          },
        }),
        200,
      );
    });

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Sign Up'));
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'tester');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(2), 'secret123');
    await tester.enterText(find.byType(TextFormField).at(3), 'secret123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Daftar'));
    await tester.pumpAndSettle();

    expect(find.text('Beranda'), findsOneWidget);
    expect(await ApiService.getToken(), 'registered-user-token');
  });
}
