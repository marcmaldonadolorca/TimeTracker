import 'package:codelab_timetracker/page_activities.dart';
import 'package:codelab_timetracker/page_intervals.dart';
import 'package:codelab_timetracker/search_options.dart';
import 'package:codelab_timetracker/tree.dart' hide getTree;
import 'package:flutter/material.dart';
import 'package:codelab_timetracker/requests.dart';
// has the new getTree() that sends an http request to the server

import 'dart:async';

//enum SingingCharacter { Project, Task }

class SearchRecentTask extends StatefulWidget {


  //Cal el nom del pare pel TimeTracekr pugui posar a l'arbre
  SearchRecentTask();

  @override
  _SearchRecentTaskState createState() => _SearchRecentTaskState();

}

class _SearchRecentTaskState extends State<SearchRecentTask> {
  String tagTarget;
  Future<Tree> futureTree;//obtindrem la lllista en forma de pare(missatger) i fills(resultat)
  bool noResults;

  final myControllerTag = new TextEditingController(); //per guardar els inpus name i tags


  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myControllerTag.dispose();
    super.dispose();
  }


  @override
  void initSate() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTap:(){
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text('Search Recent Tasks'),
            actions: <Widget>[
              IconButton(icon: Icon(Icons.home),
                  onPressed: () {
                    while(Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                    PageActivites(0);
                  }),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(  "This option will show the 6 latest active task",
                      style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold),
                  ),
                SizedBox(height: 30),
                Center(
                  child: RaisedButton(
                    onPressed: () {
                      _getLastActivities();
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.blue[500])),
                    color: Colors.blue[500],
                    textColor: Colors.white,
                    padding: const EdgeInsets.all(10.0),
                    child: Text("  Search  ",
                        style: TextStyle(fontSize: 20)),
                  ),
                ),
                SizedBox(height: 20),
                Text('Activities found: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                _getResultsList(),

              ],
            ),
          )
      ),
    );

    throw UnimplementedError();
  }

  void _getLastActivities() async {
    this.tagTarget = myControllerTag.text;//capturo el tag escrit
    if(this.tagTarget != null){
      this.futureTree = searchRecentTasks();
      setState(() {noResults=true;});//fa que es torni a cridar build
    }
  }

  Widget _getResultsList() {
    if (futureTree == null) {
      return Center();
    } else if (!noResults) {
      return Center(
        child: Text(
          'No results found',
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    } else {
      return FutureBuilder<Tree>(
          future: futureTree,
          builder: (context, snapshot){
            if(snapshot.hasData){
              //return Center(
                //Peta al fer el dibuix diu que falta especificar com dibuixar...
                // child: ListView.separated(
                //   // it's like ListView.builder() but better because it includes a separator between items
                //   padding: const EdgeInsets.all(16.0),
                //   itemCount: snapshot.data.root.children.length,
                //   itemBuilder: (BuildContext context, int index) =>
                //       _buildRow(snapshot.data.root.children[index], index),
                //   separatorBuilder: (BuildContext context, int index) =>
                //   const Divider(),
                //child: _getNamesActivities(snapshot.data.root),
                //),
              //);
              return new Row(
                children: <Widget>[
                  Expanded(
                    child: SizedBox(
                      height: 500.0,
                      child: new ListView.separated(
                        // it's like ListView.builder() but better because it includes a separator between items
                        padding: const EdgeInsets.all(16.0),
                        itemCount: snapshot.data.root.children.length,
                        itemBuilder: (BuildContext context, int index) =>
                            _buildRow(snapshot.data.root.children[index], index),
                        separatorBuilder: (BuildContext context, int index) =>
                        const Divider(),
                      ),),),],);
            }else{
              return Center(child: Text(
                'No results found',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),);
            }
          }
      );
    }
  }

  Widget _getNamesActivities(Activity root){
    String noms="";String tmp="·";
    if(!root.children.isEmpty){
      for(Activity aux in root.children){
        noms= noms+tmp+aux.name; tmp="  ·";
      }
    }else{ noms = "There are not activities previously activated";}
    // return Text(noms,
    //
    //   textAlign: TextAlign.center,
    //   overflow: TextOverflow.ellipsis,
    //   style: TextStyle(fontWeight: FontWeight.bold),);

    return Column(
      children: [
        Text("Activities found:", style: TextStyle(
            fontSize: 18.0,
            color: Colors.grey[700],
            fontWeight: FontWeight.bold
        ),),
        SizedBox(height: 30),

        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: "",
            style: TextStyle(
                fontSize: 18.0,
                color: Colors.blue[500],
                fontWeight: FontWeight.bold
            ),
            children: <TextSpan>[
              TextSpan(

                //text: (snapshot.data.root as Project).duration.toString(),
                text: noms,
                style: TextStyle(fontSize: 18.0,
                    color: Colors.blue[500],
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
      ],
    );
  }

  /* Funcions copiades de PAGE_aCtivities perk l'iport no xuta!!!!*/
  Widget _buildRow(Activity activity, int index) {
    //String strDuration = Duration(seconds: activity.duration).toString().split('.').first;
    // split by '.' and taking first element of resulting list removes the microseconds part
    //this.activityId = activity.id;
    if (activity is Project) {
      //if(!activity.activeChilds){
      if(!activity.active){
        return ListTile(
          title: Text('${activity.name}', style: TextStyle(fontWeight: FontWeight.bold),),
          //trailing: Text(_formatDuration(activity)),
          subtitle: Text(_formatDuration(activity)),
          leading: new Icon(Icons.folder, color: Colors.amber,),
          onTap: () => _navigateDownActivities(activity.id),
        );//
      }else{
        return ListTile(
          title: Text('${activity.name}', style: TextStyle(fontWeight: FontWeight.bold),),
          //trailing: Text(_formatDuration(activity),style: TextStyle(color:Colors.blue[500])),
          subtitle: Text(_formatDuration(activity),style: TextStyle(color:Colors.blue[500])),
          leading: new Icon(Icons.folder, color: Colors.amber,),
          onTap: () => _navigateDownActivities(activity.id),);
      }
    } else if (activity is Task) {
      Task task = activity as Task;
      // at the moment is the same, maybe changes in the future
      Widget timeSpent;
      if(task.active == false) {
        timeSpent = Text(_formatDuration(activity));
      }else{
        timeSpent = Text(_formatDuration(activity),style: TextStyle(color:Colors.blue[500]));
      }

      return ListTile(
        title: Text('${activity.name}', style: TextStyle(fontWeight: FontWeight.bold),),
        subtitle: timeSpent,
        leading: new Icon(Icons.assignment, color: Colors.orange,),//list_alt_rounded//description//note
        onTap: () => _navigateDownIntervals(activity.id),
      );
    }
  }



  Widget _activeTask(Activity activity){
    if(activity.active == false){
      return Icon(Icons.play_arrow, color: Colors.blue.shade400,);
    }
    else { return Icon(Icons.pause, color: Colors.blue.shade400,);}
  }

  bool _getActiveTask(Activity activity){
    bool active = false;
    for(int i=0;i<activity.children.length;i++){//la resposta del server per aquesta  vista és un arbre amb el seleccionat i els fills directes. FAltaria poder tenir tot l'arbre de sota
      if(activity.children[i] is Task){
        if(activity.children[i].active == true){
          active = true;
          break;
        }
      }
    }
    return active;
  }

  String _formatDuration(dynamic activity){
    String strDuration = Duration(seconds: activity.duration).toString().split('.').first;
    return strDuration;
  }

  String _formatDate(DateTime date){
    String strInitialDate = date.toString().split('.')[0];
    return strInitialDate;
  }

  void _navigateDownActivities(int childId) {

    // we can not do just _refresh() because then the up arrow doesnt appear in the appbar
    Navigator.of(context)
        .push(MaterialPageRoute<void>(
      builder: (context) => PageActivites(childId),
    )).then( (var value) {

    });
    //https://stackoverflow.com/questions/49830553/how-to-go-back-and-refresh-the-previous-page-in-flutter?noredirect=1&lq=1
  }

  void _navigateDownIntervals(int childId) {

    Navigator.of(context)
        .push(MaterialPageRoute<void>(
      builder: (context) => PageIntervals(childId),
    )).then( (var value) {
    });
  }



}