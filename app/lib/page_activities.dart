import 'package:codelab_timetracker/page_intervals.dart';
//import 'package:codelab_timetracker/tree.dart';
import 'package:codelab_timetracker/tree.dart' hide getTree;
// the old getTree()
import 'package:codelab_timetracker/requests.dart';
// has the new getTree() that sends an http request to the server

import 'package:flutter/material.dart';
import 'dart:async';


class PageActivites extends StatefulWidget {
  int id;

  PageActivites(this.id);

  @override
  _PageActivitesState createState() => _PageActivitesState();
}

class _PageActivitesState extends State<PageActivites> {
  int id;
  Future<Tree> futureTree;

  Timer _timer;
  static const int periodeRefresh = 6;
  // better a multiple of periode in TimeTracker, 2 seconds

  @override
  void initState() {
    super.initState();
    id = widget.id; // of PageActivities
    futureTree = getTree(id);
    _activateTimer();
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
              title: Text(snapshot.data.root.name ?? 'TimeTracker default'),
              actions: <Widget>[
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
                //TODO other actions
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
    if (activity is Project) {
      return ListTile(
        title: Text('${activity.name}'),
        trailing: Text(_formatDuration(activity)),
        onTap: () => _navigateDownActivities(activity.id),
      );
    } else if (activity is Task) {
      Task task = activity as Task;
      // at the moment is the same, maybe changes in the future
      Widget trailing;
      trailing = Text(_formatDuration(activity));

      return ListTile(
        title: Text('${activity.name}'),
        trailing: trailing,
        onTap: () => _navigateDownIntervals(activity.id),
        onLongPress: () { print("Premuda tecla llarga");
          if ((activity as Task).active) {
            stop(activity.id);
            _refresh(); // to show immediately that task has started
          } else {
            start(activity.id);
            _refresh(); // to show immediately that task has stopped
          }
        },
      );
    }
  }

  String _formatDuration(dynamic activity){
    String strDuration = Duration(seconds: activity.duration).toString().split('.').first;
    return strDuration;
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
