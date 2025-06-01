import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseSetup {
  static Future<void> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyCYM6TfAcQLqzToADmn9A_HAN9SnlPwFtM",
            appId: "1:197959029284:android:47cf245f208f1eb60d4fcf",
            messagingSenderId: "197959029284",
            projectId: "carparking-bd3ce",
            databaseURL:
                "https://carparking-bd3ce-default-rtdb.asia-southeast1.firebasedatabase.app",
          ),
        );
      } else {
        Firebase.app();
      }
    } catch (e) {
      print("Firebase initialization error: $e");
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseSetup.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Parking Realtime Viewer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ParkingStatusScreen(),
    );
  }
}

class ParkingStatusScreen extends StatefulWidget {
  const ParkingStatusScreen({super.key});

  @override
  State<ParkingStatusScreen> createState() => _ParkingStatusScreenState();
}

class _ParkingStatusScreenState extends State<ParkingStatusScreen> {
  late final DatabaseReference _parkingRef;

  int availableSpaces = 0;
  String entryGate = "Closed";
  String exitGate = "Closed";
  String carDetected = "None";
  String status = "Loading...";

  @override
  void initState() {
    super.initState();

    _parkingRef = FirebaseDatabase.instance.ref("parking");

    _parkingRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        setState(() {
          availableSpaces = data["availableSpaces"] ?? 0;
          entryGate = (data["entryGate"] == 1) ? "Open" : "Closed";
          exitGate = (data["exitGate"] == 1) ? "Open" : "Closed";
          carDetected = data["carDetected"] ?? "None";
          status = data["status"] ?? "Unknown";
        });
      } else {
        setState(() {
          status = "No data available";
        });
      }
    }, onError: (error) {
      setState(() {
        status = "Error: $error";
      });
    });
  }

  Widget buildInfoCard(String title, String value, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontSize: 18)),
        trailing: Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: color,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text("Realtime Viewer"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          buildInfoCard("Available Slots", availableSpaces.toString(), Colors.green),
         // buildInfoCard("Entry Gate", entryGate, entryGate == "Open" ? Colors.green : Colors.red),
         // buildInfoCard("Exit Gate", exitGate, exitGate == "Open" ? Colors.green : Colors.red),
          //buildInfoCard("Car Detected", carDetected, Colors.orange),
          buildInfoCard("Parking Status", status, status == "Parking Full" ? Colors.red : Colors.green),
        ],
      ),
    );
  }
}