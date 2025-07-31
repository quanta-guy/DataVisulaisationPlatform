import 'package:app/contact_admin.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';
import 'dart:io';
import 'dart:html' as html;
import 'dart:async';
import 'dart:typed_data';
import 'widget.dart';
import 'models.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:csv/csv.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
    ScreenshotController screenshotController = ScreenshotController();

  String selectedMachine = '';
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final String? userId = FirebaseAuth.instance.currentUser?.uid;
  bool isAdmin = false;

  Map<String, bool> selectedParameters = {
  'temperature': false,
  'current': false,
};

 Future<void> generateReport() async {
    await fetchMachineData(selectedMachine);

     downloadCSV();

     downloadChartImage();
  }
 void showAlertPopup() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Contact Admin'),
            content: Text('Please contact admin for access'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Dismiss the popup
                },
              ),
            ],
          );
        },
      );
    }
  void downloadChartImage() async {
    screenshotController.capture().then((Uint8List? image) {
      if (image != null) {
        final blob = html.Blob([image]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", "chart_image.png")
          ..click();
        html.Url.revokeObjectUrl(url);
      }
    }).catchError((onError) {
      print(onError);
    });
  }

  Future<void> checkAdminStatus() async {
    if (userId != null) {
      try {
        // Fetch the document for the current user
        DocumentSnapshot userDoc = await db.collection('uid').doc(userId).get();

        // Check if the 'admin' field is true
        if (userDoc.exists && userDoc.get('admin') == true) {
          setState(() {
            isAdmin = true;
          });
        }
      } catch (e) {
        print("Error checking admin status: $e");
      }
    }
    setState(() {
isAdmin=false;
    });
  }

   void downloadCSV() {
    List<List<dynamic>> rows = [
      ["Timestamp", "Current", "Temperature"],
      for (var data in chartData)
        [data.time.toString(), data.value.toString(), data.value2.toString()]
    ];
    
    String csv = const ListToCsvConverter().convert(rows);
    final bytes = utf8.encode(csv);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "chart_data.csv")
      ..click();
    html.Url.revokeObjectUrl(url);
  }

 Future<void> captureAndSaveChartAsImage() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/chart_image.png';

    screenshotController.capture().then((image) async {
      if (image != null) {
        final file = File(path);
        await file.writeAsBytes(image);
        print('Chart saved as image at $path');
      }
    }).catchError((error) {
      print('Error capturing chart: $error');
    });
  }
Future<void> saveChartDataAsCSV() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/chart_data.csv';

    List<List<dynamic>> rows = [
      ["Timestamp", "Current", "Temperature"]
    ];

    for (var data in chartData) {
      rows.add([data.time.toIso8601String(), data.value, data.value2]);
    }

    String csvData = const ListToCsvConverter().convert(rows);
    final file = File(path);
    await file.writeAsString(csvData);

    print('Chart data saved as CSV at $path');
  }


  final User? currentUser = FirebaseAuth.instance.currentUser;

  List<String> machineNames = [];
  Map<String, dynamic> machineData = {};
  List<ChartData> chartData = [];
  Timer? _chartUpdateTimer;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      machineDataSubscription;
    bool machineOn = false;
  String rtStatus = "unknown";
  double rtTemperature = 0;
