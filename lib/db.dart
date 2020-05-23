class Subject{
  int id;
  String name;
  int present;
  int absent;

  Subject(this.id, this.name, this.present , this.absent);

  Map<String, dynamic> toMap() {
    var map = <String , dynamic>{
      'id': id,
      'name': name,
      'present': present,
      'absent': absent
    };
    return map;
  }

  Subject.fromMap(Map<String , dynamic> map) {
    id = map['id'];
    name = map["name"];
    absent = map["absent"];
    present = map["present"];
  }

  @override
  String toString() {
    return 'Subject{id: $id, name: $name, present: $present, absent: $absent}';
  }
}
