import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

void main() => runApp(const MaterialApp(home: LloydboomHome()));

class LloydboomHome extends StatefulWidget {
  const LloydboomHome({super.key});
  @override
  State<LloydboomHome> createState() => _LloydboomHomeState();
}

class _LloydboomHomeState extends State<LloydboomHome> {
  DateTime _focusedDay = DateTime.now();
  String _timeString = "";
  String _lastStatus = "기록 없음";

  @override
  void initState() {
    super.initState();
    _timeString = DateTime.now().toString().substring(11, 19);
    Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
  }

  void _updateTime() {
    setState(() { _timeString = DateTime.now().toString().substring(11, 19); });
  }

  Future<void> _sendSms(String status) async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: '010-1234-5678', // 관리자 번호
      queryParameters: {'body': '[로이드밤] $status 완료: $_timeString'},
    );
    if (await canLaunchUrl(smsUri)) await launchUrl(smsUri);
    setState(() { _lastStatus = "$status 완료 ($_timeString)"; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("로이드밤 출퇴근 관리")),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text(_timeString, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
          Text("상태: $_lastStatus"),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: () => _sendSms("출근"), child: const Text("출근하기")),
              const SizedBox(width: 20),
              ElevatedButton(onPressed: () => _sendSms("퇴근"), child: const Text("퇴근하기")),
            ],
          ),
          Expanded(
            child: TableCalendar(
              firstDay: DateTime.utc(2025, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
            ),
          ),
        ],
      ),
    );
  }
}
