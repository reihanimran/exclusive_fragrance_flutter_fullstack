// ignore_for_file: library_private_types_in_public_api

import 'dart:io';
import 'dart:math';

import 'package:exclusive_fragrance/provider/theme_provider.dart';
import 'package:exclusive_fragrance/widgets/navigation.dart';
import 'package:flutter/material.dart';
import 'package:exclusive_fragrance/utils/handle_user_login.dart';
import 'package:exclusive_fragrance/api/api.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  _LoginRegisterScreenState createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final double _maxFormWidth = 500;
  bool _obscureLoginPassword = true;
  bool _obscureRegisterPassword = true;
  bool _obscureConfirmPassword = true;

  bool _rememberMe = false;

  String? _selectedDate;
  XFile? _selectedImage;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked.toIso8601String().split('T').first;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _phoneController.clear();
      _nameController.clear();
    }
  }

  Future<void> _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    // Call the login method from ApiService
    final token = await Api.login(email, password);

    if (token != null) {
      // If login is successful, navigate to the Screenbuilder page
      print('Login successful, Token: $token');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Navigation()),
      );
    } else {
      _showErrorDialog('Invalid credentials. Please try again.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Okay'),
          ),
        ],
      ),
    );
  }

  void _handleRegister() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();
    String phone = _phoneController.text.trim();
    String name = _nameController.text.trim();
    String dob = _selectedDate ?? '';

    if (!_validateEmail(email)) {
      _showErrorDialog('Please enter a valid email address.');
      return;
    }

    if (password != confirmPassword) {
      _showErrorDialog('Passwords do not match.');
      return;
    }

    if (!_validatePhone(phone)) {
      _showErrorDialog('Please enter a valid phone number.');
      return;
    }

    if (name.isEmpty) {
      _showErrorDialog('Please enter your full name.');
      return;
    }

    try {
      final uri =
          Uri.parse('http://13.60.243.207/api/register'); // 🔁 Replace this
      var request = http.MultipartRequest('POST', uri);

      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['password_confirmation'] = confirmPassword;
      request.fields['phone'] = phone;
      request.fields['date_of_birth'] = dob;

      if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'Profile_photo',
          _selectedImage!.path,
          filename: (_selectedImage!.path),
        ));
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration Successful! Please log in.'),
            backgroundColor: Colors.blue,
          ),
        );
        _tabController.animateTo(0); // move to login tab
      } else {
        final error = json.decode(responseBody);
        _showErrorDialog(error['message'] ?? 'Registration failed.');
      }
    } catch (e) {
      _showErrorDialog('Error: ${e.toString()}');
    }
  }

  bool _validateEmail(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  bool _validatePhone(String phone) {
    return RegExp(r"^[0-9]{10}$").hasMatch(phone);
  }

  Widget _buildForm(Widget formContent) {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape =
              MediaQuery.of(context).orientation == Orientation.landscape;

          return SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: _maxFormWidth,
                minHeight: isLandscape ? constraints.maxHeight * 0.6 : 0,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF5D57A), width: 2),
              ),
              margin: EdgeInsets.all(isLandscape ? 20 : 16),
              padding: EdgeInsets.all(isLandscape ? 24 : 18),
              child: IntrinsicHeight(
                child: formContent,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: isLandscape ? 100 : 80,
        title: Padding(
          padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
          child: Center(
            child: Image.asset(
              'assets/images/Exclusive_fragrance.png',
              width: isLandscape ? screenWidth * 0.3 : screenWidth * 0.5,
              fit: BoxFit.contain,
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFF5D57A),
          labelColor:
              themeProvider.isDarkMode ? const Color(0xFF151E25) : Colors.white,
          unselectedLabelColor:
              themeProvider.isDarkMode ? Colors.white70 : Color(0xFFF5D57A),
          labelStyle: TextStyle(
            fontSize: isLandscape ? 14 : 16,
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w700,
          ),
          tabs: const [
            Tab(text: "Login"),
            Tab(text: "Register"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Login Screen
          _buildForm(
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureLoginPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureLoginPassword = !_obscureLoginPassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscureLoginPassword,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            activeColor: const Color(0xFFF5D57A),
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                          ),
                          Expanded(
                            child: Text(
                              "Remember Me",
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                fontSize: isLandscape ? 12 : 14,
                                fontFamily: 'Open Sans',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _showForgotPasswordDialog,
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: isLandscape ? 12 : 14,
                          fontFamily: 'Open Sans',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isLandscape ? 10 : 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF5D57A),
                      padding: EdgeInsets.symmetric(
                        vertical: isLandscape ? 14 : 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: const Color(0xFF151E25),
                        fontSize: isLandscape ? 14 : 16,
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Register Screen
          _buildForm(
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureRegisterPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureRegisterPassword = !_obscureRegisterPassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscureRegisterPassword,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscureConfirmPassword,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedDate != null
                            ? 'DOB: $_selectedDate'
                            : 'No date selected',
                        style: TextStyle(
                          color: themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black,
                          fontSize: 14,
                          fontFamily: 'Open Sans',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _pickDate,
                      child: Text(
                        'Pick Date',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontFamily: 'Open Sans',
                            fontWeight: FontWeight.w400),
                      ),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                          const Color(0xFFF5D57A),
                        ),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _selectedImage != null
                        ? Image.file(
                            File(_selectedImage!.path),
                            width: 80,
                            height: 80,
                          )
                        : Text('No image selected',
                            style: TextStyle(
                                color: themeProvider.isDarkMode
                                    ? Colors.white
                                    : Colors.black)),
                    TextButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => SafeArea(
                            child: Wrap(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.camera_alt),
                                  title: const Text('Take Photo'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _pickImage(ImageSource.camera);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.photo_library),
                                  title: const Text('Choose from Gallery'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _pickImage(ImageSource.gallery);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Pick Profile Photo',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontFamily: 'Open Sans',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                          const Color(0xFFF5D57A),
                        ),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF5D57A),
                      padding: EdgeInsets.symmetric(
                        vertical: isLandscape ? 14 : 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Register",
                      style: TextStyle(
                        color: const Color(0xFF151E25),
                        fontSize: isLandscape ? 14 : 16,
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email to receive a reset link'),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Add password reset logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password reset link sent to your email'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
