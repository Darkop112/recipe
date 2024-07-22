import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI Application',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.deepPurple,
        ),
      ),
      home: const BMICalculator(title: 'BMI Calculator'),
    );
  }
}

class BMICalculator extends StatefulWidget {
  const BMICalculator({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _BMICalculatorState createState() => _BMICalculatorState();
}

class _BMICalculatorState extends State<BMICalculator> {
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  double bmiResult = 0.0;
  String bmiCategory = '';

  @override
  void initState() {
    super.initState();
    loadSavedData();
  }

  void loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      bmiResult = prefs.getDouble('bmiResult') ?? 0.0;
      bmiCategory = prefs.getString('bmiCategory') ?? '';
    });
  }

  void saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('bmiResult', bmiResult);
    prefs.setString('bmiCategory', bmiCategory);
  }

  void calculateBMI() {
    if (_formKey.currentState!.validate()) {
      double weight = double.parse(weightController.text);
      double height = double.parse(heightController.text);
      double bmi = weight / ((height / 100) * (height / 100));

      setState(() {
        bmiResult = bmi;
        if (bmi < 18.5) {
          bmiCategory = 'A BMI of less than 18.5 suggests underweight.';
        } else if (bmi >= 18.5 && bmi < 25) {
          bmiCategory =
              'A BMI of between 18.5 and 24.9 suggests a healthy weight range.';
        } else if (bmi >= 25 && bmi < 30) {
          bmiCategory = 'A BMI of between 25 and 29.9 may indicate overweight.';
        } else {
          bmiCategory = 'A BMI of 30 or higher may indicate obesity.';
        }
      });

      saveData();
    }
  }

  void clearData() {
    setState(() {
      weightController.text = '';
      heightController.text = '';
      bmiResult = 0.0;
      bmiCategory = '';
    });

    saveData();
  }

  @override
  void dispose() {
    weightController.dispose();
    heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  border: Border.all(width: 1.0, color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: weightController,
                        decoration: const InputDecoration(
                          labelText: 'Weight (kg)',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your weight.';
                          }
                          double weight = double.parse(value);
                          if (weight < 10) {
                            return 'Weight should be greater than or equal to 10.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        controller: heightController,
                        decoration: const InputDecoration(
                          labelText: 'Height (cm)',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your height.';
                          }
                          double height = double.parse(value);
                          if (height < 50) {
                            return 'Height should be greater than or equal to 50.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: calculateBMI,
                            child: const Text('Calculate BMI'),
                          ),
                          const SizedBox(width: 16.0),
                          ElevatedButton(
                            onPressed: clearData,
                            child: const Text('Clear Data'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              decoration: BoxDecoration(
                border: Border.all(width: 1.0, color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                children: [
                  Text(
                    'BMI Result: $bmiResult',
                    style: const TextStyle(fontSize: 24.0),
                  ),
                  Text(
                    'BMI Category: $bmiCategory',
                    style: const TextStyle(fontSize: 24.0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
