import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:biblogen/database/moor_database.dart';
import 'package:biblogen/screens/add/proj/proj_preview.dart';
import 'package:provider/provider.dart';

class EditReference extends StatefulWidget {
  final projectId;
  final projectTitle;
  final projectColor;
  final referenceType;
  final referenceId;
  final referenceParent;

  EditReference({
    this.projectId,
    this.projectTitle,
    this.projectColor,
    this.referenceType,
    this.referenceId,
    this.referenceParent,
  });

  @override
  _updateReferenceState createState() => _updateReferenceState();
}

final _formKey = GlobalKey<FormState>();

// ignore: camel_case_types
class _updateReferenceState extends State<EditReference> {
  int _authorType = 0;
  bool _updatedReference = false;
  bool _updatedAuthor = false;
  Map _currentAuthors = {};
  String _currentId;
  String _currentOrganization;
  String _currentTitle;
  String _currentPublisher;
  String _currentPlace;
  String _currentEdition;
  String _currentPages;
  DateTime _publishDate;

  List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  Future _updateReference() async {
    if (_publishDate == null) {
      _publishDate = DateTime.now();
    }

    // Using provider to assign AppDatabase to local
    final database = Provider.of<AppDatabase>(context);
    final reference = Reference(
        id: _currentId,
        parent: widget.projectId,
        author: _authorType,
        title: _currentTitle,
        volume: _currentEdition,
        page: _currentPages,
        source: _currentPublisher,
        place: _currentPlace,
        pubDate: _publishDate,
        acessDate: DateTime.now(),
        refType: 'Book');
    database.updateReference(reference, _currentId);

    final author =
        Author(parent: _currentId, first: '', last: '', organization: '');
    database.deleteAuthor(author, _currentId);

    if (_authorType == 0) {
      for (var i = 0; i < _currentAuthors.length; i++) {
        final author = Author(
            parent: _currentId,
            first: _currentAuthors.values.toList()[i][0],
            last: _currentAuthors.values.toList()[i][1],
            organization: '');
        database.insertAuthor(author);
        print('inserted author');
      }
    } else {
      final author = Author(
          parent: _currentId,
          first: '',
          last: '',
          organization: _currentOrganization);
      database.insertAuthor(author);
    }
  }