List<Map<String, String>> alarmLogs = [];
bool alarm1=false;
bool alarm2=false;
  final _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    fetchMachineNames();
      _chartUpdateTimer = Timer.periodic(Duration(seconds: 20), (timer) {
      fetchMachineData(selectedMachine);
    });
  }

  @override
  void dispose() {
    machineDataSubscription?.cancel();
    super.dispose();
  }

  Future<void> fetchMachineNames() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('test').get();

      List<String> fetchedMachineNames =
          querySnapshot.docs.map((doc) => doc.id).toList();

      if (fetchedMachineNames.isNotEmpty) {
        setState(() {
          machineNames = fetchedMachineNames;
          selectedMachine = machineNames[0];
          fetchMachineData(selectedMachine);
          subscribeToRealtimeUpdates(selectedMachine);
          
        });
      }
    } catch (e) {
      print("Error fetching machine names: $e");
    }
  }
 void showAlarmOverlay(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Active Alarms'),
          content: SingleChildScrollView(
            child: Column(
              children: alarmLogs
                  .map((log) => ListTile(
                        title: Text(log["alarm"] ?? ""),
                        subtitle: Text("Time: ${log["timestamp"] ?? ""}"),
                      ))
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
  Widget buildAlarmButton() {
    return OutlinedButton.icon(
      onPressed:  () {showAlarmOverlay(context);}, // Use the provided onPressed or a default empty function
      icon: Icon(Icons.add_alert, color: Colors.black),
      label: Text('Alarm', style: const TextStyle(color: Colors.black)),
      style: OutlinedButton.styleFrom(
        backgroundColor: alarm1 || alarm2?Colors.red:Colors.white,
        side: const BorderSide(color: Colors.black, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }

  
  void subscribeToRealtimeUpdates(String machineName) {
    machineDataSubscription?.cancel();
    if (machineDataSubscription != null) {
      machineDataSubscription!.cancel();
    }

    machineDataSubscription = _firestoreService
        .getRealTimeMachineData(machineName)
        .listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          machineData = snapshot.data() ?? {};
          machineOn=snapshot.data()?['machine_on']=='True'?true:false;
          bool newAlarm1 = snapshot.data()?['alarm_1']=='True'?true :false;
          bool newAlarm2 = snapshot.data()?['alarm_2'] =='True'?true :false;

          if (newAlarm1 && !alarm1) {
            alarmLogs.add({
              "alarm": "Alarm 1",
              "timestamp": DateTime.now().toString(),
            });
          }
          if (newAlarm2 && !alarm2) {
            alarmLogs.add({
              "alarm": "Alarm 2",
              "timestamp": DateTime.now().toString(),
            });
          }

          // Update the alarm states
          alarm1 = newAlarm1;
          alarm2 = newAlarm2;
        
        });
      }
    });
  }



Future<void> fetchMachineData(String machineName) async {
  try {
    
    // Replace with your FastAPI server URL
    final String baseUrl = 'http://127.0.0.1:8000';

    // Fetch CSV data from the FastAPI endpoint
    final response = await http.get(Uri.parse('$baseUrl/csvdata'));
    if (response.statusCode == 200) {

      Map<String, dynamic> csvData = jsonDecode(response.body);
      print(csvData);
      if (csvData.containsKey(selectedMachine)) {
        List<dynamic> timestamps = csvData[machineName]['timestamp']; 
        List<dynamic> values = csvData[machineName]['current']; // Replace 'value' with your actual value column name
        List<dynamic> values2 = csvData[machineName]['temperature']; // Replace 'value' with your actual value column name

        List<ChartData> data = [];
        for (int i = 0; i < timestamps.length; i++) {
          DateTime time = DateTime.parse(timestamps[i]); 
          double value = double.parse(values[i].toString());
          double value2= double.parse(values2[i].toString());
          data.add(ChartData(time, value,value2));
        }

        // Update the state with the fetched data
        setState(() {
          chartData = data;
        });
      } else {
        print('Machine data not found for $machineName');
      }
    } else {
      print('Failed to fetch data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching machine data: $e');
  }
}
void showParameterSelectionDialog(BuildContext context, Map<String, bool> selectedParameters) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setStateDialog) {
          return AlertDialog(
            title: Text('Select Parameters'),
            content: SingleChildScrollView(
              child: Column(
                children: selectedParameters.keys.map((String key) {
                  return CheckboxListTile(
                    title: Text(key),
                    value: selectedParameters[key],
                    onChanged: (bool? value) {
                      setStateDialog(() {
                        selectedParameters[key] = value ?? false;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  
                  setState(() {
                    
                    fetchMachineData(selectedMachine); 
                  });
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Dashboard', style: TextStyle(color: Colors.black)),
        actions: [
          buildAppBarButton(Icons.home, 'Home'),
           buildAppBarButton(
          Icons.edit,
          'Edit',
          onPressed: () => isAdmin?showParameterSelectionDialog(
            context,
           selectedParameters
          ):showAlertPopup(),
        ),
           buildAppBarButton(Icons.assessment, 'Reports', onPressed:()=>isAdmin?generateReport():showAlertPopup()),
           buildAlarmButton(),
        ],
      ),
      backgroundColor: Colors.white,
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        const Text('Select Machine: ',
                            style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 20),
                        _buildMachineDropdown(),
                      ],
                    ),
                  ),
                  SizedBox(
                      height: 100, width: 250, child: buildObjectCountCard(machineData)),
                  const SizedBox(height: 20),
                  SizedBox(width: 250, child: _buildMachineStatusToggleCard()),
                  SizedBox(height:50),
                  SizedBox(
                     height: 120, width: 250,
                    child: buildRealtimeDataCard(
                          field: "coolant_level",
                          title: "Coolant Level",
                          icon: Icons.check,
                          iconColor: Colors.green,
                          machineData: machineData,
                          unit: "%",
                          cardColor: Colors.orange[100]),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        buildRealtimeDataCard(
                            field: "temperature",
                            title: "Temprature",
                            icon: Icons.check,
                            iconColor: Colors.green,
                            machineData: machineData,
                            unit: "\u00B0C",
                            cardColor:Colors.white),
                            buildRealtimeDataCard(
                          field: "current",
                          title: "Current",
                          icon: Icons.check,
                          iconColor: Colors.green,
                          machineData: machineData,
                          unit: "A",
                          cardColor: Colors.white),
                  
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    const SizedBox(height: 20),
                    chartData.isNotEmpty
                        ? Screenshot(controller:screenshotController,child: buildChart(chartData,selectedParameters))
                        : buildPlaceholderWidget(),
                  ],
                ),
              ),
              const SizedBox(width: 200),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildMachineDropdown() {
    return DropdownButton<String>(
      value: selectedMachine,
      items: machineNames.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedMachine = newValue!;
          fetchMachineData(selectedMachine); 
          subscribeToRealtimeUpdates(selectedMachine);
        });
      },
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: Colors.black,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName:
                  const Text('admin', style: TextStyle(color: Colors.white)),
              accountEmail: Text(currentUser?.email ?? 'No Email',
                  style: const TextStyle(color: Colors.white70)),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.black),
              ),
              decoration: const BoxDecoration(color: Colors.black),
            ),
            _buildDrawerTile(Icons.person, 'Username', () {}),
            _buildDrawerTile(Icons.notifications, 'Notifications', () {}),
            _buildDrawerTile(Icons.devices, 'Manage Devices', () {}),
            _buildDrawerTile(Icons.people, 'Manage Users', () {}),
            const Divider(color: Colors.white54),
            _buildDrawerTile(Icons.logout, 'Logout', () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.of(context).pushReplacementNamed('/login');
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerTile(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }


Widget _buildMachineStatusToggleCard() {
  return Card(
    elevation: 1,
    color: machineOn ? Colors.green[200] : Colors.red[200],
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Machine Status',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
         Switch(value: machineOn, onChanged:(value) {
           
         },)
        ],
      ),
    ),
  );
}
}

