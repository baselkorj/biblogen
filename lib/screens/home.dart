import 'package:flutter/material.dart';
import 'package:biblogen/database/moor_database.dart';
import 'package:biblogen/screens/add/proj/proj_add.dart';
import 'package:biblogen/screens/add/proj/proj_edit.dart';
import 'package:biblogen/screens/add/proj/proj_preview.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App Bar
      appBar: AppBar(
        title: Text('Projects'),
        backgroundColor: Colors.grey[800],
        actions: [
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          )
        ],
      ),

      // Body
      body: Container(
        child: _buildProjectList(context),
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddProject()));
        },
        label: Text('Project'),
        icon: Icon(Icons.add),
        backgroundColor: Colors.pink,
      ),
    );
  }

  // A stream that returns a list of created projects
  StreamBuilder<List<Project>> _buildProjectList(BuildContext context) {
    final database = Provider.of<AppDatabase>(context);
    return StreamBuilder(
      stream: database.watchAllProjects(),
      builder: (context, AsyncSnapshot<List<Project>> snapshot) {
        if (snapshot.hasData) {
          final projects = snapshot.data ?? List();

          // If no projects are found
          if (projects.length == 0) {
            return ProjectMessage(); // Display this message
          } else {
            // Otherwise display the returned project list
            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              itemCount: projects.length,
              itemBuilder: (_, index) {
                final itemProject = projects[index];
                return _buildListItem(itemProject, database);
              },
            );
          }
        } else {
          return Center(
            child: RefreshProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
            ),
          );
        }
      },
    );
  }

  // Project item in list
  Widget _buildListItem(Project itemProject, AppDatabase database) {
    return InkWell(
      onTap: () {
        // Navigate to proj_overview.dart while carrying relavent variables
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => ProjectOverview(
                      projectId: itemProject.id,
                      projectTitle: itemProject.title,
                      projectColor: itemProject.color,
                      projectRefStyle: itemProject.refStyle,
                    )),
            (Route<dynamic> route) => false);
      },
      child: Card(
        child: ListTile(
            title: Text(
              itemProject.title,
              softWrap: false,
              overflow: TextOverflow.fade,
              maxLines: 1,
            ),
            subtitle: Text('${itemProject.refStyle}'),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // Navigate to proj_edit.dart along with relavent variables
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditProject(
                          projectId: itemProject.id,
                          projectTitle: itemProject.title,
                          projectRefStyle: itemProject.refStyle,
                          projectColor: itemProject.color,
                          projectCreated: itemProject.created)),
                );
              },
            ),
            leading: CircleAvatar(backgroundColor: Color(itemProject.color))),
      ),
    );
  }
}

// Message to display if no projects are found
class ProjectMessage extends StatelessWidget {
  const ProjectMessage({
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
            child: Text('No projects found!',
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
                'to add a project.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          )
        ]);
  }
}
