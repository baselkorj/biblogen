import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:biblogen/screens/home.dart';
import 'package:provider/provider.dart';
import 'package:biblogen/database/moor_database.dart';

class EditProject extends StatefulWidget {
  final projectId;
  final projectTitle;
  final projectRefStyle;
  final projectColor;
  final projectCreated;

  EditProject(
      {this.projectId,
      this.projectTitle,
      this.projectRefStyle,
      this.projectColor,
      this.projectCreated});

  @override
  _EditProjectState createState() => _EditProjectState();
}

class _EditProjectState extends State<EditProject> {
  final _formKey = GlobalKey<FormState>();

  String _currentTitle;
  int _currentColor;
  Color _finalColor;
  String _currentRefStyle;

  // ignore: must_call_super
  void initState() {
    _currentTitle = widget.projectTitle;
    _currentColor = widget.projectColor;
    _finalColor = Color(widget.projectColor);
    _currentRefStyle = widget.projectRefStyle;
  }

  @override
  Widget build(BuildContext context) {
    Future _updateProject() async {
      final database = Provider.of<AppDatabase>(context);
      final project = Project(
          id: widget.projectId,
          title: _currentTitle,
          color: _currentColor,
          refStyle: _currentRefStyle,
          created: widget.projectCreated,
          edited: DateTime.now());
      await database.updateProject(project, widget.projectId);
    }

    Future _deleteProject() async {
      final database = Provider.of<AppDatabase>(context);
      final project = Project(
          id: widget.projectId,
          title: widget.projectTitle,
          refStyle: widget.projectRefStyle,
          color: widget.projectColor,
          created: widget.projectCreated,
          edited: DateTime.now());
      await database.deleteProject(project, widget.projectId);
    }

    Future _deleteReferences() async {
      final database = Provider.of<AppDatabase>(context);
      // ignore: missing_required_param
      final reference = Reference(parent: widget.projectId);
      await database.deleteReferences(reference, widget.projectId);
    }

    return Form(
      key: _formKey,
      child: Scaffold(
        // App Bar
        appBar: AppBar(
          title: Text('Project Editor'),
          backgroundColor: _finalColor,
          actions: [
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                          title: Text(
                            'Delete Project?',
                            style: TextStyle(height: 1.5),
                          ),
                          content: Text('This action cannot be reversed.',
                              style: TextStyle(
                                  color: Colors.black54, height: 1.5)),
                          actions: <Widget>[
                            TextButton(
                                child: Text('Cancel'),
                                onPressed: () => Navigator.pop(context),
                                style: ButtonStyle(
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.black54))),
                            ElevatedButton(
                                child: Text('Yes',
                                    style: TextStyle(color: Colors.white)),
                                style: ButtonStyle(
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.red)),
                                onPressed: () async {
                                  await _deleteReferences();
                                  await _deleteProject();
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Home()),
                                    (Route<dynamic> route) => false,
                                  );
                                })
                          ],
                        ));
              },
            )
          ],
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
                        initialValue: _currentTitle,
                        decoration: buildInputDecoration(_finalColor),
                        validator: (val) => val.isEmpty
                            ? 'Enter a title for your project'
                            : null,
                        maxLength: 50,
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
                        dropdownSearchDecoration:
                            buildInputDecoration(_finalColor),
                        searchBoxDecoration: buildInputDecoration(_finalColor),
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
                _updateProject();
                Navigator.pop(context);
              }
            });
          },
          child: Icon(Icons.save),
        ),
      ),
    );
  }

  InputDecoration buildInputDecoration(Color _finalColor) {
    return InputDecoration(
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
