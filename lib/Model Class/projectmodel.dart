import 'dart:typed_data';

class projectmodel {
  Uint8List projectlogo;
  String projectname;
  List<ProjectInstance> instances;
  int projectid;

  projectmodel(
      {required this.projectlogo,
      required this.projectname,
      required this.instances,
      required this.projectid});

  factory projectmodel.fromJson(Map<String, dynamic> json) {
    return projectmodel(
      projectlogo: json['projectlogo'],
      projectname: json['projectname'],
      instances: json['instances'],
      projectid: json['projectid'],
    );
  }
}

class ProjectInstance {
  String projectfromdate;
  String projecttodate;

  ProjectInstance({
    required this.projectfromdate,
    required this.projecttodate,
  });
}