  Future _deleteReference() async {
    final database = Provider.of<AppDatabase>(context);
    final reference = Reference(
        id: _currentId,
        parent: widget.projectId,
        author: _authorType,
        title: _currentTitle,
        volume: _currentEdition,
        page: _currentPages,
        source: _currentPublisher,
        place: _currentPlace,
        pubDate: _publishDate,
        acessDate: DateTime.now(),
        refType: 'Book');
    database.deleteReference(reference, _currentId);

    final author =
        Author(parent: _currentId, first: '', last: '', organization: '');
    database.deleteAuthor(author, _currentId);
  }

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<AppDatabase>(context);
    return StreamBuilder<List<Reference>>(
        stream: database.watchAllReferencesID(widget.referenceId),
        builder: (context, AsyncSnapshot<List<Reference>> snapshot) {
          if (snapshot.hasData) {
            final references = snapshot.data ?? List();

            if (!_updatedReference) {
              _authorType = references[0].author;
              _currentId = references[0].id;
              _currentTitle = references[0].title;
              _currentPublisher = references[0].source;
              _currentPlace = references[0].place;
              _currentEdition = references[0].volume;
              _currentPages = references[0].page;
              _publishDate = references[0].pubDate;
              _updatedReference = true;
            }

            return StreamBuilder<List<Author>>(
                stream: database.watchAllAuthors(widget.referenceId),
                builder: (context, AsyncSnapshot<List<Author>> snapshot) {
                  if (snapshot.hasData) {
                    final authors = snapshot.data.toList();
                    if (!_updatedAuthor && _authorType == 0) {
                      _updatedAuthor = true;
                      for (var i = 1; i <= authors.length; i++) {
                        _currentAuthors.putIfAbsent(
                            i,
                            () => [
                                  '${authors[i - 1].first}',
                                  '${authors[i - 1].last}'
                                ]);
                      }
                    } else if (!_updatedAuthor && _authorType == 1) {
                      _updatedAuthor = true;
                      _currentOrganization = authors[0].organization;
                      _currentAuthors = {
                        1: ['', '']
                      };
                    }

                    return Form(
                      key: _formKey,
                      child: Scaffold(
                          appBar: AppBar(
                            title: Text('${references[0].title}',
                                softWrap: false, overflow: TextOverflow.fade),
                            backgroundColor: Color(widget.projectColor),
                            actions: [
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () async {
                                  showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          AlertDialog(
                                            title: Text(
                                              'Delete Reference?',
                                              style: TextStyle(height: 1.5),
                                            ),
                                            content: Text(
                                                'This action cannot be reversed.',
                                                style: TextStyle(
                                                    color: Colors.black54,
                                                    height: 1.5)),
                                            actions: <Widget>[
                                              TextButton(
                                                child: Text('Cancel'),
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                style: ButtonStyle(
                                                    foregroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(Colors
                                                                .black54)),
                                              ),
                                              ElevatedButton(
                                                  child: Text('Yes',
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                  style: ButtonStyle(
                                                      foregroundColor:
                                                          MaterialStateProperty
                                                              .all<Color>(
                                                                  Colors.red)),
                                                  onPressed: () async {
                                                    await _deleteReference();
                                                    Navigator
                                                        .pushAndRemoveUntil(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ProjectOverview(
                                                                projectId: widget
                                                                    .referenceParent,
                                                                projectTitle: widget
                                                                    .projectTitle,
                                                                projectColor: widget
                                                                    .projectColor,
                                                                projectRefStyle:
                                                                    widget
                                                                        .referenceType,
                                                              )),
                                                      (Route<dynamic> route) =>
                                                          false,
                                                    );
                                                  })
                                            ],
                                          ));
                                },
                              )
                            ],
                          ),
                          body: ListView(
                              physics: BouncingScrollPhysics(),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 15),
                              children: [
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Author Type
                                      Card(
                                        child: Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Author Type',
                                                style: TextStyle(
                                                    color: Color(
                                                        widget.projectColor),
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                              SizedBox(height: 10),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Expanded(
                                                    child: InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          _authorType = 0;
                                                        });
                                                      },
                                                      child: Container(
                                                        height: 60,
                                                        decoration: BoxDecoration(
                                                            color: _authorType ==
                                                                    0
                                                                ? Color(widget
                                                                    .projectColor)
                                                                : Colors.grey,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5)),
                                                        child: Row(
                                                          children: [
                                                            SizedBox(width: 15),
                                                            Icon(
                                                              Icons.person,
                                                              color:
                                                                  Colors.white,
                                                              size: 45,
                                                            ),
                                                            SizedBox(width: 10),
                                                            Text(
                                                              'Person',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 15),
                                                  Expanded(
                                                    child: InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          _authorType = 1;
                                                        });
                                                      },
                                                      child: Container(
                                                        height: 60,
                                                        decoration: BoxDecoration(
                                                            color: _authorType ==
                                                                    1
                                                                ? Color(widget
                                                                    .projectColor)
                                                                : Colors.grey,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5)),
                                                        child: Row(
                                                          children: [
                                                            SizedBox(width: 20),
                                                            Icon(
                                                              Icons.business,
                                                              color:
                                                                  Colors.white,
                                                              size: 40,
                                                            ),
                                                            SizedBox(width: 10),
                                                            Text(
                                                              'Organization',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 5),

                                      _authorType == 0
                                          ? // Author is Person
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Card(
                                                  child: Padding(
                                                    padding: EdgeInsets.all(10),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                'First Name',
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        widget
                                                                            .projectColor),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700),
                                                              ),
                                                            ),
                                                            SizedBox(width: 15),
                                                            Expanded(
                                                              child: Text(
                                                                'Last Name',
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        widget
                                                                            .projectColor),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        ListView.builder(
                                                          physics:
                                                              NeverScrollableScrollPhysics(),
                                                          scrollDirection:
                                                              Axis.vertical,
                                                          shrinkWrap: true,
                                                          itemCount:
                                                              _currentAuthors
                                                                  .length,
                                                          itemBuilder:
                                                              (context, index) {
                                                            return Column(
                                                              children: [
                                                                SizedBox(
                                                                    height: 10),
                                                                Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child: TextFormField(
                                                                          initialValue: _currentAuthors.values.toList()[index]
                                                                              [
                                                                              0],
                                                                          decoration:
                                                                              buildInputDecoration(),
                                                                          validator: (val) => val.isEmpty
                                                                              ? ''
                                                                              : null,
                                                                          onChanged: (val) => setState(() => _currentAuthors
                                                                              .values
                                                                              .toList()[index][0] = val)),
                                                                    ),
                                                                    SizedBox(
                                                                        width:
                                                                            15),
                                                                    Expanded(
                                                                      child: TextFormField(
                                                                          initialValue: _currentAuthors.values.toList()[index]
                                                                              [
                                                                              1],
                                                                          decoration:
                                                                              buildInputDecoration(),
                                                                          validator: (val) => val.isEmpty
                                                                              ? ''
                                                                              : null,
                                                                          onChanged: (val) => setState(() => _currentAuthors
                                                                              .values
                                                                              .toList()[index][1] = val)),
                                                                    )
                                                                  ],
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    Expanded(
                                                      child: InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            var i =
                                                                _currentAuthors
                                                                        .length +
                                                                    1;
                                                            _currentAuthors
                                                                .putIfAbsent(
                                                                    i,
                                                                    () => [
                                                                          '',
                                                                          ''
                                                                        ]);
                                                          });
                                                        },
                                                        child: Card(
                                                            child: Center(
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    5),
                                                            child: Icon(
                                                              Icons.add_circle,
                                                              color:
                                                                  Colors.green,
                                                            ),
                                                          ),
                                                        )),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: InkWell(
                                                        onTap: () {
                                                          if (_currentAuthors
                                                                  .length >
                                                              1) {
                                                            setState(() {
                                                              var i =
                                                                  _currentAuthors
                                                                      .length;
                                                              _currentAuthors
                                                                  .remove(i);
                                                            });
                                                          }
                                                        },
                                                        child: Card(
                                                            child: Center(
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    5),
                                                            child: Icon(
                                                              Icons
                                                                  .remove_circle,
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                        )),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            )
                                          : // Author is Organization
                                          Card(
                                              child: Padding(
                                                padding: EdgeInsets.all(10),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Organization Name',
                                                      style: TextStyle(
                                                          color: Color(widget
                                                              .projectColor),
                                                          fontWeight:
                                                              FontWeight.w700),
                                                    ),
                                                    SizedBox(height: 10),
                                                    TextFormField(
                                                        initialValue: authors[0]
                                                            .organization,
                                                        decoration:
                                                            buildInputDecoration(),
                                                        validator: (val) =>
                                                            val.isEmpty
                                                                ? ''
                                                                : null,
                                                        onChanged: (val) =>
                                                            setState(() =>
                                                                _currentOrganization =
                                                                    val)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                      SizedBox(height: 5),

                                      // Reference Title
                                      Card(
                                        child: Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Reference Title',
                                                style: TextStyle(
                                                    color: Color(
                                                        widget.projectColor),
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                              SizedBox(height: 10),
                                              TextFormField(
                                                  initialValue:
                                                      references[0].title,
                                                  decoration:
                                                      buildInputDecoration(),
                                                  validator: (val) =>
                                                      val.isEmpty ? '' : null,
                                                  onChanged: (val) => setState(
                                                      () =>
                                                          _currentTitle = val)),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 5),

                                      // Edition & Pages Used
                                      Card(
                                        child: Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      'Edition',
                                                      style: TextStyle(
                                                          color: Color(widget
                                                              .projectColor),
                                                          fontWeight:
                                                              FontWeight.w700),
                                                    ),
                                                  ),
                                                  SizedBox(width: 15),
                                                  Expanded(
                                                    child: Text(
                                                      'Pages Used',
                                                      style: TextStyle(
                                                          color: Color(widget
                                                              .projectColor),
                                                          fontWeight:
                                                              FontWeight.w700),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: TextFormField(
                                                        initialValue:
                                                            references[0]
                                                                .volume,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        inputFormatters: <
                                                            TextInputFormatter>[
                                                          FilteringTextInputFormatter
                                                              .digitsOnly
                                                        ],
                                                        decoration:
                                                            buildInputDecoration(),
                                                        maxLength: 3,
                                                        onChanged: (val) =>
                                                            setState(() =>
                                                                _currentEdition =
                                                                    val)),
                                                  ),
                                                  SizedBox(width: 15),
                                                  Expanded(
                                                    child: TextFormField(
                                                        initialValue:
                                                            references[0].page,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        decoration:
                                                            buildInputDecoration(),
                                                        onChanged: (val) =>
                                                            setState(() =>
                                                                _currentPages =
                                                                    val)),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 5),

                                      // Publisher & Place of Publication
                                      Card(
                                        child: Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      'Publisher',
                                                      style: TextStyle(
                                                          color: Color(widget
                                                              .projectColor),
                                                          fontWeight:
                                                              FontWeight.w700),
                                                    ),
                                                  ),
                                                  SizedBox(width: 15),
                                                  Expanded(
                                                    child: Text(
                                                      'Place of Publication',
                                                      style: TextStyle(
                                                          color: Color(widget
                                                              .projectColor),
                                                          fontWeight:
                                                              FontWeight.w700),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: TextFormField(
                                                        initialValue:
                                                            references[0]
                                                                .source,
                                                        decoration:
                                                            buildInputDecoration(),
                                                        onChanged: (val) =>
                                                            setState(() =>
                                                                _currentPublisher =
                                                                    val)),
                                                  ),
                                                  SizedBox(width: 15),
                                                  Expanded(
                                                    child: TextFormField(
                                                        initialValue:
                                                            references[0].place,
                                                        decoration:
                                                            buildInputDecoration(),
                                                        onChanged: (val) =>
                                                            setState(() =>
                                                                _currentPlace =
                                                                    val)),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 5),

                                      // Date Published
                                      Card(
                                        child: Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Date Published',
                                                style: TextStyle(
                                                    color: Color(
                                                        widget.projectColor),
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                              SizedBox(height: 10),
                                              InkWell(
                                                onTap: () {
                                                  showDatePicker(
                                                          context: context,
                                                          initialDate:
                                                              references[0]
                                                                  .pubDate,
                                                          firstDate:
                                                              DateTime(0),
                                                          lastDate:
                                                              DateTime.now())
                                                      .then((DateTime value) {
                                                    if (value != null) {
                                                      setState(() {
                                                        _publishDate = value;
                                                      });
                                                    }
                                                  });
                                                },
                                                child: Container(
                                                  height: 60,
                                                  decoration: BoxDecoration(
                                                      color: Color(
                                                          widget.projectColor),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      _publishDate == null
                                                          ? Icon(
                                                              Icons.edit,
                                                              color:
                                                                  Colors.white,
                                                            )
                                                          : Text(
                                                              '${_publishDate.day} ${months[_publishDate.month - 1]} ${_publishDate.year}',
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
                                                            ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 15),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 5)
                                    ]),
                                SizedBox(height: 75),
                              ]),

                          // Save Button
                          floatingActionButton: FloatingActionButton(
                              backgroundColor: Color(widget.projectColor),
                              child: Icon(Icons.save),
                              onPressed: () async {
                                setState(() {
                                  if (_formKey.currentState.validate()) {
                                    _updateReference();
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ProjectOverview(
                                                  projectId:
                                                      widget.referenceParent,
                                                  projectTitle:
                                                      widget.projectTitle,
                                                  projectColor:
                                                      widget.projectColor,
                                                  projectRefStyle:
                                                      widget.referenceType,
                                                )),
                                        (Route<dynamic> route) => false);
                                  }
                                });
                              })),
                    );
                  } else {
                    return Center(
                      child: RefreshProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Color(widget.projectColor)),
                      ),
                    );
                  }
                });
          } else {
            return Center(
              child: RefreshProgressIndicator(
                strokeWidth: 3,
                valueColor:
                    AlwaysStoppedAnimation<Color>(Color(widget.projectColor)),
              ),
            );
          }
        });
  }

  InputDecoration buildInputDecoration() {
    return InputDecoration(
        errorStyle: TextStyle(height: 0),
        counterText: '',
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueGrey, width: 1.5)),
        focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(width: 2, color: Color(widget.projectColor))),
        errorBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 2, color: Colors.red)),
        focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 2, color: Colors.red)));
  }
}
