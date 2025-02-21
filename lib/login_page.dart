import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'database_helper.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; // Loading state

  void _login() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showSnackbar('Please fill in both fields');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://api.ezuite.com/api/External_Api/Mobile_Api/Invoke'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'API_Body': [
            {
              'Unique_Id': '',
              'Pw': password,
            }
          ],
          'Api_Action': 'GetUserData',
          'Company_Code': username,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['Status_Code'] == 200) {
          _showSnackbar('Login Successful!');

          // Extract user data from the response
          var userData = responseData['Response_Body'][0];

          // Save user data into SQLite database
          Map<String, dynamic> row = {
            DatabaseHelper.columnUserCode: userData['User_Code'],
            DatabaseHelper.columnUserDisplayName: userData['User_Display_Name'],
            DatabaseHelper.columnEmail: userData['Email'],
            DatabaseHelper.columnUserEmployeeCode:
                userData['User_Employee_Code'],
            DatabaseHelper.columnCompanyCode: userData['Company_Code'],
          };

          int id = await DatabaseHelper.instance.insert(row);
          print('Inserted user data with id: $id');

          // Retrieve and print saved data for verification
          _getUserData();
        } else {
          _showSnackbar('Login Failed! ${responseData["Message"]}');
        }
      } else {
        _showSnackbar('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackbar('Error: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _getUserData() async {
    List<Map<String, dynamic>> allRows =
        await DatabaseHelper.instance.queryAllRows();
    print('All rows: $allRows');
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('/// Enhanzer',
              style: TextStyle(
                  color: Color(0xB6214396),
                  fontSize: 25,
                  fontWeight: FontWeight.bold))),
      backgroundColor: Colors.blue.shade100, // Soft background
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white, // Card background
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3), // Shadow effect
                    blurRadius: 10,
                    spreadRadius: 3,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock, size: 60, color: Colors.lightBlue),
                  SizedBox(height: 10),
                  Text(
                    "Login Page",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 30),
                  // Username TextField
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person, color: Colors.lightBlue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
                  // Password TextField
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock, color: Colors.lightBlue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 35),
                  // Login Button with loading state
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login, // Disable if loading
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Login', style: TextStyle(fontSize: 18)),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
