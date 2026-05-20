import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'main.dart';
class RegisterScreen extends StatefulWidget {
const RegisterScreen({super.key});
@override
State<RegisterScreen> createState() => 
_RegisterScreenState();
}
class _RegisterScreenState 
extends State<RegisterScreen> {
final AppManager _manager = 
AppManager();
final TextEditingController 
_nameController = 
TextEditingController();
double _selectedLat = 0.0;
double _selectedLng = 0.0;
bool _isLocating = false;
String _gpsStatus = 
"위치를 조회하지 않았습니다.";
@override
void initState() {
super.initState();
_nameController.text = 
_manager.isRegistered 
? _manager.userName : "";
_selectedLat = _manager.targetLat;
_selectedLng = _manager.targetLng;
if (_manager.isRegistered) {
_gpsStatus = "등록지:\n위도 "
"${_selectedLat.toStringAsFixed(4)}\n"
"경도 ${_selectedLng.toStringAsFixed(4)}";
}
}
Future<void> 
_captureCurrentLocation() 
async {
setState(() {
_isLocating = true;
_gpsStatus = "신호 수신 중...";
});
try {
LocationPermission permission = 
await Geolocator
.checkPermission();
if (permission == 
LocationPermission.denied || 
permission == 
LocationPermission.deniedForever) {
permission = await Geolocator
.requestPermission();
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
setState(() {
_selectedLat = 
position.latitude;
_selectedLng = 
position.longitude;
_gpsStatus = "🎯 수신 성공!\n"
"위도: ${_selectedLat.toStringAsFixed(4)}\n"
"경도: ${_selectedLng.toStringAsFixed(4)}";
_isLocating = false;
});
} catch (e) {
setState(() {
_gpsStatus = "실패: $e";
_isLocating = false;
});
}
}
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text(
'정보 설정', 
style: TextStyle(fontSize: 14)
),
centerTitle: true,
),
body: Padding(
padding: const 
EdgeInsets.all(10.0),
child: Column(
crossAxisAlignment: 
CrossAxisAlignment.stretch,
children: [
SizedBox(
height: 38,
child: TextField(
controller: 
_nameController,
style: const 
TextStyle(fontSize: 12),
decoration: const 
InputDecoration(
makeLabel: '이름 입력',
labelText: '이름 입력',
labelStyle: 
TextStyle(fontSize: 11),
contentPadding: 
EdgeInsets.symmetric(
vertical: 4, 
horizontal: 8
),
border: 
OutlineInputBorder(),
),
),
),
const SizedBox(height: 12),
const Text(
'📍 회사 위치 설정', 
style: TextStyle(
fontWeight: 
FontWeight.bold, 
fontSize: 12
)
),
const SizedBox(height: 4),
Container(
padding: const 
EdgeInsets.all(8),
decoration: BoxDecoration(
color: Colors.grey.shade100,
borderRadius: 
BorderRadius.circular(4),
border: Border.all(
color: Colors.grey.shade300
)
),
child: Text(
_gpsStatus,
textAlign: 
TextAlign.center,
style: const TextStyle(
fontSize: 10, 
color: Colors.black87, 
height: 1.2
),
),
),
const SizedBox(height: 6),
SizedBox(
height: 32,
child: ElevatedButton.icon(
onPressed: _isLocating 
? null 
: _captureCurrentLocation,
icon: const Icon(
Icons.my_location, 
size: 12
),
label: const Text(
'현재 위치 가져오기', 
style: TextStyle(
fontSize: 10
)
),
style: ElevatedButton
.styleFrom(
backgroundColor: 
Colors.blueGrey.shade50
),
),
),
const Spacer(),
SizedBox(
height: 40,
child: ElevatedButton(
onPressed: () {
if (_selectedLat == 0.0 || 
_selectedLng == 0.0) {
ScaffoldMessenger
.of(context)
.showSnackBar(
const SnackBar(
content: Text(
'위치를 먼저 수신해 주세요.', 
style: TextStyle(
fontSize: 11
)
)
),
);
return;
}
String name = 
_nameController
.text.trim().isEmpty 
? "익명" 
: _nameController.text;
_manager.registerUser(
name, 
_selectedLat, 
_selectedLng
);
ScaffoldMessenger
.of(context)
.showSnackBar(
const SnackBar(
content: Text(
'저장 완료.', 
style: TextStyle(
fontSize: 11
)
)
),
);
Navigator.pop(context);
},
style: ElevatedButton
.styleFrom(
backgroundColor: 
Colors.teal,
foregroundColor: 
Colors.white,
shape: 
RoundedRectangleBorder(
borderRadius: 
BorderRadius.circular(4)
),
),
child: const Text(
'설정 저장', 
style: TextStyle(
fontSize: 13, 
fontWeight: 
FontWeight.bold
)
),
),
)
],
),
),
);
}
}

