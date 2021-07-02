import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:biblogen/database/moor_database.dart';
import 'package:biblogen/screens/home.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddProject extends StatefulWidget {
  @override
  _AddProjectState createState() => _AddProjectState();
}

class _AddProjectState extends State<AddProject> {
  final _formKey = GlobalKey<FormState>();

  String _currentTitle;
  String _currentRefStyle = 'CU Harvard';
  int _currentColor = 0xFFE91E63;
  Color _finalColor = Color(0xFFE91E63);

  // Project add function
  Future _addProject() async {
    // Generate a UUID
    var uuid = Uuid();
    String id = uuid.v4();

    // Using provider to assign AppDatabase to local
    final database = Provider.of<AppDatabase>(context);
    final project = Project(
        id: id,
        title: _currentTitle,
        refStyle: _currentRefStyle,
        color: _currentColor,
        created: DateTime.now(),
        edited: DateTime.now());
    database.insertProject(project);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        // App Bar
        appBar: AppBar(
          title: Text('New Project'),
          backgroundColor: _finalColor,
        ),

        // Body
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Title',
                      style: TextStyle(
                          color: _finalColor, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                        decoration: buildInputDecoration(),
                        validator: (val) => val.isEmpty
                            ? 'Enter a title for your project'
                            : null,
                        maxLength: 100,
                        onChanged: (val) =>
                            setState(() => _currentTitle = val)),
                    SizedBox(height: 15),
                    Text(
                      'Referencing Style',
                      style: TextStyle(
                          color: _finalColor, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 10),
                    DropdownSearch<String>(
                        mode: Mode.DIALOG,
                        maxHeight: 250,
                        dropdownSearchDecoration: buildInputDecoration(),
                        searchBoxDecoration: buildInputDecoration(),
                        showSelectedItem: true,
                        showSearchBox: true,
                        items: ['APA', 'CU Harvard'],
                        popupItemDisabled: (String s) => s.startsWith('I'),
                        onChanged: (val) =>
                            setState(() => _currentRefStyle = val),
                        selectedItem: _currentRefStyle),
                    SizedBox(height: 15),
                    Text(
                      'Color Tag',
                      style: TextStyle(
                          color: _finalColor, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Dark Blue
                        InkWell(
                            onTap: () {
                              setState(() {
                                _currentColor = 0xFF1565C0;
                                _finalColor = Color(0xFF1565C0);
                              });
                            },
                            child: CircleAvatar(
                                backgroundColor: Color(0xFF1565C0),
                                radius: 18,
                                child: _finalColor == Color(0xFF1565C0)
                                    ? WhiteCheck()
                                    : Container())),

                        // Blue
                        InkWell(
                            onTap: () {
                              setState(() {
                                _currentColor = 0xFF2196F3;
                                _finalColor = Color(0xFF2196F3);
                              });
                            },
                            child: CircleAvatar(
                                backgroundColor: Color(0xFF2196F3),
                                radius: 18,
                                child: _finalColor == Color(0xFF2196F3)
                                    ? WhiteCheck()
                                    : Container())),

                        // Green
                        InkWell(
                            onTap: () {
                              setState(() {
                                _currentColor = 0xFF4CAF50;
                                _finalColor = Color(0xFF4CAF50);
                              });
                            },
                            child: CircleAvatar(
                                backgroundColor: Color(0xFF4CAF50),
                                radius: 18,
                                child: _finalColor == Color(0xFF4CAF50)
                                    ? WhiteCheck()
                                    : Container())),

                        // Yellow
                        InkWell(
                            onTap: () {
                              setState(() {
                                _currentColor = 0xFFFBC02D;
                                _finalColor = Color(0xFFFBC02D);
                              });
                            },
                            child: CircleAvatar(
                                backgroundColor: Color(0xFFFBC02D),
                                radius: 18,
                                child: _finalColor == Color(0xFFFBC02D)
                                    ? Icon(Icons.check,
                                        size: 28, color: Colors.white)
                                    : Container())),

                        // Orange
                        InkWell(
                            onTap: () {
                              setState(() {
                                _currentColor = 0xFFFF9800;
                                _finalColor = Color(0xFFFF9800);
                              });
                            },
                            child: CircleAvatar(
                                backgroundColor: Color(0xFFFF9800),
                                radius: 18,
                                child: _finalColor == Color(0xFFFF9800)
                                    ? WhiteCheck()
                                    : Container())),

                        // Red
                        InkWell(
                            onTap: () {
                              setState(() {
                                _currentColor = 0xFFF44336;
                                _finalColor = Color(0xFFF44336);
                              });
                            },
                            child: CircleAvatar(
                                backgroundColor: Color(0xFFF44336),
                                radius: 18,
                                child: _finalColor == Color(0xFFF44336)
                                    ? WhiteCheck()
                                    : Container())),

                        // Pink
                        InkWell(
                            onTap: () {
                              setState(() {
                                _currentColor = 0xFFE91E63;
                                _finalColor = Color(0xFFE91E63);
                              });
                            },
                            child: CircleAvatar(
                                backgroundColor: Color(0xFFE91E63),
                                radius: 18,
                                child: _finalColor == Color(0xFFE91E63)
                                    ? WhiteCheck()
                                    : Container())),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),

        floatingActionButton: FloatingActionButton(
          backgroundColor: _finalColor,
          onPressed: () {
            setState(() {
              if (_formKey.currentState.validate()) {
                _addProject();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Home()),
                    (Route<dynamic> route) => false);
              }
            });
          },
          child: Icon(Icons.save),
        ),
      ),
    );
  }

  InputDecoration buildInputDecoration() {
    return InputDecoration(
        counterText: '',
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueGrey, width: 1.5)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 2, color: _finalColor)),
        errorBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 2, color: Colors.red)),
        focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 2, color: Colors.red)));
  }
}

class WhiteCheck extends StatelessWidget {
  const WhiteCheck({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.check, size: 28, color: Colors.white);
  }
}
