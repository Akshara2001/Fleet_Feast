import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/colors.dart';
import 'package:intl/intl.dart'; // For date formatting

class UserFeedback extends StatefulWidget {
  const UserFeedback({super.key});

  @override
  _UserFeedbackState createState() => _UserFeedbackState();
}

class _UserFeedbackState extends State<UserFeedback> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedMeal;
  List<String> _menuItems = []; // To store menu items

  final List<String> _mealOptions = ['breakfast', 'lunch', 'dinner'];

  // Additional variables to store user information
  String? _unitId;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo(); // Fetch user info on init
  }

  @override
  void dispose() {
    _dateController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserInfo() async {
    // Get the current user's email from FirebaseAuth
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // Handle the case where there is no user signed in
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user signed in')),
      );
      return;
    }

    String userEmail = currentUser.email!;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userEmail)
        .get();

    if (userDoc.exists) {
      setState(() {
        _unitId = userDoc['unit_id'];
        _userName = userDoc['name'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User data not found')),
      );
    }
  }

  Future<void> _selectDate() async {
    DateTime now = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: now, // Restrict to today and previous dates
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
        _dateController.text = formattedDate;
      });
    }
  }

  Future<void> _fetchMenuItems() async {
    if (_selectedMeal == null || _selectedDate == null) return;

    try {
      // Format the date to match the format used in Firestore
      final formattedDate = DateFormat('dd-MM-yyyy').format(_selectedDate!);

      // Query the daily_menus collection where the date field matches the formatted date
      final querySnapshot = await FirebaseFirestore.instance
          .collection('daily_menus')
          .where('date', isEqualTo: formattedDate)
          .limit(1) // Assuming there will be only one document per date
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final menuDoc =
            querySnapshot.docs.first; // Get the first document from the query

        List<String> items = [];
        switch (_selectedMeal) {
          case 'breakfast':
            items = List<String>.from(menuDoc['breakfast'] ?? []);
            break;
          case 'lunch':
            items = List<String>.from(menuDoc['lunch'] ?? []);
            break;
          case 'dinner':
            items = List<String>.from(menuDoc['dinner'] ?? []);
            break;
          default:
            break;
        }
        setState(() {
          _menuItems = items;
        });
      } else {
        setState(() {
          _menuItems
              .clear(); // Clear menu items if no document matches the date
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No menu items found for the selected date')),
        );
      }
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch menu items')),
      );
    }
  }

  String _getDayOfWeek(DateTime date) {
    return DateFormat('EEE').format(date);
  }

  Future<void> _submitFeedback() async {
    final feedbackCollection =
        FirebaseFirestore.instance.collection('feedback');

    try {
      await feedbackCollection.add({
        'date': _selectedDate != null
            ? DateFormat('dd-MM-yyyy').format(_selectedDate!)
            : null,
        'day': _selectedDate != null ? _getDayOfWeek(_selectedDate!) : null,
        'feedback': _feedbackController.text,
        'meal_name': _selectedMeal,
        'menu_item': _menuItems,
        'unit_id': _unitId, // Add unit_id
        'user_name': _userName, // Add user_name
      });

      // Optionally show a success message or navigate to another screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Feedback submitted successfully')),
      );

      // Clear the fields after submission
      _dateController.clear();
      _feedbackController.clear();
      setState(() {
        _selectedDate = null;
        _selectedMeal = null;
        _menuItems.clear(); // Clear menu items
      });
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit feedback')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10.0),
          const Text(
            "Feed Us Your Thoughts!",
            style: TextStyle(
              color: AppColors.black,
              fontSize: 28.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5.0),
          const Text(
            "Your Opinion is Our Secret Ingredient",
            style: TextStyle(
              color: AppColors.grey,
              fontSize: 12.0,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 55.0),
          TextField(
            controller: _dateController,
            readOnly: true,
            decoration: InputDecoration(
              fillColor: Colors.white,
              labelText: "Date",
              suffixIcon: Icon(
                Icons.today,
                color: AppColors.orange200.withOpacity(0.8),
              ),
            ),
            onTap: _selectDate,
          ),
          const SizedBox(height: 10.0),
          DropdownButtonFormField<String>(
            value: _selectedMeal,
            decoration: InputDecoration(
              fillColor: Colors.white,
              labelText: "Meal",
            ),
            items: _mealOptions.map((meal) {
              return DropdownMenuItem<String>(
                value: meal,
                child: Text(meal),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedMeal = newValue;
                _fetchMenuItems(); // Fetch menu items when meal is selected
              });
            },
          ),
          const SizedBox(height: 10.0),
          TextField(
            controller: _feedbackController,
            maxLines: 5,
            decoration: InputDecoration(
              fillColor: Colors.white,
              labelText: 'Feedback',
            ),
          ),
          const SizedBox(height: 30.0),
          SizedBox(
            width: double.infinity,
            height: 40.0,
            child: ElevatedButton(
              onPressed: _submitFeedback,
              child: const Text(
                'Submit Feedback',
                style: TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
