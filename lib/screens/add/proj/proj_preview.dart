import 'package:biblogen/pdf_generators.dart';
import 'package:flutter/material.dart';
import 'package:biblogen/database/moor_database.dart';
import 'package:biblogen/screens/add/ref/ref_book_add.dart';
import 'package:biblogen/screens/add/ref/ref_book_edit.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:biblogen/screens/home.dart';
import 'package:provider/provider.dart';

class ProjectOverview extends StatefulWidget {
  final projectId;
  final projectTitle;
  final projectRefStyle;
  final projectColor;

  ProjectOverview(
      {this.projectId,
      this.projectTitle,
      this.projectRefStyle,
      this.projectColor});

  @override
  _ProjectOverviewState createState() => _ProjectOverviewState();
}

class _ProjectOverviewState extends State<ProjectOverview> {
  // Forward to the correct reference creation page
  // based on the selected reference type
  Future forwardType(String type) {
    if (type == 'Book') {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AddBookReference(
                    projectId: widget.projectId,
                    projectTitle: widget.projectTitle,
                    projectColor: widget.projectColor,
                    referenceType: widget.projectRefStyle,
                  )));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App Bar
      appBar: AppBar(
        // Substituted the default back arrow in flutter with
        // a custom one that always navigates to Home()
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Home()),
                (Route<dynamic> route) => false);
          },
        ),
        title: Text('${widget.projectTitle}',
            softWrap: false, overflow: TextOverflow.fade),
        backgroundColor: Color(widget.projectColor),
        actions: [
          IconButton(
            icon: Icon(Icons.outbox),
            onPressed: () {
              savePDF();
            },
          )
        ],
      ),

      // Body
      body: Container(
        child: _buildReferenceList(context),
      ),

      // Floating Action Button
      floatingActionButton: buildRefDial(),
    );
  }

  SpeedDial buildRefDial() {
    return SpeedDial(
      marginEnd: 18,
      marginBottom: 20,
      icon: Icons.add,
      activeIcon: Icons.close,
      buttonSize: 56.0,
      visible: true,
      closeManually: false,
      renderOverlay: false,
      curve: Curves.bounceIn,
      overlayColor: Colors.black,
      overlayOpacity: 0.35,
      onOpen: () {},
      onClose: () {},
      tooltip: 'Speed Dial',
      heroTag: 'speed-dial-hero-tag',
      backgroundColor: Color(widget.projectColor),
      foregroundColor: Colors.white,
      elevation: 8.0,
      shape: CircleBorder(),
      children: [
        SpeedDialChild(
          child: Icon(Icons.web),
          backgroundColor: Color(widget.projectColor),
          foregroundColor: Colors.white,
          label: 'Website',
          labelStyle: TextStyle(fontSize: 16.0),
          onTap: () {
            forwardType('Website');
          },
        ),
        SpeedDialChild(
          child: Icon(Icons.bookmark),
          backgroundColor: Color(widget.projectColor),
          foregroundColor: Colors.white,
          label: 'Journal',
          labelStyle: TextStyle(fontSize: 16.0),
          onTap: () {
            forwardType('Journal');
          },
        ),
        SpeedDialChild(
          child: Icon(Icons.book),
          backgroundColor: Color(widget.projectColor),
          foregroundColor: Colors.white,
          label: 'Book',
          labelStyle: TextStyle(fontSize: 16.0),
          onTap: () {
            forwardType('Book');
          },
        ),
      ],
    );
  }

  StreamBuilder<List<Reference>> _buildReferenceList(BuildContext context) {
    final database = Provider.of<AppDatabase>(context);
    return StreamBuilder(
      stream: database.watchAllReferences(widget.projectId),
      builder: (context, AsyncSnapshot<List<Reference>> snapshot) {
        if (snapshot.hasData) {
          final references = snapshot.data ?? List();
          if (references.length == 0) {
            return ReferenceMessage();
          } else {
            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              itemCount: references.length,
              itemBuilder: (_, index) {
                final itemReference = references[index];
                return _buildListItem(itemReference, database);
              },
            );
          }
        } else {
          return Center(
            child: RefreshProgressIndicator(
              strokeWidth: 3,
              valueColor:
                  AlwaysStoppedAnimation<Color>(Color(widget.projectColor)),
            ),
          );
        }
      },
    );
  }

  StreamBuilder<List<Author>> _buildAuthorList(
      Reference itemReference, BuildContext context) {
    final database = Provider.of<AppDatabase>(context);
    return StreamBuilder(
      stream: database.watchAllAuthors(itemReference.id),
      builder: (context, AsyncSnapshot<List<Author>> snapshot) {
        if (snapshot.hasData) {
          final authors = snapshot.data ?? List();
          print(authors);
          if (itemReference.author == 0) {
            if (authors.length == 1) {
              return Text(
                  '[ ${authors[0].last} ${itemReference.pubDate.year} ]',
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  maxLines: 1);
            } else {
              return Text(
                  '[ ${authors[0].last} et al ${itemReference.pubDate.year} ]',
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  maxLines: 1);
            }
          } else {
            return Text(
              '[ ${authors[0].organization} ${itemReference.pubDate.year} ]',
              softWrap: false,
              overflow: TextOverflow.fade,
              maxLines: 1,
            );
          }
        } else {
          return Container();
        }
      },
    );
  }

  Widget _buildListItem(Reference itemReference, AppDatabase database) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EditReference(
                      projectId: widget.projectId,
                      projectTitle: widget.projectTitle,
                      projectColor: widget.projectColor,
                      referenceType: itemReference.refType,
                      referenceId: itemReference.id,
                      referenceParent: itemReference.parent,
                    )));
      },
      child: Card(
        child: ListTile(
            title: Text(
              '${itemReference.title}',
              softWrap: false,
              overflow: TextOverflow.fade,
              maxLines: 1,
            ),
            subtitle: _buildAuthorList(itemReference, context),
            leading: CircleAvatar(
                backgroundColor: Color(widget.projectColor),
                child: Icon(
                  itemReference.refType == 'Book'
                      ? Icons.book
                      : itemReference.refType == 'Journal'
                          ? Icons.bookmark
                          : Icons.web,
                  color: Colors.white,
                ))),
      ),
    );
  }
}

class ReferenceMessage extends StatelessWidget {
  const ReferenceMessage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.search, color: Colors.grey, size: 64),
          SizedBox(height: 10),
          Align(
            alignment: Alignment.center,
            child: Text('No references found!',
                style: TextStyle(color: Colors.grey)),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Use ',
                style: TextStyle(color: Colors.grey),
              ),
              Icon(
                Icons.add,
                color: Colors.grey,
              ),
              Text(
                'to add a reference.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          )
        ]);
  }
}
