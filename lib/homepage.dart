import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'sql_helper.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _diaries = [];
  bool _isLoading = true;
  bool _isDarkMode = false;
  bool _isBlurMode = false;
  bool _showSettings = false;
  String _userName = 'Fatehah Sofian';
  String? _selectedImagePath;

  final List<Color> _softColors = [
    Color(0xFFFFF9C4), // Light yellow
    Color(0xFFE1BEE7), // Light purple
    Color(0xFFB3E5FC), // Light blue
    Color(0xFFFFCCBC), // Light orange
    Color(0xFFC8E6C9), // Light green
  ];

  void _refreshDiaries() async {
    final data = await SQLHelper.getDiaries();
    setState(() {
      _diaries = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshDiaries();
  }

  final TextEditingController _feelingController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  void _showForm(int? id) async {
    if (id != null) {
      final existingDiary =
          _diaries.firstWhere((element) => element['id'] == id);
      _feelingController.text = existingDiary['feeling'];
      _descriptionController.text = existingDiary['description'];
      _selectedImagePath = existingDiary['imagePath'];
    } else {
      _feelingController.text = '';
      _descriptionController.text = '';
      _selectedImagePath = null;
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _feelingController,
                    decoration: const InputDecoration(
                      hintText: 'Feeling',
                      filled: true,
                      fillColor: Color(0xFFFCF8E8), // Light yellow color
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(
                          color: Colors.orange, // Orange border color
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Description',
                      filled: true,
                      fillColor: Color(0xFFE8F5FC), // Light blue color
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(
                          color: Colors.blue, // Blue border color
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedImagePath != null
                              ? 'Image selected'
                              : 'No image selected',
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.image),
                        onPressed: _pickImage,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (id == null) {
                        await _addDiary();
                      }

                      if (id != null) {
                        await _updateDiary(id);
                      }

                      _feelingController.text = '';
                      _descriptionController.text = '';
                      _selectedImagePath = null;

                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                    child: Text(
                      id == null ? 'Create New' : 'Update',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ));
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImagePath = pickedFile.path;
      });
    }
  }

  Future<void> _addDiary() async {
    await SQLHelper.createDiary(
      _feelingController.text,
      _descriptionController.text,
      _selectedImagePath,
    );
    _refreshDiaries();
  }

  Future<void> _updateDiary(int id) async {
    await SQLHelper.updateDiary(
      id,
      _feelingController.text,
      _descriptionController.text,
      _selectedImagePath,
    );
    _refreshDiaries();
  }

  Future<void> _deleteDiary(int id) async {
    await SQLHelper.deleteDiary(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted from Storytel!'),
    ));
    _refreshDiaries();
  }

  Future<void> _deleteAllDiaries() async {
    await SQLHelper.deleteAllDiaries();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted all Storytels!'),
    ));
    _refreshDiaries();
  }

  void _showEditProfile() {
    _nameController.text = _userName;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                setState(() {
                  _userName = _nameController.text;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Color _getRandomSoftColor() {
    final _random = Random();
    return _softColors[_random.nextInt(_softColors.length)];
  }

  Widget _getEmoji(String feeling) {
    switch (feeling.toLowerCase()) {
      case 'happy':
      case 'gembira':
      case 'suka':
        return Image.asset(
          'assets/happy.png',
          width: 80,
          height: 80,
        );
      case 'apologise':
      case 'minta maaf':
      case 'maaf':
        return Image.asset(
          'assets/apologise.png',
          width: 80,
          height: 80,
        );
      case 'lovely':
      case 'sayang':
        return Image.asset(
          'assets/lovely.png',
          width: 80,
          height: 80,
        );
      case 'sedih':
      case 'sad':
        return Image.asset(
          'assets/sad.png',
          width: 80,
          height: 80,
        );
      case 'scared':
      case 'takut':
        return Image.asset(
          'assets/scared.png',
          width: 80,
          height: 80,
        );
      case 'sleepy':
      case 'ngantuk':
      case 'exhausted':
        return Image.asset(
          'assets/sleepy.png',
          width: 80,
          height: 80,
        );
      case 'surprise':
      case 'terkejut':
        return Image.asset(
          'assets/surprise.png',
          width: 80,
          height: 80,
        );
      default:
        return Image.asset(
          'assets/happy.png',
          width: 80,
          height: 80,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${_userName}'s Storytel"),
        backgroundColor: Color.fromRGBO(242, 232, 207, 1),
      ),
      drawer: Drawer(
        child: Container(
          color: Color.fromARGB(255, 168, 164, 164),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 81, 81, 81),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/profile.jpg'),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _userName,
                          style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontSize: 18,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.white, size: 18),
                          onPressed: _showEditProfile,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.settings, color: Color.fromARGB(255, 255, 255, 255)),
                title: Text('Settings', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
                onTap: () {
                  setState(() {
                    _showSettings = !_showSettings;
                  });
                  Navigator.pop(context);
                },
              ),
              if (_showSettings) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListTile(
                    leading: Icon(Icons.brightness_6, color: Color.fromARGB(255, 255, 255, 255)),
                    title: Text('Dark Mode', style: TextStyle(color: const Color.fromARGB(255, 244, 245, 245))),
                    onTap: () {
                      setState(() {
                        _isDarkMode = true;
                        _isBlurMode = false;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListTile(
                    leading: Icon(Icons.brightness_7, color: Color.fromARGB(255, 255, 255, 255)),
                    title: Text('Default Mode', style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255))),
                    onTap: () {
                      setState(() {
                        _isDarkMode = false;
                        _isBlurMode = false;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListTile(
                    leading: Icon(Icons.blur_on, color: const Color.fromARGB(255, 255, 255, 255)),
                    title: Text('Blur Mode', style: TextStyle(color: const Color.fromARGB(255, 254, 255, 255))),
                    onTap: () {
                      setState(() {
                        _isBlurMode = true;
                        _isDarkMode = false;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
              ListTile(
                leading: Icon(Icons.refresh, color: const Color.fromARGB(255, 255, 255, 255)),
                title: Text('Reset', style: TextStyle(color: const Color.fromARGB(255, 248, 248, 248))),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Reset Confirmation'),
                      content: Text('Are you sure you want to reset all storytels? By clicking reset, all your storytels will disappear.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            _deleteAllDiaries();
                            Navigator.of(context).pop();
                          },
                          child: Text('Reset'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Spacer(),
              ListTile(
                leading: Icon(Icons.logout, color: Color.fromARGB(255, 255, 255, 255)),
                title: Text('Logout', style: TextStyle(color: const Color.fromARGB(255, 254, 254, 254))),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Logout'),
                        content: Text('Are you sure you want to log out?'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('No'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text('Yes'),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: _isDarkMode ? Colors.black : Colors.white,
              image: DecorationImage(
                image: AssetImage(_isDarkMode
                    ? 'assets/dark_wallpaper.jpeg'
                    : 'assets/wallpaper.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (_isBlurMode)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color: Colors.black.withOpacity(0.1),
              ),
            ),
          Center(
            child: _isLoading
                ? const CircularProgressIndicator()
                : ListView.builder(
                    itemCount: _diaries.length,
                    itemBuilder: (context, index) => Dismissible(
                      key: Key(_diaries[index]['id'].toString()),
                      direction: DismissDirection.horizontal,
                      background: Container(
                        color: Colors.blue,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Icon(Icons.edit, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          return showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Delete Confirmation'),
                              content: Text('Are you sure you want to delete this diary?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        } else if (direction == DismissDirection.startToEnd) {
                          _showForm(_diaries[index]['id']);
                          return false;
                        }
                        return false;
                      },
                      onDismissed: (direction) {
                        if (direction == DismissDirection.endToStart) {
                          _deleteDiary(_diaries[index]['id']);
                        }
                      },
                      child: Card(
                        color: _getRandomSoftColor(),
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          leading: _getEmoji(_diaries[index]['feeling']),
                          title: Text(_diaries[index]['feeling']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_diaries[index]['description']),
                              Text(_diaries[index]['createdAt']),
                            ],
                          ),
                          trailing: _diaries[index]['imagePath'] != null
                              ? Image.file(
                                  File(_diaries[index]['imagePath']),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}
