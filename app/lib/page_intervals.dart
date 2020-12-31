import 'dart:async';

import 'package:codelab_timetracker/page_activities.dart';
import 'package:codelab_timetracker/search_options.dart';
import 'package:codelab_timetracker/tree.dart';
import 'package:flutter/material.dart';
import 'package:codelab_timetracker/tree.dart' as Tree hide getTree;
// to avoid collision with an Interval class in another library
import 'package:codelab_timetracker/requests.dart';

import 'package:codelab_timetracker/page_intervals.dart';

class PageIntervals extends StatefulWidget {
  int id;

  PageIntervals(this.id);

  @override
  _PageIntervalsState createState() => _PageIntervalsState();
}

class _PageIntervalsState extends State<PageIntervals> {
  int id;
  Future<Tree.Tree> futureTree;

  Timer _timer;
  static const int periodeRefresh = 6;
  // better a multiple of periode in TimeTracker, 2 seconds

  @override
  void initState() {
    super.initState();
    id = widget.id;
    futureTree = getTree(id);
    _activateTimer();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Tree.Tree>(
      future: futureTree,
      // this makes the tree of children, when available, go into snapshot.data
      builder: (context, snapshot) {
        // anonymous function
        if (snapshot.hasData) {
          int numChildren = snapshot.data.root.children.length;
          return Scaffold(
            appBar: AppBar(
              title: Text(snapshot.data.root.name),
              actions: <Widget>[
                // Icon(
                //   Icons.update_outlined,
                //   color: Colors.white,
                //   size: 30.0,
                // ),

                IconButton(icon: Icon(Icons.info_outline),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context){
                      return AlertDialog(
                        scrollable: true,
                      title: Text(snapshot.data.root.name,
                        style: TextStyle(
                            fontSize: 22.0,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.bold
                        ),),
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
                                      text: _formatDuration(snapshot.data.root ),
                                      style: TextStyle(color: Colors.blue[500]),
                                    )
                                  ],
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  text: 'Parent: ',
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.bold
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      //text: (snapshot.data.root as Project).duration.toString(),
                                      text: snapshot.data.root.parentName,
                                      style: TextStyle(color: Colors.blue[500]),
                                    )
                                  ],
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  text: 'Tags: ',
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.bold
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      //text: (snapshot.data.root as Project).duration.toString(),
                                      text: snapshot.data.root.tags[0],
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
                                      text: _formatDate(snapshot.data.root.initialDate),
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
                                      text: _formatDate(snapshot.data.root.finalDate),
                                      style: TextStyle(color: Colors.blue[500]),
                                    )
                                  ],
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  text: 'Active: ',
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.bold
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: snapshot.data.root.active.toString(),
                                      style: TextStyle(color: Colors.blue[500]),
                                    )
                                  ],
                                ),
                              ),
                              //Text("Status: " + (snapshot.data.root as Task).active.toString()),
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
                        ],
                      );
                  });
                }
                ),
                IconButton(icon: Icon(Icons.search),
                    onPressed: () {
                      _navigateSearchOptions();
                      //TODO: llamar a la página de búsqueda
                    }
                ),
                IconButton(icon: Icon(Icons.home),
                    onPressed: () {
                      while(Navigator.of(context).canPop()) {
                        print("pop");
                        Navigator.of(context).pop();
                      }
                      /* this works also:
                      Navigator.popUntil(context, ModalRoute.withName('/'));
                      */
                      PageActivites(0);
                    }),
              ],
            ),
            body: ListView.separated(
              // it's like ListView.builder() but better because it includes a separator between items
              padding: const EdgeInsets.all(16.0),
              itemCount: numChildren,
              itemBuilder: (BuildContext context, int index) =>
                  _buildRow(snapshot.data.root.children[index], index),
              separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
            ),

            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                // Add your onPressed code here!
                _startOrStop(snapshot.data.root);
              },
              label: _startOrStopTaskWord(snapshot.data.root),
              icon: _startOrStopTaskView(snapshot.data.root),
              backgroundColor: Colors.blue[500],
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
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

  Widget _startOrStopTaskWord(Activity activity){
    if(activity.active){
      return Text('Stop',style: TextStyle(fontSize: 20));
    }else{
      return Text('Start', style: TextStyle(fontSize: 20));
    }
  }

  Widget _startOrStopTaskView(Activity activity){
    if(activity.active){
      return Icon(Icons.pause_circle_filled, color: Colors.white,);
    }else{
      return Icon(Icons.play_circle_filled,color: Colors.white,);
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

  void _refresh() async {
    futureTree = getTree(id); // to be used in build()
    setState(() {});
  }

  Widget _buildRow(Tree.Interval interval, int index) {
    //String strDuration = Duration(seconds: interval.duration).toString().split('.').first;
    //String strInitialDate = interval.initialDate.toString().split('.')[0];
    // this removes the microseconds part
    //String strFinalDate = interval.finalDate.toString().split('.')[0];
    if(!interval.active) {
      return ListTile(
        //title: Text('from ${_formatDate(interval.initialDate)} to ${_formatDate(interval.finalDate)}' ),
        title: Text('Interval ${interval.numOrder}',style: TextStyle(fontWeight: FontWeight.bold),),
        subtitle: Text('Start date:'),
        //trailing: Text(_formatDuration(interval)),
        trailing: Column(
          children: <Widget>[
            Text('${_formatDuration(interval)} seconds'),
            Text(_formatDate(interval.initialDate)),
          ]
        ),
      );
    } else {
      return ListTile(
        //title: Text('from ${_formatDate(interval.initialDate)} to ${_formatDate(interval.finalDate)}',
        //style: TextStyle(color:Colors.blue[500])),
        title: Text('Interval ${interval.numOrder}',
            style: TextStyle(color:Colors.blue[500], fontWeight: FontWeight.bold)),
        subtitle: Text('Start date:',style: TextStyle(color:Colors.blue[500])),
        //trailing: Text(_formatDuration(interval),style: TextStyle(color:Colors.blue[500])),
        trailing: Column(
            children: <Widget>[
              Text('${_formatDuration(interval)} seconds',style: TextStyle(color:Colors.blue[500])),
              Text(_formatDate(interval.initialDate),style: TextStyle(color:Colors.blue[500])),
            ]
        ),
      );
    }

  }

  String _formatDuration(dynamic activity){
    String strDuration = Duration(seconds: activity.duration).toString().split('.').first;
    return strDuration;
  }

  String _formatDate(DateTime date){
    String strInitialDate = date.toString().split('.')[0];
    return strInitialDate;
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

  void _navigateSearchOptions() {
    _timer.cancel();
    Navigator.of(context)
        .push(MaterialPageRoute<void>(
      builder: (context) => SearchOptions(),
    )).then( (var value) {
      //_activateTimer();
      //_refresh();
    });
  }
}