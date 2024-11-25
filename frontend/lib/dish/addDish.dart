import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddDishPage extends StatefulWidget {
  @override
  _AddDishPageState createState() => _AddDishPageState();
}

class _AddDishPageState extends State<AddDishPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController restaurantNameController = TextEditingController();  // Added controller for restaurantName
  File? _image;

  final ImagePicker _picker = ImagePicker();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  // Function to pick image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  // Function to submit the form to the backend
 Future<void> _submitForm() async {
  if (_formKey.currentState!.validate()) {
    final uri = Uri.parse("http://192.168.1.4:3500/dishs/addDish");
    var request = http.MultipartRequest('POST', uri);

    // Get the token
    String token = await _getToken();
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['name'] = nameController.text;
    request.fields['category'] = categoryController.text;
    request.fields['description'] = descriptionController.text;
    request.fields['price'] = priceController.text;
    request.fields['restaurantName'] = restaurantNameController.text;

    // Send image only if it's available
    if (_image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
    } else {
      // You can either skip the 'image' field or set it as an empty string
      request.fields['image'] = ''; // Or just skip adding this field if not required by the backend
      print("No image to send, but the form will still be submitted.");
    }

    try {
      final response = await request.send();
      final responseData = await http.Response.fromStream(response);
      print("Response status: ${response.statusCode}");
      print("Response: ${responseData.body}");

      if (response.statusCode == 201) {
        print("Dish added successfully");
        _showSnackBar('Dish added successfully');
        _resetForm();
      } else {
        print("Failed to add the dish");
        _showSnackBar('Failed to add the dish');
      }
    } catch (e) {
      print("Error during submission: $e");
      _showSnackBar('Error during submission');
    }
  }
}

  // Function to get token from local storage
  Future<String> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  void _showSnackBar(String message) {
    _scaffoldKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _resetForm() {
    nameController.clear();
    categoryController.clear();
    descriptionController.clear();
    priceController.clear();
    restaurantNameController.clear();  // Clear restaurantName field
    setState(() {
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Add a Dish'),
          backgroundColor: Colors.orangeAccent,
        ),
        body: Stack(
          children: [
            // Background image with opacity
            Opacity(
              opacity: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/wallpapers-sfondo-e-globo-background-and-globe-arriere-plan-et-sphere.jpg.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // The form content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add a New Dish',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Dish Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.fastfood, color: const Color.fromARGB(255, 0, 0, 0)),
                          labelStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: const Color.fromARGB(255, 134, 77, 2)),
                          ),
                        ),
                        validator: (value) => value!.isEmpty ? 'This field is required' : null,
                        style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: categoryController,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category, color: const Color.fromARGB(255, 0, 0, 0)),
                          labelStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: const Color.fromARGB(255, 16, 4, 4)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: const Color.fromARGB(172, 92, 57, 10)),
                          ),
                        ),
                        validator: (value) => value!.isEmpty ? 'This field is required' : null,
                        style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description, color: const Color.fromARGB(209, 66, 23, 23)),
                          labelStyle: TextStyle(color: const Color.fromARGB(255, 8, 2, 2)),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: const Color.fromARGB(255, 125, 80, 19)),
                          ),
                        ),
                        validator: (value) => value!.isEmpty ? 'This field is required' : null,
                        style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: priceController,
                        decoration: InputDecoration(
                          labelText: 'Price',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money, color: const Color.fromARGB(255, 0, 0, 0)),
                          labelStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: const Color.fromARGB(255, 255, 255, 255)),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty ? 'This field is required' : null,
                        style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: restaurantNameController,  // Added input field for restaurantName
                        decoration: InputDecoration(
                          labelText: 'Restaurant Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.restaurant, color: const Color.fromARGB(255, 0, 0, 0)),
                          labelStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: const Color.fromARGB(255, 134, 77, 2)),
                          ),
                        ),
                        validator: (value) => value!.isEmpty ? 'This field is required' : null,
                        style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                      SizedBox(height: 16),
                      TextButton(
                        onPressed: _pickImage,
                        child: Text(
                          _image == null ? 'Pick Image' : 'Change Image',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: Text('Add Dish'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
