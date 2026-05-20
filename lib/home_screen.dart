import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'main.dart';
import 'register_screen.dart';
class HomeScreen extends StatefulWidget {
const HomeScreen({super.key});
@override
State<HomeScreen> createState() => 
_HomeScreenState();
}
class _HomeScreenState 
extends State<HomeScreen> {
final AppManager _manager = 
AppManager();
bool _isLoading = false;
String _statusMessage = 
"위치 확인 중...";
double _currentDistance = -1.0;
bool _isInsideZone = false;
@override
void initState() {
super.initState();
_manager.addListener(_updateState);
_checkCurrentLocationAndZone();
}
@override
void dispose() {
_manager.removeListener(_updateState);
super.dispose();
}
void _updateState() {
if (mounted) setState(() {});
}
Future<void> 
_checkCurrentLocationAndZone() 
async {
if (!_manager.isRegistered) {
setState(() {
_statusMessage = 
"우측 상단 아이콘을 눌러\n"
"출근지를 등록해주세요.";
});
return;
}
setState(() {
_isLoading = true;
});
try {
bool serviceEnabled = 
await Geolocator
.isLocationServiceEnabled();
if (!serviceEnabled) {
throw '스마트폰 GPS가 꺼져있습니다.';
}
LocationPermission permission = 
await Geolocator
.checkPermission();
if (permission == 
LocationPermission.denied) {
permission = await Geolocator
.requestPermission();
if (permission == 
LocationPermission.denied) {
throw '위치 권한이 거부되었습니다.';
}
}
if (permission == 
LocationPermission
.deniedForever) {
throw '위치 권한이 차단되었습니다.';
}
Position position = 
await Geolocator
.getCurrentPosition(
locationSettings: 
const LocationSettings(
accuracy: 
LocationAccuracy.high
)
);
double distanceInMeters = 
Geolocator.distanceBetween(
position.latitude,
position.longitude,
_manager.targetLat,
_manager.targetLng,
);
setState(() {
_currentDistance = 
distanceInMeters;
_isInsideZone = 
distanceInMeters <= 
_manager.targetRadius;
_statusMessage = _isInsideZone 
? "📍 출근 가능 위치입니다." 
: "🚨 반경 외 위치\n"
"(회사까지 약 "
"${_currentDistance
.toStringAsFixed(0)}m)";
_isLoading = false;
});
} catch (e) {
setState(() {
_statusMessage = e.toString();
_isLoading = false;
_isInsideZone = false;
});
}
}
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: Text(
'${_manager.userName}의 출근', 
style: const TextStyle(
fontSize: 14
)
),
centerTitle: true,
actions: [
IconButton(
icon: const Icon(
Icons.settings, 
size: 18
),
onPressed: () => 
Navigator.push(
context, 
MaterialPageRoute(
builder: (_) => 
const RegisterScreen()
)
),
)
],
),
body: SingleChildScrollView(
child: Padding(
padding: const 
EdgeInsets.symmetric(
horizontal: 10.0, 
vertical: 8.0
),
child: Column(
children: [
_buildSimpleCalendar(),
const SizedBox(height: 12),
Card(
elevation: 1,
color: _isInsideZone 
? Colors.teal.shade50 
: Colors.red.shade50,
child: Padding(
padding: const 
EdgeInsets.all(10.0),
child: Column(
children: [
if (_isLoading) 
const SizedBox(
width: 18, 
height: 18, 
child: 
CircularProgressIndicator(
strokeWidth: 2
)
) 
else 
Icon(
_isInsideZone 
? Icons.gpp_good
: Icons.location_off,
color: _isInsideZone 
? Colors.teal 
: Colors.red,
size: 20,
),
const SizedBox(height: 4),
Text(
_statusMessage,
textAlign: 
TextAlign.center,
style: const 
TextStyle(
fontWeight: 
FontWeight.bold, 
fontSize: 11
),
),
],
),
),
),
const SizedBox(height: 8),
SizedBox(
height: 32,
child: ElevatedButton.icon(
onPressed: _isLoading 
? null 
: _checkCurrentLocationAndZone,
icon: const Icon(
Icons.refresh, 
size: 12
),
label: const Text(
'위치 다시 갱신', 
style: TextStyle(
fontSize: 10
)
),
style: ElevatedButton
.styleFrom(
padding: const 
EdgeInsets.symmetric(
horizontal: 8
),
),
),
),
const SizedBox(height: 16),
SizedBox(
width: 110,
height: 110,
child: ElevatedButton(
onPressed: _isInsideZone && 
!_isLoading 
? () {
_manager.checkIn(
DateTime.now()
);
ScaffoldMessenger
.of(context)
.showSnackBar(
const SnackBar(
content: Text(
'저장 완료! 🎉', 
style: TextStyle(
fontSize: 11
)
)
),
);
} : null,
style: ElevatedButton
.styleFrom(
shape: const 
CircleBorder(),
backgroundColor: 
Colors.teal,
foregroundColor: 
Colors.white,
disabledBackgroundColor: 
Colors.grey.shade300,
elevation: 1,
),
child: const Text(
'출근 완료',
style: TextStyle(
fontSize: 14, 
fontWeight: 
FontWeight.bold
),
),
),
),
],
),
),
),
);
}
Widget _buildSimpleCalendar() {
final now = DateTime.now();
final daysInMonth = DateTime(
now.year, 
now.month + 1, 
0
).day;
return Column(
crossAxisAlignment: 
CrossAxisAlignment.start,
children: [
Text(
'🗓️ ${now.month}월 기록',
style: const TextStyle(
fontSize: 12, 
fontWeight: FontWeight.bold
),
),
const SizedBox(height: 6),
GridView.builder(
shrinkWrap: true,
physics: const 
NeverScrollableScrollPhysics(),
itemCount: daysInMonth,
gridDelegate: const 
SliverGridDelegateWithFixedCrossAxisCount(
crossAxisCount: 7,
mainAxisSpacing: 3,
crossAxisSpacing: 3,
),
itemBuilder: (context, index) {
final day = index + 1;
final currentCheckDate = 
DateTime(
now.year, 
now.month, 
day
);
bool isChecked = _manager
.attendanceDates
.contains(
currentCheckDate
);
return Container(
decoration: BoxDecoration(
color: isChecked 
? Colors.teal 
: Colors.grey.shade100,
borderRadius: 
BorderRadius.circular(4),
border: Border.all(
color: now.day == day 
? Colors.teal 
: Colors.transparent, 
width: 1.2
),
),
alignment: Alignment.center,
child: Text(
'$day',
style: TextStyle(
fontSize: 10,
fontWeight: 
FontWeight.bold,
color: isChecked 
? Colors.white 
: Colors.black87,
),
),
);
},
),
],
);
}
}

