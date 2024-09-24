import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/user_screens/user.dart';
import 'package:flutter_application_1/screens/user_screens/user_login.dart';
import 'package:flutter_application_1/screens/user_screens/user_serivice.dart';
import 'package:flutter_application_1/theme/colors.dart';
import 'package:flutter_application_1/utility/common.dart';
import 'package:intl/intl.dart'; // For date formatting

// Simulate fetching user data asynchronously
Future<User?> fetchUserData() async {
  Map<String, dynamic>? data = await getUserDataFromLocal();
  String? email = data?['email'];
  final UserService userService = UserService();
  User? user = await userService.getUser(email!);
  return user;
}

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile>
    with TickerProviderStateMixin {
  late Future<User?> _userDataFuture;
  bool _isLoading = true;
  String _errorMessage = '';
  late User _userData;
  final TextEditingController _lastDateController = TextEditingController();
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  bool _showLeaveDetails = false;
  DateTime? _fromDate;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _fetchUserData();
  }

  Future<User?> _fetchUserData() async {
    try {
      final data = await fetchUserData();
      if (data != null) {
        setState(() {
          _userData = data;
          _lastDateController.text = DateFormat.yMMMd().format(data.lastDate);
          _fromDateController.text = data.fromDate != null
              ? DateFormat.yMMMd().format(data.fromDate!)
              : '';
          _toDateController.text = data.toDate != null
              ? DateFormat.yMMMd().format(data.toDate!)
              : '';
          _fromDate = data.fromDate;
          _isLoading = false;
        });
      }
      return data;
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load data';
      });
      rethrow; // Propagate the error
    }
  }

  // void _updateUserData() async {
  //   try {
  //     final updatedUser = User(
  //       name: _userData.name,
  //       phone: _userData.phone,
  //       preference: _userData.preference,
  //       unitId: _userData.unitId,
  //       lastDate: _userData.lastDate,
  //       fromDate: _fromDateController.text.isNotEmpty
  //           ? DateFormat.yMMMd().parse(_fromDateController.text)
  //           : null,
  //       toDate: _toDateController.text.isNotEmpty
  //           ? DateFormat.yMMMd().parse(_toDateController.text)
  //           : null,
  //       email: _userData.email,
  //       password: _userData.password,
  //       isApproved: _userData.isApproved,
  //     );

  //     final UserService userService = UserService();
  //     bool success = await userService.updateUser(updatedUser);

  //     if (success) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Profile updated successfully')),
  //       );
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to update profile')),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to update profile')),
  //     );
  //   }
  // }

  void _updateUserData() async {
    try {
      final updatedUser = User(
        name: _userData.name,
        phone: _userData.phone,
        preference: _userData.preference,
        unitId: _userData.unitId,
        lastDate: _userData.lastDate,
        fromDate: _fromDateController.text.isNotEmpty
            ? DateFormat.yMMMd().parse(_fromDateController.text)
            : null,
        toDate: _toDateController.text.isNotEmpty
            ? DateFormat.yMMMd().parse(_toDateController.text)
            : null,
        email: _userData.email,
        password: _userData.password,
        isApproved: _userData.isApproved,
      );

      final UserService userService = UserService();
      bool success = await userService.updateUser(updatedUser);

      if (success) {
        setState(() {
          _showLeaveDetails = false; // Automatically close dropdown
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile')),
      );
    }
  }

  void _selectDate(TextEditingController controller,
      {DateTime? firstDate, DateTime? lastDate}) async {
    DateTime initialDate = DateTime.now();
    if (controller == _fromDateController && _fromDate != null) {
      initialDate = _fromDate!;
    } else if (controller == _toDateController && _fromDate != null) {
      initialDate = _fromDate!;
    }

    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime.now(), // Default to now for "From" date
      lastDate: lastDate ?? DateTime(2100),
    );
    if (selectedDate != null) {
      setState(() {
        controller.text = DateFormat.yMMMd().format(selectedDate);
        if (controller == _fromDateController) {
          _fromDate = selectedDate;
          // Ensure "To" date is reset if "From" date changes
          _toDateController.clear();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _userDataFuture,
      builder: (context, snapshot) {
        if (_isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text(_errorMessage));
        }

        if (!snapshot.hasData) {
          return Center(child: Text('No data available'));
        }

        final userData = snapshot.data!;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Heading with underline
                const Text(
                  'Profile',
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: 28.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),

                // Display user information
                _buildInfoBox('Name', userData.name),
                _buildInfoBox('Phone', userData.phone),
                _buildInfoBox('Email', userData.email),
                _buildInfoBox('Preference', userData.preference),
                _buildInfoBox('Unit ID',
                    userData.unitId), // Display Unit ID as a simple text
                SizedBox(height: 10),

                // Last Date section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: _lastDateController,
                    decoration: InputDecoration(
                      labelText: 'Last Date',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.today),
                        onPressed: () => _selectDate(_lastDateController),
                      ),
                    ),
                    keyboardType: TextInputType.datetime,
                    onSubmitted: (value) => _updateUserData(),
                  ),
                ),

                SizedBox(height: 20),

                // Leave/ Ty Dy Details section with dropdown
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showLeaveDetails = !_showLeaveDetails;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Leave/ Ty Dy Details',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      Icon(
                        _showLeaveDetails
                            ? Icons.expand_less
                            : Icons.expand_more,
                      ),
                    ],
                  ),
                ),
                if (_showLeaveDetails) ...[
                  SizedBox(height: 10),
                  _buildDateField('From', _fromDateController,
                      firstDate: DateTime.now(), // Disable past dates
                      lastDate: null),
                  SizedBox(height: 10),
                  _buildDateField('To', _toDateController,
                      firstDate:
                          _fromDate, // Disable dates before the From date
                      lastDate: null),

                  SizedBox(height: 20),

                  // Save button
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 120.0, // Adjust the width as needed
                      height: 36.0, // Adjust the height as needed
                      child: ElevatedButton(
                        onPressed: _updateUserData,
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

                SizedBox(height: 20),

                // Logout button
                SizedBox(
                  width: double.infinity,
                  height: 40.0,
                  child: ElevatedButton(
                    onPressed: () {
                      clearUserDataOfLocal();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UserLogin()),
                        (Route<dynamic> route) =>
                            false, // This removes all previous routes
                      );
                    },
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method to build a box for text information
  Widget _buildInfoBox(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: TextEditingController(text: value),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        readOnly: true,
      ),
    );
  }

  // Helper method to build a date input field with calendar icon
  Widget _buildDateField(String label, TextEditingController controller,
      {DateTime? firstDate, DateTime? lastDate}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: Icon(Icons.today),
            onPressed: () => _selectDate(controller,
                firstDate: firstDate, lastDate: lastDate),
          ),
        ),
        keyboardType: TextInputType.datetime,
      ),
    );
  }
}
