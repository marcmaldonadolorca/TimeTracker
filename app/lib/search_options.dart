
import 'package:codelab_timetracker/page_activities.dart';
import 'package:codelab_timetracker/search_recent_tasks.dart';
import 'package:codelab_timetracker/total_time.dart';
import 'package:codelab_timetracker/tree.dart' hide getTree;
// the old getTree()
import 'package:codelab_timetracker/requests.dart';
// has the new getTree() that sends an http request to the server
import 'package:codelab_timetracker/search_by_tag.dart';

import 'package:flutter/material.dart';


class SearchOptions extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
            title: Text('Search Options'),
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
      body: Center(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 80),
            RaisedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                    builder: (context) => SearchByTag(),),);
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.blue[500])),
              color: Colors.blue[500],
              textColor: Colors.white,
              padding: const EdgeInsets.all(10.0),
              child: Text("        By Tag        ",
                  style: TextStyle(fontSize: 20)),
            ),

            const SizedBox(height: 30),
            RaisedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchRecentTask(),),);
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.blue[500])),
              color: Colors.blue[500],
              textColor: Colors.white,
              padding: const EdgeInsets.all(10.0),
              child: Text("  Recent Tasks  ",
                  style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(height: 30),
            RaisedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TotalTime(),),);
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.blue[500])),
              color: Colors.blue[500],
              textColor: Colors.white,
              padding: const EdgeInsets.all(10.0),
              child: Text("    Total Time    ",
                  style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }

  //No cal amb statelessWidget
  void _navigateByTag(){

  }

  void _navigateRecent(){

  }

  void _navigateTotalTime(){

  }



}