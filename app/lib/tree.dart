// see Serializing JSON inside model classes in
// https://flutter.dev/docs/development/data-and-backend/json

import 'package:intl/intl.dart';
import 'dart:convert' as convert;

final DateFormat _dateFormatter = DateFormat("yyyy-MM-dd HH:mm:ss");

abstract class Activity {
  int id;
  String name;
  DateTime initialDate;
  DateTime finalDate;
  int duration;
  List<dynamic> children = List<dynamic>();
  List<String> tags = List<String>();
  bool active;
  String parentName;

  Activity.fromJson(Map<String, dynamic> json)
        :id = json['id'],
        name = json['name'],
        initialDate = json['initialDate']==null ? null : _dateFormatter.parse(json['initialDate']),
        finalDate = json['finalDate']==null ? null : _dateFormatter.parse(json['finalDate']),
        duration = json['duration'],
        active = json['active'],
        parentName = (json['parentName'] == "root") ? "TimeTracker": json['parentName'];
        // if (json['tags'].length()!=0){
        //   String tmp = "";
        //   for(String aux in json['tags']){
        //     tmp=tmp+","+aux;
        //   }
        //   tags.add(tmp);//de moment tot junt per imprimir a flutter details
        // }else tags.add("--");

}



class Project extends Activity {
  //bool activeChilds;
  Project.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    //activeChilds = json['activeChilds'];
    _setTags(this, json);
    if(json['name']=='root'){ name = 'TimeTracker';}
    if (json.containsKey('activities')) {
      // json has only 1 level because depth=1 or 0 in time_tracker
      for (Map<String, dynamic> jsonChild in json['activities']) {
        if (jsonChild['class'] == "project") {
          children.add(Project.fromJson(jsonChild));
          // condition on key avoids infinite recursion
        } else if (jsonChild['class'] == "task") {
          children.add(Task.fromJson(jsonChild));
        } else {
          assert(false);
        }
      }
    }
    if (json.containsKey('tags')) {
      for (String jsonTag in json['tags']) {
        tags.add(jsonTag);
      }
    };
  }
}


class Task extends Activity {
  //bool active;
  Task.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    //active = json['active'];
    _setTags(this, json);
    for (Map<String, dynamic> jsonChild in json['intervals']) {
      children.add(Interval.fromJson(jsonChild));
    }
    if (json.containsKey('tags')) {
      for (String jsonTag in json['tags']) {
        tags.add(jsonTag);
      }
    };
  }
}


class Interval {
  int id;
  DateTime initialDate;
  DateTime finalDate;
  int duration;
  bool active;
  int numOrder;

  Interval.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        initialDate = json['initialDate']==null ? null : _dateFormatter.parse(json['initialDate']),
        finalDate = json['finalDate']==null ? null : _dateFormatter.parse(json['finalDate']),
        duration = json['duration'],
        active = json['active'],
        numOrder = json['number'];

}

void _setTags(Activity activity, Map<String, dynamic> json){
  //if (!json['tags'].isEmpty()){
    String tmp = "";
    String char = "";
    for(String aux in json['tags']){
      tmp=tmp+char+aux;
      char = ",";
    }

    activity.tags.add(tmp);//de moment tot junt per imprimir a flutter details
  //}else activity.tags.add("--");
}



class Tree {
  Activity root;

  Tree(Map<String, dynamic> dec) {
    // 1 level tree, root and children only, root is either Project or Task. If Project
    // children are Project or Task, that is, Activity. If root is Task, children are Instance.
    if (dec['class'] == "project") {
      root = Project.fromJson(dec);
    } else if (dec['class'] == "task") {
      root = Task.fromJson(dec);
    } else {
      assert(false);
    }
  }
}

//
// Tree getTree() {
//   String strJson = "{"
//       "\"name\":\"root\", \"class\":\"project\", \"id\":0, \"initialDate\":\"2020-09-22 16:04:56\", \"finalDate\":\"2020-09-22 16:05:22\", \"duration\":26,"
//       "\"activities\": [ "
//       "{ \"name\":\"software design\", \"class\":\"project\", \"id\":1, \"initialDate\":\"2020-09-22 16:05:04\", \"finalDate\":\"2020-09-22 16:05:16\", \"duration\":16 },"
//       "{ \"name\":\"software testing\", \"class\":\"project\", \"id\":2, \"initialDate\": null, \"finalDate\":null, \"duration\":0 },"
//       "{ \"name\":\"databases\", \"class\":\"project\", \"id\":3,  \"finalDate\":null, \"initialDate\":null, \"duration\":0 },"
//       "{ \"name\":\"transportation\", \"class\":\"task\", \"id\":6, \"active\":false, \"initialDate\":\"2020-09-22 16:04:56\", \"finalDate\":\"2020-09-22 16:05:22\", \"duration\":10, \"intervals\":[] }"
//       "] "
//       "}";
//   Map<String, dynamic> decoded = convert.jsonDecode(strJson);
//   Tree tree = Tree(decoded);
//   return tree;
// }
//
// testLoadTree() {
//   Tree tree = getTree();
//   print("root name ${tree.root.name}, duration ${tree.root.duration}");
//   for (Activity act in tree.root.children) {
//     print("child name ${act.name}, duration ${act.duration}");
//   }
// }
//
// Tree getTreeTask() {
//   String strJson = "{"
//       "\"name\":\"transportation\",\"class\":\"task\", \"initialDate\":\"2020-09-22 13:36:08\", \"finalDate\":\"2020-09-22 13:36:34\", \"duration\":10,"
//       "\"intervals\":["
//       "{\"class\":\"interval\", \"initialDate\":\"2020-09-22 13:36:08\", \"finalDate\":\"2020-09-22 13:36:14\", \"duration\":6 },"
//       "{\"class\":\"interval\", \"initialDate\":\"2020-09-22 13:36:30\", \"finalDate\":\"2020-09-22 13:36:34\", \"duration\":4}"
//       "]}";
//   Map<String, dynamic> decoded = convert.jsonDecode(strJson);
//   Tree tree = Tree(decoded);
//   return tree;
// }


void main() {
  //testLoadTree();
}