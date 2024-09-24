import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/screens/user_screens/user.dart';
import 'package:flutter_application_1/screens/user_screens/user_serivice.dart';
import 'package:flutter_application_1/utility/common.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/screens/user_screens/user_login.dart';
import 'package:flutter_application_1/theme/colors.dart';

class UserSignup extends StatelessWidget {
  const UserSignup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: <Widget>[
                      Container(
                        width: 42.0,
                        height: 42.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.orange200.withOpacity(0.4),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        color: Colors.white,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const UserLogin()),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 60.0),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text("Register",
                      style: TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.orange200,
                      )),
                  SizedBox(height: 3.0),
                  Text("Create your new account",
                      style: TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w100,
                        color: AppColors.grey,
                      )),
                ],
              ),
              const SizedBox(
                height: 50.0,
              ),
              const Column(
                children: <Widget>[
                  SignUpForm(),
                  SizedBox(
                    height: 10.0,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();

  String? _name;
  String? _mobileNumber;
  String? _email;
  String? _password;
  String? _unitId;
  TextEditingController _lastDayInUnit = TextEditingController();
  String? _preference;
  DateTime? _selectedDate;
  bool _rankError = false;
  bool _mobileError = false;
  bool _passwordError = false;
  bool _emailError = false;

  @override
  void initState() {
    super.initState();
    dataForUnitName;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          _buildNameField(),
          const SizedBox(height: 17.0),
          _buildMobileNumberField(),
          const SizedBox(height: 17.0),
          _buildEmailField(),
          const SizedBox(height: 17.0),
          _buildPasswordField(),
          const SizedBox(height: 17.0),
          _buildUnitIdField(),
          const SizedBox(height: 17.0),
          _buildLastDayInUnitPicker(context),
          const SizedBox(height: 17.0),
          _buildPreferenceDropdown(),
          const SizedBox(height: 50.0),
          _buildSignUpButton(),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Name',
        errorText: _rankError ? 'Name should not include rank' : null,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your name';
        }
        if (value
            .toLowerCase()
            .contains(RegExp(r'\b(slt|lt|lt cdr|cdr|capt|cmde)\b'))) {
          setState(() {
            _rankError = true;
          });
          return 'Name should not include rank';
        }
        setState(() {
          _rankError = false;
        });
        return null;
      },
      onSaved: (value) => _name = value,
    );
  }

  Widget _buildMobileNumberField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Mobile Number',
        errorText:
            _mobileError ? 'Please enter a valid 10-digit mobile number' : null,
      ),
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your mobile number';
        }
        String cleaned = value.replaceAll(RegExp(r'\D'), '');
        if (cleaned.length != 10) {
          setState(() {
            _mobileError = true;
          });
          return 'Mobile number should have exactly 10 digits';
        }
        setState(() {
          _mobileError = false;
        });
        return null;
      },
      onSaved: (value) => _mobileNumber = value,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Password',
        errorText: _mobileError ? 'Please enter a valid Password' : null,
      ),
      keyboardType: TextInputType.visiblePassword,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your Password';
        }

        // String passwordPattern =
        //     r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
        // RegExp regex = RegExp(passwordPattern);

        // if (!regex.hasMatch(value)) {
        //   // If the email doesn't match the pattern, show an error
        //   return 'Please enter a valid Password';
        // }
        setState(() {
          _passwordError = false;
        });
        return null;
      },
      onSaved: (value) => _password = value,
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Email',
        errorText: _mobileError ? 'Please enter a valid Email' : null,
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }

        // Email regex pattern for basic validation
        String emailPattern =
            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
        RegExp regex = RegExp(emailPattern);

        if (!regex.hasMatch(value)) {
          // If the email doesn't match the pattern, show an error
          return 'Please enter a valid email address';
        }
        setState(() {
          _emailError = false;
        });
        return null;
      },
      onSaved: (value) => _email = value,
    );
  }

  Widget _buildUnitIdField() {
    return SizedBox(
        width: double.infinity,
        child: DropdownMenu(
          expandedInsets: EdgeInsets.zero,
          // width: double.infinity,
          label: const Text("Unit Name"),
          onSelected: (preference) {
            if (preference != null) {
              setState(() {
                _unitId = preference;
              });
            }
          },
          textStyle: const TextStyle(
            fontSize: 13.0,
          ),
          menuStyle: const MenuStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.white)),
          dropdownMenuEntries: allUnitNames,
        ));
  }

  Widget _buildLastDayInUnitPicker(BuildContext context) {
    return TextField(
      readOnly: true,
      controller: _lastDayInUnit,
      decoration: InputDecoration(
        labelText: "Last day in Unit",
        suffixIcon: Icon(
          Icons.today,
          color: AppColors.orange200.withOpacity(0.8),
        ),
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          setState(() {
            _selectedDate = pickedDate;
            String formattedDate = DateFormat('dd-MM-yy').format(pickedDate);
            _lastDayInUnit.text = formattedDate;
          });
        }
      },
    );
  }

  Widget _buildPreferenceDropdown() {
    return SizedBox(
        width: double.infinity,
        child: DropdownMenu(
          expandedInsets: EdgeInsets.zero,
          // width: double.infinity,
          label: const Text("Preference"),
          onSelected: (preference) {
            if (preference != null) {
              setState(() {
                _preference = preference;
              });
            }
          },
          textStyle: const TextStyle(
            fontSize: 13.0,
          ),
          menuStyle: const MenuStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.white)),
          dropdownMenuEntries: const <DropdownMenuEntry<String>>[
            DropdownMenuEntry(
                value: "veg",
                label: "Vegetarian",
                leadingIcon: Icon(
                  Icons.ramen_dining,
                  color: Colors.green,
                )),
            DropdownMenuEntry(
                value: "nonveg",
                label: "Non-Vegetarian",
                leadingIcon: Icon(
                  Icons.set_meal,
                  color: Colors.red,
                )),
          ],
        ));
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      height: 40.0,
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();

            User user = User(
              name: _name ?? "",
              phone: _mobileNumber ?? "",
              password: _password ?? "",
              email: _email ?? "",
              preference: _preference ?? "",
              unitId: _unitId ?? "",
              lastDate: _selectedDate ?? DateTime(2024, 1, 1),
            );
            final UserService userService = UserService();
            var isSuccess = await userService.addUser(user);

            if (isSuccess != null) {
              // Show success dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Success'),
                    content: const Text(
                        'Verification mail has been sent to the registered email ID.'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Dismiss the dialog
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const UserLogin()),
                          );
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            } else {
              // Show error dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Error'),
                    content:
                        const Text('Failed to register. Please try again.'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Dismiss the dialog
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            }
          }
        },
        child: const Text(
          'Sign Up',
          style: TextStyle(
            fontSize: 13.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
