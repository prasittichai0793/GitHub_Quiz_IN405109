import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:quiz_in405109/screen/signin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF03a9f4)),
        useMaterial3: true,
      ),
      home: const SigninScreen(),
    );
  }
}

class ExpenseTrackerApp extends StatefulWidget {
  const ExpenseTrackerApp({super.key});

  @override
  State<ExpenseTrackerApp> createState() => _ExpenseTrackerAppState();
}

class _ExpenseTrackerAppState extends State<ExpenseTrackerApp> {
  late TextEditingController _amountController;
  late TextEditingController _dateController;
  late TextEditingController _typeController;
  late TextEditingController _noteController;

  double totalIncome = 0;
  double totalExpense = 0;

  final List<String> _transactionTypes = ['Income', 'Expense'];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _dateController = TextEditingController();
    _typeController = TextEditingController();
    _noteController = TextEditingController();
    _calculateTotals();
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SigninScreen()),
    );
  }

  void addTransactionHandle(BuildContext context, [DocumentSnapshot? doc]) {
    if (doc != null) {
      _amountController.text = doc['amount'].toString();
      _dateController.text = doc['date'];
      _typeController.text = doc['type'];
      _noteController.text = doc['note'];
    } else {
      _amountController.clear();
      _dateController.clear();
      _typeController.clear();
      _noteController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                doc != null ? Icons.edit : Icons.add,
                color: const Color(0xFF259b24),
              ),
              const SizedBox(width: 8),
              Text(
                doc != null ? "Edit Transaction" : "Add Transaction",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SizedBox(
              width: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Amount",
                      prefixIcon: Icon(Icons.money),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    readOnly: true,
                    controller: _dateController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Date (YYYY-MM-DD)",
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );

                      if (selectedDate != null) {
                        _dateController.text =
                            "${selectedDate.toLocal()}".split(' ')[0];
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _typeController.text.isNotEmpty
                        ? _typeController.text
                        : null,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Type",
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: _transactionTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _typeController.text = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Note",
                      prefixIcon: Icon(Icons.note),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFFF44336),
              ),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_amountController.text.isEmpty ||
                    _dateController.text.isEmpty ||
                    _typeController.text.isEmpty ||
                    _noteController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please fill out all fields."),
                    ),
                  );
                  return;
                }

                if (doc != null) {
                  FirebaseFirestore.instance
                      .collection(FirebaseAuth.instance.currentUser!.email!)
                      .doc(doc.id)
                      .update({
                    'amount': double.parse(_amountController.text),
                    'date': _dateController.text,
                    'type': _typeController.text,
                    'note': _noteController.text,
                  }).then((_) {
                    print("Transaction updated");
                    _calculateTotals();
                  }).catchError((onError) {
                    print("Failed to update transaction");
                  });
                } else {
                  FirebaseFirestore.instance
                      .collection(FirebaseAuth.instance.currentUser!.email!)
                      .add({
                    'amount': double.parse(_amountController.text),
                    'date': _dateController.text,
                    'type': _typeController.text,
                    'note': _noteController.text,
                  }).then((res) {
                    print("Transaction added");
                    _calculateTotals();
                  }).catchError((onError) {
                    print("Failed to add transaction");
                  });
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
              ),
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void deleteTransaction(String id) {
    FirebaseFirestore.instance
        .collection(FirebaseAuth.instance.currentUser!.email!)
        .doc(id)
        .delete()
        .then((_) {
      print("Transaction deleted");
      _calculateTotals();
    }).catchError((onError) {
      print("Failed to delete transaction");
    });
  }

  void _calculateTotals() {
    totalIncome = 0;
    totalExpense = 0;

    FirebaseFirestore.instance
        .collection(FirebaseAuth.instance.currentUser!.email!)
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        if (doc['type'].toLowerCase() == 'income') {
          totalIncome += doc['amount'];
        } else if (doc['type'].toLowerCase() == 'expense') {
          totalExpense += doc['amount'];
        }
      }
      setState(() {});
    });
  }

  Future<List<FlSpot>> getChartData() async {
    List<FlSpot> spots = [];
    List<DocumentSnapshot> transactions = [];

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection(FirebaseAuth.instance.currentUser!.email!)
        .get();
    transactions = snapshot.docs;

    for (int i = 0; i < transactions.length; i++) {
      double amount = transactions[i]['amount'];
      String type = transactions[i]['type'];

      if (type.toLowerCase() == 'income') {
        spots.add(FlSpot(i.toDouble(), amount));
      } else if (type.toLowerCase() == 'expense') {
        spots.add(FlSpot(i.toDouble(), -amount));
      }
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense Tracker"),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(FirebaseAuth.instance.currentUser!.email!)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot doc = snapshot.data!.docs[index];
                    return ListTile(
                      title: Text("Amount: ${doc['amount']}"),
                      subtitle: Text("Date: ${doc['date']}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => deleteTransaction(doc.id),
                      ),
                      onTap: () => addTransactionHandle(context, doc),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total Income: $totalIncome"),
                Text("Total Expense: $totalExpense"),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              addTransactionHandle(context);
            },
            child: const Text("Add Transaction"),
          ),
          SizedBox(
            height: 200,
            child: FutureBuilder<List<FlSpot>>(
              future: getChartData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) {
                  return const Center(child: Text("No data available"));
                }

                return LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    minX: 0,
                    maxX: snapshot.data!.length.toDouble(),
                    minY: -totalExpense,
                    maxY: totalIncome,
                    lineBarsData: [
                      LineChartBarData(
                        spots: snapshot.data!,
                        isCurved: true,
                        // colors: [Colors.blue],
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
