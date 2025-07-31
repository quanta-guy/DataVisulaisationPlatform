import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'models.dart';

Widget buildAppBarButton(IconData icon, String label, {VoidCallback? onPressed}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4.0),
    child: OutlinedButton.icon(
      onPressed: onPressed ?? () {}, // Use the provided onPressed or a default empty function
      icon: Icon(icon, color: Colors.black),
      label: Text(label, style: const TextStyle(color: Colors.black)),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        side: const BorderSide(color: Colors.black, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    ),
  );
}

Widget buildRealtimeDataCard({
  required String title,
  required String field,
  required Map<String, dynamic> machineData,
  required String unit,
  required IconData icon,
  required Color iconColor,
  Color? cardColor,
}) {
  // Extract the field value from machineData and parse it to a double.
  String fieldValue = machineData[field]?.toString() ?? 'Error';

  return SizedBox(
    width: 500,
    child: Card(
      elevation: 2,
      color: cardColor ?? Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "$fieldValue $unit",
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
            Icon(
              fieldValue == "Error" ? Icons.error : icon,
              color: fieldValue == "Error" ? Colors.red : iconColor,
              size: 40,
            ),
          ],
        ),
      ),
    ),
  );
}


  Widget buildObjectCountCard(machineData) {
    return Card(
      elevation: 1,
      color: Colors.orange[100],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Object Count',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              machineData['object_count']?.toString() ?? '0',
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }



  Widget buildPlaceholderWidget() {
    return Container(
      width: double.infinity,
      height: 300.0,
      color: Colors.grey[300],
      child: const Center(
        child: Text('Chart Placeholder'),
      ),
    );
  }

Widget buildChart(List<ChartData> chartData, Map<String, bool> selectedMachine) {

  return Card(
    elevation: 1.0,
    color: Colors.white,
    child: SizedBox(
      width: double.infinity,
      height: 350.0,
      child: SfCartesianChart(
        enableAxisAnimation: true,
        enableMultiSelection: true,
         legend: Legend(
          isVisible: true,         // Enable the legend
          position: LegendPosition.bottom, // Set legend position (optional)
          overflowMode: LegendItemOverflowMode.wrap, // Wrap legend items if they overflow
        ),
        primaryXAxis: DateTimeAxis(),
        series: _getChartSeries(chartData, selectedMachine), 
      ),
    ),
  );
}
List<CartesianSeries<ChartData, DateTime>> _getChartSeries(
  List<ChartData> chartData,
  Map<String, bool> selectedMachine,
) {
  if (selectedMachine['temperature'] == true && selectedMachine['current'] == true) {
    return <CartesianSeries<ChartData, DateTime>>[
      LineSeries<ChartData, DateTime>(
        dataSource: chartData,
        xValueMapper: (ChartData data, _) => data.time,
        yValueMapper: (ChartData data, _) => data.value,
        color: Colors.blue,
        name: 'Temperature', 
      ),
      LineSeries<ChartData, DateTime>(
        dataSource: chartData,
        xValueMapper: (ChartData data, _) => data.time,
        yValueMapper: (ChartData data, _) => data.value2,
        color: Colors.red,
        name: 'Current',
      ),
    ];
  } else if (selectedMachine['temperature'] == true) {
    return <CartesianSeries<ChartData, DateTime>>[
      LineSeries<ChartData, DateTime>(
        dataSource: chartData,
        xValueMapper: (ChartData data, _) => data.time,
        yValueMapper: (ChartData data, _) => data.value,
        color: Colors.blue,
        name: 'Temperature',
      ),
    ];
  } else if (selectedMachine['current'] == true) {
    return <CartesianSeries<ChartData, DateTime>>[
      LineSeries<ChartData, DateTime>(
        dataSource: chartData,
        xValueMapper: (ChartData data, _) => data.time,
        yValueMapper: (ChartData data, _) => data.value2, 
        color: Colors.red,
        name: 'Current',
      ),
    ];
  } else {
    // If none are selected, return an empty list or a default series
    return <CartesianSeries<ChartData, DateTime>>[];
  }
}


