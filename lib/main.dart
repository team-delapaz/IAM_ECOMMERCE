import 'package:flutter/material.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'app.dart';

/// entry point of Flutter App

Future<void> main() async {
  ///Todo: Add widget Binding
  ///Todo: Init local storage
  ///Todo: Await native spalsh
  ///Todo: Initialize Firebase
  ///Todo: Inidtialize Authentication

  WidgetsFlutterBinding.ensureInitialized();
  await ApiMiddleware.init();
  runApp(const App());
}
