import 'dart:typed_data';

class projectmodel {
  Uint8List projectlogo;
  String projectname;
  List<ProjectInstance> instances;
  int projectid;

  projectmodel({required this.projectlogo, required this.projectname, required this.instances, required this.projectid});
}

class ProjectInstance {
  String projectfromdate;
  String projecttodate;

  ProjectInstance({
    required this.projectfromdate,
    required this.projecttodate,
  });
}
