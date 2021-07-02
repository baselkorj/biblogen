import 'package:moor_flutter/moor_flutter.dart';

part 'moor_database.g.dart';

class Projects extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get refStyle => text()();
  IntColumn get color => integer()();
  DateTimeColumn get created => dateTime()();
  DateTimeColumn get edited => dateTime()();
}

class References extends Table {
  TextColumn get id => text()();
  TextColumn get parent => text()();
  IntColumn get author => integer()();
  TextColumn get title => text()();
  TextColumn get volume => text()();
  TextColumn get page => text()();
  TextColumn get source => text()();
  TextColumn get place => text()();
  DateTimeColumn get acessDate => dateTime()();
  DateTimeColumn get pubDate => dateTime()();
  TextColumn get refType => text()();
}

class Authors extends Table {
  TextColumn get parent => text()();
  TextColumn get first => text()();
  TextColumn get last => text()();
  TextColumn get organization => text()();
}

@UseMoor(tables: [Projects, References, Authors])
class AppDatabase extends _$AppDatabase {
  AppDatabase()
      : super(FlutterQueryExecutor.inDatabaseFolder(
            path: 'db.sqlite', logStatements: true));

  @override
  int get schemaVersion => 1;

  // Project Functions
  Future<List<Project>> getAllProjects() => select(projects).get();
  Stream<List<Project>> watchAllProjects() {
    return (select(projects)
          ..orderBy([
            (t) => OrderingTerm(expression: t.title),
          ]))
        .watch();
  }

  Future insertProject(Project project) => into(projects).insert(project);
  Future updateProject(Project project, String id) {
    return (update(projects)..where((t) => t.id.like(id))).write(project);
  }

  Future deleteProject(Project project, String id) {
    return (delete(projects)..where((t) => t.id.like(id))).go();
  }

  // Reference Functions
  Future<List<Reference>> getAllReferences() => select(references).get();
  Stream<List<Reference>> watchAllReferences(String child) {
    return (select(references)
          ..where((t) => t.parent.equals(child))
          ..orderBy(([
            (t) => OrderingTerm(expression: t.title, mode: OrderingMode.asc)
          ])))
        .watch();
  }

  Stream<List<Reference>> watchAllReferencesID(String id) {
    return (select(references)..where((t) => t.id.equals(id))).watch();
  }

  Future insertReference(Reference reference) =>
      into(references).insert(reference);
  Future updateReference(Reference reference, String id) {
    return (update(references)..where((t) => t.id.like(id))).write(reference);
  }

  Future deleteReference(Reference reference, String id) {
    return (delete(references)..where((t) => t.id.like(id))).go();
  }

  Future deleteReferences(Reference reference, String parent) {
    return (delete(references)..where((t) => t.parent.like(parent))).go();
  }

  // Author Functions
  Future<List<Author>> getAllAuthors() => select(authors).get();
  Stream<List<Author>> watchAllAuthors(String child) {
    return (select(authors)..where((t) => t.parent.equals(child))).watch();
  }

  Future insertAuthor(Author author) => into(authors).insert(author);
  Future updateAuthor(Author author, String parent) {
    return (update(authors)..where((t) => t.parent.like(parent))).write(author);
  }

  Future deleteAuthor(Author author, String parent) {
    return (delete(authors)..where((t) => t.parent.like(parent))).go();
  }
}
