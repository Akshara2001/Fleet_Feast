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

  // Controllers for text fields
  final TextEditingController _lastDateController = TextEditingController();
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  final TextEditingController _preferenceController = TextEditingController();
  final TextEditingController _unitIdController = TextEditingController();

  bool _showLeaveDetails = false;
  bool _isEditing = false;
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
          _preferenceController.text = data.preference;
          _unitIdController.text = data.unitId;
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

  void _updateUserData() async {
    try {
      DateTime? lastDate = _lastDateController.text.isNotEmpty
          ? DateFormat.yMMMd().parse(_lastDateController.text)
          : null;

      final updatedUser = User(
        name: _userData.name,
        phone: _userData.phone,
        preference: _preferenceController.text,
        unitId: _unitIdController.text,
        lastDate: _userData.lastDate, // Handle nullable value here
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
          _isEditing = false; // Exit editing mode
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
      firstDate: firstDate ?? DateTime.now(),
      lastDate: lastDate ?? DateTime(2100),
    );
    if (selectedDate != null) {
      setState(() {
        controller.text = DateFormat.yMMMd().format(selectedDate);
        if (controller == _fromDateController) {
          _fromDate = selectedDate;
          _toDateController.clear(); // Clear "To" date when "From" date changes
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
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Edit icon in the top right corner
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(
                      _isEditing ? Icons.done : Icons.edit,
                      color: Colors.blue,
                    ),
                    onPressed: () {
                      setState(() {
                        _isEditing = !_isEditing; // Toggle editing mode
                      });
                    },
                  ),
                ),

                const SizedBox(height: 20), // Spacing

                // User's name at the center
                Center(
                  child: Text(
                    userData.name,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8), // Spacing

                // User's phone and email center-aligned
                Center(
                  child: Column(
                    children: [
                      Text(
                        userData.phone,
                        style: const TextStyle(fontSize: 16.0),
                      ),
                      const SizedBox(height: 4), // Spacing
                      Text(
                        userData.email,
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20), // Spacing

                // Editable fields for preference, unit ID, and last date
                if (_isEditing) ...[
                  _buildUnderlinedInputField(
                      'Preference', _preferenceController),
                  SizedBox(height: 10),
                  _buildUnderlinedInputField('Unit ID', _unitIdController),
                  SizedBox(height: 10),
                  _buildUnderlinedInputField('Last Date', _lastDateController),
                ] else ...[
                  _buildInfoBox('Preference', _userData.preference),
                  SizedBox(height: 10),
                  _buildInfoBox('Unit ID', _userData.unitId),
                  SizedBox(height: 10),
                  _buildInfoBox('Last Date',
                      DateFormat.yMMMd().format(userData.lastDate)),
                ],

                SizedBox(height: 20), // Space between entries

                // Leave/Ty Dy Details section with dropdown
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
                          'Leave/Ty Dy Details',
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
                      firstDate: DateTime.now()), // Disable past dates
                  SizedBox(height: 10),
                  _buildDateField('To', _toDateController,
                      firstDate:
                          _fromDate), // Disable dates before the From date
                  SizedBox(height: 20),

                  // Save button
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 120.0,
                      height: 36.0,
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

                SizedBox(height: 20), // Space between entries

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
                        (Route<dynamic> route) => false,
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
      child: Text(
        value,
        style: const TextStyle(fontSize: 16.0),
      ),
    );
  }

  // Helper method to build an underlined TextField
  Widget _buildUnderlinedInputField(
      String label, TextEditingController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey), // Optional label color
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue), // Focused color
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey), // Default color
          ),
        ),
      ),
    );
  }

  // Helper method to build a date input field with calendar icon
  Widget _buildDateField(String label, TextEditingController controller,
      {DateTime? firstDate}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: UnderlineInputBorder(),
          suffixIcon: IconButton(
            icon: Icon(Icons.today),
            onPressed: () => _selectDate(controller, firstDate: firstDate),
          ),
        ),
        keyboardType: TextInputType.datetime,
      ),
    );
  }
}
