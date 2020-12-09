import 'dart:async';

import 'package:codelab_timetracker/page_activities.dart';
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

  Widget _buildRow(Tree.Interval interval, int index) {
    //String strDuration = Duration(seconds: interval.duration).toString().split('.').first;
    //String strInitialDate = interval.initialDate.toString().split('.')[0];
    // this removes the microseconds part
    //String strFinalDate = interval.finalDate.toString().split('.')[0];
    if(!interval.active){
    return ListTile(
      title: Text('from ${_formatDate(interval.initialDate)} to ${_formatDate(interval.finalDate)}' ),
      trailing: Text(_formatDuration(interval)),
    );}else{
      return ListTile(
        title: Text('from ${_formatDate(interval.initialDate)} to ${_formatDate(interval.finalDate)}',
        style: TextStyle(color:Colors.indigo)),
        trailing: Text(_formatDuration(interval),style: TextStyle(color:Colors.indigo)),
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

}