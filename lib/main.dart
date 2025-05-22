import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: info_form());
  }
}

class info_form extends StatefulWidget {
  const info_form({super.key});

  @override
  State<info_form> createState() => _info_formState();
}

class _info_formState extends State<info_form> {
  int _currentStep = 0;

  String savedName = '';
  String savedLName = '';
  String savedDOB = '';
  String savedPhone = '';
  String savedEmail = '';
  bool showData = false;

  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  DateTime? _dateSelection;

  final _nameController = TextEditingController();
  final _lnameController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  //method of shared_preferences for storing data
  Future<void> userInfoInput() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('name', _nameController.text);
    await prefs.setString('lname', _lnameController.text);
    await prefs.setString('dob', _dobController.text);
    await prefs.setString('phone', _phoneController.text);
    await prefs.setString('email', _emailController.text);

    print("User Information saved successfully!");
  }

  // method to load data
  Future<void> loaduserinfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedName = prefs.getString('name') ?? 'Name Not found!';
      savedLName = prefs.getString('lname') ?? 'Last Name not found!';
      savedDOB = prefs.getString('dob') ?? 'DOB not found';
      savedPhone = prefs.getString('phone') ?? 'Phone not found';
      savedEmail = prefs.getString('email') ?? 'Email not found';
      showData = true;
    });
  }

  // method for picking date
  Future<void> _datePicker() async {
    DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _dateSelection = picked;
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  // list of steps
  List<Step> _stepList() => [
    Step(
      title: Text(
        'Your Personal Information',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKeys[0],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? "Don't you have a name"
                            : null,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _lnameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? "Surely you have a Last Name 🤔"
                            : null,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _dobController,
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Select your Birth Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: _datePicker,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? "Okay, you should input your birth date! 🎂"
                            : null,
              ),
            ),
          ],
        ),
      ),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
    ),

    Step(
      title: Text(
        'Contact Information',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKeys[1],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Your Phone',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number!';
                  }
                  final number = int.tryParse(value);
                  if (number == null) {
                    return 'Invalid phone number!';
                  }
                  if (number <= 0) {
                    return 'Number must be greater.';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Your Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Type your email';
                  }
                  if (value.contains('@') & value.contains('.com')) {
                    return null;
                  } else {
                    return 'Your email is wrong!! 😒';
                  }
                },
              ),
            ),
          ],
        ),
      ),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
    ),
    Step(
      title: Text(
        'Confirm Your Information',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKeys[2],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Name: ${_nameController.text}'),
            Text('Last Name: ${_lnameController.text}'),
            Text('Date of Birth: ${_dobController.text}'),
            Text('Phone Number: ${_phoneController.text}'),
            Text('Email: ${_emailController.text}'),
          ],
        ),
      ),
      isActive: _currentStep >= 2,
      state: StepState.complete,
    ),
  ];

  // Next or Continue button
  void _onStepContinue() {
    if (_formKeys[_currentStep].currentState!.validate()) {
      if (_currentStep < 2) {
        setState(() => _currentStep += 1);
      } else {
        _submitForm();
      }
    }
  }

  // Cancel or Back button
  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  // Submit button
  void _submitForm() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Succeed 🙂'),
            content: Text('Information submitted successfully!'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  userInfoInput();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Data Saved Successfully!")),
                  );
                },
                child: Text('Okay'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Center(child: Text('Info_Form'))),
        body: Column(
          children: [
            Expanded(
              child: Stepper(
                currentStep: _currentStep,
                type: StepperType.vertical,
                steps: _stepList(),
                onStepContinue: _onStepContinue,
                onStepCancel: _onStepCancel,
                controlsBuilder: (context, detail) {
                  return Row(
                    children: [
                      ElevatedButton(
                        onPressed: detail.onStepContinue,
                        child: Text(
                          _currentStep == _stepList().length - 1
                              ? 'Finish'
                              : 'Next',
                        ),
                      ),
                      SizedBox(width: 8),
                      if (_currentStep > 0)
                        TextButton(
                          onPressed: detail.onStepCancel,
                          child: Text('Back'),
                        ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 14),
            ElevatedButton(
              onPressed: () {
                loaduserinfo();
              },
              child: Text('Previous Data'),
            ),
            SizedBox(height: 14),
            if (showData)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(),
                    Text(
                      "Previous Information:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Name: $savedName'),
                    Text('Last Name: $savedLName'),
                    Text('Date of Birth: $savedDOB'),
                    Text('Email: $savedEmail'),
                    Text('Phone Number: $savedPhone'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
