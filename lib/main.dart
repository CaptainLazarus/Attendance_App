import 'package:flutter/material.dart';
import 'db.dart';
import 'dart:async';
import 'db_func.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue, 
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<Subject>> subjects;
  TextEditingController textField = TextEditingController();
  TextEditingController textField1 = TextEditingController();
  TextEditingController textField2 = TextEditingController();

  String name;
  int present;
  int curUserID;
  int percentage;

  final formKey = new GlobalKey<FormState>();
  var dbHelper;
  int absent;
  bool isUpdating;

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    isUpdating = false;
    refreshList();
  }

  refreshList(){
    setState(() {
      subjects = dbHelper.getSubjects();
    });
  }

  clear(){
    textField.text = "";
    textField1.text = "";
    textField2.text = "";
  }

  validate() {
    if(formKey.currentState.validate()){
      formKey.currentState.save();
      if(isUpdating) {
        Subject s = Subject(curUserID, name , present , absent);
        dbHelper.update(s);
        setState(() {
          isUpdating = false;
        });
      } else {
        Subject s = Subject(null, name, present , absent);
        dbHelper.save(s);
      }
      clear();
      refreshList();
    }
  }

  fill(Subject subject) {
    textField.text = subject.name;
    textField1.text = subject.present.toString();
    textField2.text = subject.absent.toString();
  }

  form() {
    return Form( 
      key: formKey,
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          verticalDirection: VerticalDirection.down,
          children: <Widget>[
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                    child: TextFormField(
                    controller: textField,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(labelText: 'Name'),
                    validator: (val) => val.length == 0 ? "Enter a Name":null,
                    onSaved: (val) => name = val,
                  ),
                ),
                new SizedBox(width: 10.0),
                Expanded(
                  child: TextFormField(
                  controller: textField1,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Present'),
                  validator: (val1) {
                      if(val1.length == 0) {
                        return "No. of days present?";
                      }
                      var present = int.tryParse(val1);
                      if(present == null){
                        return "Enter a Number";
                      }
                      return null;
                    },
                  onSaved: (val1) => present = int.parse(val1),
                )),
                new SizedBox(width: 10.0),
                Expanded(
                  child: TextFormField(
                  controller: textField2,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Absent'),
                  validator: (val2) {
                      if(val2.length == 0) {
                        return "No. of days absent?";
                      }
                      var present = int.tryParse(val2);
                      if(present == null){
                        return "Enter a Number";
                      }
                      return null;
                    },
                  onSaved: (val2) => absent = int.parse(val2),
                ))
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FlatButton(
                  onPressed: validate, 
                  child: Text(isUpdating? 'Update' : 'Add')
                  ),
                  FlatButton(
                  onPressed: () {
                    setState(() {
                      isUpdating = false;
                      }
                    );
                    clear();
                  }
                    , 
                  child: Text('Cancel'))
              ],
            )
          ],
        ),) , 
    );
  }

  ListView listBuilder(List<Subject> subjects) {
    return ListView.builder(
      itemCount: subjects.length,
      itemBuilder: (context , index) {
        return Dismissible(
          background: Container(color: Colors.red),
          onDismissed: (direction) {
            var id = subjects[index].id;
            setState(() {
              subjects.removeAt(index);
            });
            dbHelper.delete(id);
            
            // refreshList();
          },
          key: UniqueKey(),
          child: Center(
            child: Card(  
              child: Column(
                mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile( 
                      onTap: () {
                        setState(() {
                          isUpdating = true;
                          curUserID = subjects[index].id;
                        });
                        fill(subjects[index]);
                      },
                      leading: IconButton(icon: Icon(Icons.add), 
                        onPressed: () {
                          setState(() {
                            subjects[index].present+=1;
                          });
                          dbHelper.update(subjects[index]);
                          refreshList();
                        }),
                      title: Text(subjects[index].name) , 
                      subtitle: Text((subjects[index].present/(subjects[index].present+subjects[index].absent)).toString()),  
                      trailing: IconButton(icon: Icon(Icons.minimize), 
                        onPressed: () {
                          setState(() {
                            subjects[index].absent+=1;
                          });
                          dbHelper.update(subjects[index]);
                          refreshList();
                      })
                    ),
                ],
              )
            )
          ),
        );
      }
    );
  }

  SingleChildScrollView dataTable(List<Subject> subjects) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [  
          DataColumn(label: Text("Name")),
          DataColumn(label: Text("Present")),
          DataColumn(label: Text("Absent")),
          DataColumn(label: Text("Percentage")),
        ] , 
        rows: subjects.map(
          (subject) => DataRow(
            cells: [
              DataCell(Text(subject.name) , 
              onTap: () {
                setState(() {
                  isUpdating = true;
                  curUserID = subject.id;
                });
                fill(subject);
              }) , 
              DataCell(Text(subject.present.toString()) , 
              onTap: () {
                setState(() {
                  isUpdating = true;
                  curUserID = subject.id;
                });
                subject.present+=1;
                dbHelper.update(subject);
                clear();
                refreshList();
              }) , 
              DataCell(Text(subject.absent.toString()) , 
              onTap: () {
                setState(() {
                  isUpdating = true;
                  curUserID = subject.id;
                });
                subject.absent+=1;
                dbHelper.update(subject);
                clear();
                refreshList();
              }) ,
              // DataCell(IconButton(
              //     icon: Icon(Icons.delete_outline), 
              //     onPressed: () {
              //       dbHelper.delete(subject.id);
              //       refreshList();
              //     },
              //   )
              // ) ,
              DataCell(Text((subject.present*100/(subject.absent + subject.present)).toString()) , )
            ] ,)
        ).toList(),)
    );
  }



  list() {
    return Expanded(
      child: FutureBuilder(
      future: subjects,
      builder: (context,snapshot) {
        if(snapshot.hasData) {
          return listBuilder(snapshot.data);
        }
        if(snapshot.data == null || snapshot.data.length == 0){
          return Text("No Subjects Found");
        }

        return CircularProgressIndicator();
      }
      ), 
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            form() , 
            list()
          ],
        ),
      ),
    );
  }
}
