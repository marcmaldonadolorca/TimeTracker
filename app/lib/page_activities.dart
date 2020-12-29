import 'package:codelab_timetracker/page_intervals.dart';
//import 'package:codelab_timetracker/tree.dart';
import 'package:codelab_timetracker/tree.dart' hide getTree;
// the old getTree()
import 'package:codelab_timetracker/requests.dart';
// has the new getTree() that sends an http request to the server

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/material.dart';


class PageActivites extends StatefulWidget {
  int id;

  PageActivites(this.id);

  @override
  _PageActivitesState createState() => _PageActivitesState();
}

class _PageActivitesState extends State<PageActivites> {
  int id;
  Future<Tree> futureTree;
  int activityId;

  Timer _timer;
  static const int periodeRefresh = 6;
  // better a multiple of periode in TimeTracker, 2 seconds

  @override
  void initState() {
    super.initState();
    id = widget.id; // of PageActivities
    activityId = 0;
    futureTree = getTree(id);
    _activateTimer();

  }

  int _selectedIndex = 0;
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: optionStyle,

    ),
    Text(
      'Index 1: Business',
      style: optionStyle,
    ),
    Text(
      'Index 2: School',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) {
          while(Navigator.of(context).canPop()) {
            print("pop");
            Navigator.of(context).pop();
          }
          PageActivites(0);
      }
    });
  }

  // future with listview
  // https://medium.com/nonstopio/flutter-future-builder-with-list-view-builder-d7212314e8c9
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Tree>(
      future: futureTree,
      // this makes the tree of children, when available, go into snapshot.data
      builder: (context, snapshot) {
        // anonymous function
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text(snapshot.data.root.name ?? 'TimeTracker'),
              actions: <Widget>[
                IconButton(icon: Icon(Icons.home),
                    onPressed: () {
                      while(Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                      /* this works also:
                      Navigator.popUntil(context, ModalRoute.withName('/'));
                      */
                      PageActivites(0);
                    }),
                IconButton(icon: Icon(Icons.info_outline),
                    onPressed: () {
                  //A LA PAGEACTIVITIES SEMPRE SERÀ PROJECT PK SINÓ ESTARIEM A LA PAGE_INTERVALS!!!!!!!!
                      if (snapshot.data.root is Project ) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                scrollable: true,
                                title:
                                RichText(
                                text: TextSpan(
                                text: snapshot.data.root.name.toString(),
                                style: TextStyle(
                                  fontSize: 22.0,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.bold
                                ),
                                )
                                ),
                                content: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      RichText(
                                        text: TextSpan(
                                          text: 'Duration: ',
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              color: Colors.grey[700],
                                              fontWeight: FontWeight.bold
                                          ),
                                          children: <TextSpan>[
                                            TextSpan(
                                              //text: (snapshot.data.root as Project).duration.toString(),
                                              text: _formatDuration((snapshot.data.root as Project)),
                                              style: TextStyle(color: Colors.blue[500]),
                                            )
                                          ],
                                        ),
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          text: 'Start date: ',
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              color: Colors.grey[700],
                                              fontWeight: FontWeight.bold
                                          ),
                                          children: <TextSpan>[
                                            TextSpan(
                                              //text: (snapshot.data.root as Project).initialDate.toString(),
                                              text: _formatDate((snapshot.data.root as Project).initialDate),
                                              style: TextStyle(color: Colors.blue[500]),
                                            )
                                          ],
                                        ),
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          text: 'End date: ',
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              color: Colors.grey[700],
                                              fontWeight: FontWeight.bold
                                          ),
                                          children: <TextSpan>[
                                            TextSpan(
                                              //text: (snapshot.data.root as Project).finalDate.toString(),
                                              text: _formatDate((snapshot.data.root as Project).finalDate),
                                              style: TextStyle(color: Colors.blue[500]),
                                            )
                                          ],
                                        ),
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          text: 'Child activities: ',
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              color: Colors.grey[700],
                                              fontWeight: FontWeight.bold
                                          ),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: (snapshot.data.root as Project).children.length.toString(),
                                              style: TextStyle(color: Colors.blue[500]),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  RaisedButton(
                                    onPressed: () {Navigator.of(context, rootNavigator: true).pop('dialog');},
                                    textColor: Colors.white,
                                    padding: const EdgeInsets.all(0.0),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: <Color>[
                                            Color(0xFF0D47A1),
                                            Color(0xFF1976D2),
                                            Color(0xFF42A5F5),
                                          ],
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(10.0),

                                      child: const Text(
                                          "Close",
                                          style: TextStyle(
                                              fontSize: 20.0,
                                              color: Colors.white
                                          )
                                      ),
                                    ),
                                  ),
                                  /*RaisedButton(
                                      child: const Text(
                                        "Close",
                                        style: TextStyle(
                                            fontSize: 20.0,
                                            color: Colors.white
                                        )
                                      ),
                                      onPressed: () {
                                        Navigator.of(context, rootNavigator: true).pop('dialog');
                                      })*/
                                ],
                              );
                            });
                      } else if (snapshot.data.root is Task ) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                scrollable: true,
                                //Text(snapshot.data.root.children[0].name),
                                title: Text(snapshot.data.root.name),
                                content: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: <Widget>[
                                      Text("Duration: " +
                                          snapshot.data.root.duration.toString()
                                      ),
                                      Text("Parent: " + ""),
                                      Text("Tags: " + ""),
                                      Text("Start date: " + ""),
                                      Text("End date: " +
                                          snapshot.data.root.finalDate.toString()),
                                      Text("Status: " + (snapshot.data.root as Task).active.toString()),
                                    ],
                                  ),
                                ),
                                actions: [
                                  RaisedButton(
                                      child: Text("Submit"),
                                      onPressed: () {
                                        // your code
                                      })
                                ],
                              );
                            });
                      }
                    }
                ),
                IconButton(icon: Icon(Icons.search),
                    onPressed: () {
                  print(snapshot.data.root.toString());
                      //TODO: llamar a la página de búsqueda
                      }
                    ),
              ],
            ),
            body: ListView.separated(
              // it's like ListView.builder() but better because it includes a separator between items
              padding: const EdgeInsets.all(16.0),
              itemCount: snapshot.data.root.children.length,
              itemBuilder: (BuildContext context, int index) =>
                  _buildRow(snapshot.data.root.children[index], index),
              separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
            ),

            floatingActionButton: FloatingActionButton(
              onPressed: () {
                // Add your onPressed code here!
              },
              child: Icon(Icons.add),
              backgroundColor: Colors.blue[500],
            ),


            // bottomNavigationBar: BottomNavigationBar(
            //   items: const <BottomNavigationBarItem>[
            //     BottomNavigationBarItem(
            //       icon: Icon(Icons.home),
            //       label: 'Home',
            //     ),
            //     BottomNavigationBarItem(
            //       icon: Icon(Icons.add),
            //       label: 'Business',
            //     ),
            //     BottomNavigationBarItem(
            //       icon: Icon(Icons.info_outline),
            //       label: 'School',
            //     ),
            //   ],
            //   currentIndex: _selectedIndex,
            //   selectedItemColor: Colors.blue[500],
            //   onTap: _onItemTapped,
            // )
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}" ?? "Error default");
        }
        // By default, show a progress indicator
        return Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: Center(
              child: CircularProgressIndicator(),
            ));
      },
    );
  }

  Widget _buildRow(Activity activity, int index) {
    //String strDuration = Duration(seconds: activity.duration).toString().split('.').first;
    // split by '.' and taking first element of resulting list removes the microseconds part
    this.activityId = activity.id;
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
        trailing: IconButton(icon: _activeTask(activity),
            onPressed: () { _startOrStop(activity); }),
        onTap: () => _navigateDownIntervals(activity.id),
        onLongPress: () { _startOrStop(activity);
        },
      );
    }
  }

  void _startOrStop(Activity activity){
    print("Premuda tecla llarga per: "+activity.id.toString()+" name: "+activity.name);
    if (activity .active) {
      stop(activity.id);
      _refresh(); // to show immediately that task has started
    } else {
      start(activity.id);
      _refresh(); // to show immediately that task has stopped
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


  void _refresh() async {
    futureTree = getTree(id); // to be used in build()
    setState(() {});
  }

  void _navigateDownActivities(int childId) {
    _timer.cancel();
    // we can not do just _refresh() because then the up arrow doesnt appear in the appbar
    Navigator.of(context)
        .push(MaterialPageRoute<void>(
      builder: (context) => PageActivites(childId),
    )).then( (var value) {
      _activateTimer();
      _refresh();
    });
    //https://stackoverflow.com/questions/49830553/how-to-go-back-and-refresh-the-previous-page-in-flutter?noredirect=1&lq=1
  }

  void _navigateDownIntervals(int childId) {
    _timer.cancel();
    Navigator.of(context)
        .push(MaterialPageRoute<void>(
      builder: (context) => PageIntervals(childId),
    )).then( (var value) {
      _activateTimer();
      _refresh();
    });
  }

  void _activateTimer() {
    _timer = Timer.periodic(Duration(seconds: periodeRefresh), (Timer t) {
      futureTree = getTree(id);
      setState(() {});
    });
  }

  @override
  void dispose() {
    // "The framework calls this method when this State object will never build again"
    // therefore when going up
    _timer.cancel();
    super.dispose();
  }
}
