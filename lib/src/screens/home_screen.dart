import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../globals.dart';
import '../providers/auth_service.dart';
import 'login_screen.dart';
import 'package:overlay_loading_progress/overlay_loading_progress.dart';

class DataFetchWidget extends StatefulWidget {
  const DataFetchWidget({Key? key}) : super(key: key);

  @override
  State<DataFetchWidget> createState() => _DataFetchWidgetState();
}

class _DataFetchWidgetState extends State<DataFetchWidget> {
  List<Map<String, dynamic>> data = [];
  String selectedValue = '';
  bool isLoading = false;
  String? token;
  Map<String, dynamic>? selectedProduct;
  List<Map<String, dynamic>> categories = [];
  String? selectedCategory;

  final AuthService authService = AuthService();

  Future<bool> isAuthenticated() async {
    bool authToken = await authService.isAuthenticated();
    return authToken;
  }

  Future<void> fetchData() async {
    try {
      setState(() {
        isLoading = true;
      });

      Map<String, String> headers =
          Map<String, String>.from(await authService.headers);
      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/products',
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        dynamic jsonData = json.decode(response.body);

        List<dynamic> dataList = (jsonData is List) ? jsonData : [jsonData];

        List<Map<String, dynamic>> newData =
            dataList.map<Map<String, dynamic>>((item) {
          return item is Map<String, dynamic> && item.containsKey('name')
              ? {
                  'name': item['name'].toString(),
                  'id': item['id'].toString(),
                  'quantity': item['quantity'].toString(),
                  'category': item['category'].toString(),
                }
              : {'name': ''};
        }).toList();

        setState(() {
          data = newData;
          selectedValue = data.isNotEmpty ? data[0].toString() : '';
          selectedProduct = data.isNotEmpty ? data.first : null;
        });
      } else if (response.statusCode == 401) {
        dynamic error = json.decode(response.body);
        throw error['message'];
      } else {
        dynamic error = json.decode(response.body);
        throw error['message'];
      }
    } catch (e) {
      throw '$e';
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchCategories() async {
    try {
      Map<String, String> headers =
          Map<String, String>.from(await authService.headers);
      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/categories',
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        dynamic jsonData = json.decode(response.body);
        List<dynamic> categoryList = (jsonData is List) ? jsonData : [jsonData];

        List<Map<String, dynamic>> newData =
            categoryList.map<Map<String, dynamic>>((item) {
          return item is Map<String, dynamic> && item.containsKey('name')
              ? {
                  'name': item['name'].toString(),
                  'id': item['id'].toString(),
                }
              : {'name': ''};
        }).toList();
        setState(() {
          categories = newData;
          selectedCategory =
              categories.isNotEmpty ? categories.first['id'] : null;
        });
      } else if (response.statusCode == 401) {
        dynamic error = json.decode(response.body);
        throw error['error'];
      } else {
        dynamic error = json.decode(response.body);
        throw error['error'];
      }
    } catch (e) {
      throw '$e';
    }
  }

  Future<void> updateProductDetails(Map<String, dynamic> updatedDetails) async {
    try {
      OverlayLoadingProgress.start(context);

      Map<String, String> headers =
          Map<String, String>.from(await authService.headers);
      final response = await http.put(
        Uri.parse(
          '$baseUrl/api/products/${selectedProduct!['id']}',
        ),
        headers: headers,
        body: json.encode(updatedDetails),
      );

      OverlayLoadingProgress.stop();

      if (response.statusCode == 200) {
        fetchData();
      } else {
        dynamic error = json.decode(response.body);
        throw error['error'];
      }
    } catch (e) {
      OverlayLoadingProgress.stop();

      throw '$e';
    }
  }

  Future<void> deleteProduct() async {
    try {
      OverlayLoadingProgress.start(context);
      Map<String, String> headers =
          Map<String, String>.from(await authService.headers);
      final response = await http.delete(
        Uri.parse(
          '$baseUrl/api/products/${selectedProduct!['id']}',
        ),
        headers: headers,
      );

      OverlayLoadingProgress.stop();

      if (response.statusCode == 200) {
        fetchData(); // Refresh data after delete
      } else {
        dynamic error = json.decode(response.body);
        throw error['error'];
      }
    } catch (e) {
      OverlayLoadingProgress.stop();
      throw '$e';
    }
  }

  Future<void> addProduct(Map<String, dynamic> productDetails) async {
    try {
      OverlayLoadingProgress.start(context);

      Map<String, String> headers =
          Map<String, String>.from(await authService.headers);
      final response = await http.post(
        Uri.parse('$baseUrl/api/products'),
        headers: headers,
        body: json.encode(productDetails),
      );

      OverlayLoadingProgress.stop();

      if (response.statusCode == 200) {
        fetchData();
      } else {
        dynamic error = json.decode(response.body);
        throw error['error'];
      }
    } catch (e) {
      OverlayLoadingProgress.stop();

      throw '$e';
    }
  }

  void _showEditProductDialog() {
    TextEditingController nameController =
        TextEditingController(text: selectedProduct!['name']);
    TextEditingController quantityController =
        TextEditingController(text: selectedProduct!['quantity']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Product'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: quantityController,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        int.tryParse(value) == null) {
                      return 'Please enter a valid quantity';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_validateForm()) {
                  await updateProductDetails({
                    'name': nameController.text,
                    'quantity': quantityController.text,
                  }).then((value) => Navigator.of(context).pop());
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: const Text('Are you sure you want to delete this product?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await deleteProduct()
                    .then((value) => Navigator.of(context).pop());
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _validateForm() {
    final form = _formKey.currentState;
    if (form != null) {
      if (form.validate()) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  void _showAddProductDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Product'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: quantityController,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        int.tryParse(value) == null) {
                      return 'Please enter a valid quantity';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<String>(
                  value: selectedCategory != null
                      ? selectedCategory!.toString()
                      : null,
                  items: categories.map<DropdownMenuItem<String>>(
                    (Map<String, dynamic> value) {
                      return DropdownMenuItem<String>(
                        value: value['id'].toString(),
                        child: Text(
                          value['name'],
                          style: const TextStyle(fontSize: 20),
                        ),
                      );
                    },
                  ).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCategory = categories.firstWhere(
                          (item) => item['id'].toString() == newValue)['id'];
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Category',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_validateForm()) {
                  await addProduct({
                    'name': nameController.text,
                    'quantity': quantityController.text,
                    'category_id': selectedCategory,
                  }).then((value) => Navigator.of(context).pop());
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    isAuthenticated().then((value) {
      if (value) {
        fetchData();
        fetchCategories();
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: DropdownButton<Map<String, dynamic>>(
                        value: selectedProduct,
                        items: data.map<DropdownMenuItem<Map<String, dynamic>>>(
                            (Map<String, dynamic> value) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: value,
                            child: Text(
                              value['name'],
                              style: const TextStyle(fontSize: 20),
                            ),
                          );
                        }).toList(),
                        onChanged: (Map<String, dynamic>? newValue) {
                          setState(() {
                            selectedProduct = newValue;
                          });
                        },
                        icon: const Icon(Icons.arrow_drop_down),
                        iconSize: 36,
                        isExpanded: true,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (selectedProduct != null)
                      Expanded(
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Product: ${selectedProduct!['name']}',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Quantity: ${selectedProduct!['quantity']}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Category: ${selectedProduct!['category']}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: _showEditProductDialog,
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          color: Colors.red,
                                          onPressed:
                                              _showDeleteConfirmationDialog,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
