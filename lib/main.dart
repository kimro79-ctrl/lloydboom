import 'package:flutter/material.dart';
import 'home_screen.dart';
void main() {
WidgetsFlutterBinding
.ensureInitialized();
runApp(const MyApp());
}
class MyApp extends StatelessWidget {
const MyApp({super.key});
@override
Widget build(BuildContext context) {
return MaterialApp(
title: 'Lloyd Boom',
debugShowCheckedModeBanner: false,
theme: ThemeData(
useMaterial3: true,
colorScheme: 
ColorScheme.fromSeed(
seedColor: Colors.teal
),
),
home: const HomeScreen(),
);
}
}
class AppManager extends ChangeNotifier {
static final AppManager _instance = 
AppManager._internal();
factory AppManager() => _instance;
AppManager._internal();
String userName = "미등록";
bool isRegistered = false;
double targetLat = 0.0;
double targetLng = 0.0;
double targetRadius = 50.0;
List<DateTime> attendanceDates = [];
void registerUser(
String name, 
double lat, 
double lng) {
userName = name;
targetLat = lat;
targetLng = lng;
isRegistered = true;
notifyListeners();
}
void checkIn(DateTime date) {
final today = DateTime(
date.year, 
date.month, 
date.day
);
if (!attendanceDates
.contains(today)) {
attendanceDates.add(today);
notifyListeners();
}
}
}

