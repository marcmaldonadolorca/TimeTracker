import 'package:codelab_timetracker/page_activities.dart';
import 'package:codelab_timetracker/tree.dart' hide getTree;
// the old getTree()
import 'package:codelab_timetracker/requests.dart';
// has the new getTree() that sends an http request to the server

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
          //mainAxisSize: MainAxisSize.min,

          children: <Widget>[
            const SizedBox(height: 80),
            RaisedButton(
              onPressed: () {},
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
              onPressed: () {},
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
              onPressed: () {},
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
}