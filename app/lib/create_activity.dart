import 'package:codelab_timetracker/page_activities.dart';
import 'package:codelab_timetracker/tree.dart' hide getTree;
// the old getTree()
import 'package:codelab_timetracker/requests.dart';
// has the new getTree() that sends an http request to the server

import 'package:flutter/material.dart';
import 'dart:async';

//enum SingingCharacter { Project, Task }

class CreateActivity extends StatefulWidget {
  int parentId;
  String parentName;


  //Cal el nom del pare pel TimeTracekr pugui posar a l'arbre
  CreateActivity(this.parentId, this.parentName);

  @override
  _CreateActivityState createState() => _CreateActivityState();

}

class _CreateActivityState extends State<CreateActivity> {
  int parentId;
  String parentName;
  String newName;
  String tagsByComas;
  bool isProject = true;


  final myControllerName = new TextEditingController();//per guardar els inpus name i tags
  final myControllerTags = new TextEditingController();//per guardar els inpus name i tags

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myControllerName.dispose();
    myControllerTags.dispose();
    super.dispose();
  }


  @override
  void initSate() {
    super.initState();
    parentId = widget.parentId;
    parentName = widget.parentName;
    newName = null;
    tagsByComas = null;
    isProject = true;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTap:(){
        FocusScope.of(context).requestFocus(new FocusNode());
    },
      child: Scaffold(
          resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('Create activity'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextField(
                  controller: myControllerName,
                  decoration: InputDecoration(
                    labelText: 'Activity name',
                    hintText: 'Enter name',
                    labelStyle: TextStyle(
                      fontSize: 22.0,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold
                  ),
                  ),
                  cursorColor: Colors.blue[500],
                  // keyboardType: TextInputType.name,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: myControllerTags,
                  decoration: InputDecoration(
                    labelText: 'Tags (optional)',
                    hintText: 'Tags words separated by commas',
                    labelStyle: TextStyle(
                      fontSize: 22.0,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold
                  ),
                  ),
                  cursorColor: Colors.blue[500],
                  // keyboardType: TextInputType.name,
                ),
                SizedBox(height: 30),
                Text('Select type:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                //Tipus Proj o Task canviar a botons
                ListTile(
                  title: const Text('Project'),
                  leading: Radio(
                    value: true,
                    groupValue: this.isProject,
                    onChanged: (bool value) {
                      setState(() {
                        this.isProject = value;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Task'),
                  leading: Radio(
                    value: false,
                    groupValue: this.isProject,
                    onChanged: (bool value) {
                      setState(() {
                        this.isProject = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 120),
                Center(
                 child: FlatButton(
                    onPressed: () {
                      //server case 'add'
                      setState(() {
                        this.newName = myControllerName.text;
                        //per la funció add server tenir algun valor al URL indicador de empty
                        if(myControllerTags.text != ""){ this.tagsByComas = myControllerTags.text; }
                        else {this.tagsByComas = "empty_of_tags";}
                        this.parentName = widget.parentName;
                        this.parentId = widget.parentId;
                      });
                      add(this.parentId,this.parentName, this.newName, this.tagsByComas, this.isProject);
                      _activityCreated(this.parentId);
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.blue[500])),
                    color: Colors.blue[500],
                    textColor: Colors.white,
                    padding: const EdgeInsets.all(10.0),
                    child: Text("Create",
                        style: TextStyle(fontSize: 20)),
                  ),
                ),

              ],

          ),

        ),

        // floatingActionButton: FloatingActionButton.extended(
        //     onPressed: (){
        //     //server case 'add'
        //       setState(() {
        //         this.newName = myControllerName.text;
        //         this.tagsByComas = myControllerTags.text;
        //         this.parentName = widget.parentName;
        //         this.parentId = widget.parentId;
        //       });
        //       add(this.parentId,this.parentName, this.newName, this.tagsByComas, this.isProject);
        //       _activityCreated(this.parentId);
        //       },
        //     label: Text('Create'),
        //     backgroundColor: Colors.blue[500],
        // ),
      ),
    );
  }

  void _activityCreated(int parentId) async{

    Navigator.of(context)
        .push(MaterialPageRoute<void>(
      builder: (context) => PageActivites(parentId),
    )).then( (var value) {
      //_activateTimer();
      //_refresh();
    });


}





}