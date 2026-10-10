import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screen/display.dart';
import 'screen/formscreen.dart';

// เปิดการเชื่อมต่อ Firebase ก่อนเริ่มแอป
// (แก้ error "No Firebase App '[DEFAULT]' has been created" ตามท้ายใบงาน)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Workshop 6',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // แท็บเมนู 2 แท็บ: บันทึกคะแนน / รายชื่อนักเรียน
    return const DefaultTabController(
      length: 2,
      child: Scaffold(
        body: TabBarView(
          children: [
            FormScreen(),
            DisplayScreen(),
          ],
        ),
        backgroundColor: Color.fromARGB(255, 49, 224, 157),
        bottomNavigationBar: TabBar(
          tabs: [
            Tab(text: "บันทึกคะแนน"),
            Tab(text: "รายชื่อนักเรียน"),
          ],
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          labelColor: Color.fromARGB(225, 255, 255, 255),
        ),
      ),
    );
  }
}