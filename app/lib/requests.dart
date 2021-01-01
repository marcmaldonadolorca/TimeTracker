import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'tree.dart';

final http.Client client = http.Client();
// better than http.get() if multiple requests to the same server

// If you connect the Android emulator to the webserver listening to localhost:8080
const String baseUrl = "http://10.0.2.2:8080";

// If instead you want to use a real phone, run this command in the linux terminal
//   ssh -R joans.serveousercontent.com:80:localhost:8080 serveo.net
//const String baseUrl = "https://joans.serveousercontent.com";

Future<Tree> getTree(int id) async {
  String uri = "$baseUrl/get_tree?$id";
  final response = await client.get(uri);
  // response is NOT a Future because of await but since getTree() is async,
  // execution continues (leaves this function) until response is available,
  // and then we come back here
  if (response.statusCode == 200) {
    print("statusCode=$response.statusCode");
    print(response.body);
    // If the server did return a 200 OK response, then parse the JSON.
    Map<String, dynamic> decoded = convert.jsonDecode(response.body);
    return Tree(decoded);
  } else {
    // If the server did not return a 200 OK response, then throw an exception.
    print("statusCode=$response.statusCode");
    throw Exception('Failed to get children');
  }
}

Future<void> start(int id) async {
  String uri = "$baseUrl/start?$id";
  final response = await client.get(uri);
  if (response.statusCode == 200) {
    print("statusCode=$response.statusCode");
  } else {
    print("statusCode=$response.statusCode");
    throw Exception('Failed to start task');
  }
}

Future<void> stop(int id) async {
  String uri = "$baseUrl/stop?$id";
  final response = await client.get(uri);
  if (response.statusCode == 200) {
    print("statusCode=$response.statusCode");
  } else {
    print("statusCode=$response.statusCode");
    throw Exception('Failed to stop task');
  }
}

//create("add" pel server switch case)
Future<void> add(int parentId, String parentName, String newName, String tagsByComas, bool isProject) async {
  String uri = "$baseUrl/add?$parentId&$newName&$tagsByComas&$isProject";
  final response = await client.get(uri);
  if (response.statusCode == 200) {
    print("statusCode=$response.statusCode");
  } else {
    print("statusCode=$response.statusCode");
    throw Exception('Failed to create activity');
  }
}

//searchByTag("searchTag" pel server...)
//Future list d'activities
Future<Tree> searchByTag(String tag) async {
  String uri = "$baseUrl/searchTag?$tag";
  final response = await client.get(uri);
  if (response.statusCode == 200) {
    print("statusCode=$response.statusCode");
    print(response.body);
    // If the server did return a 200 OK response, then parse the JSON.
    Map<String, dynamic> decoded = convert.jsonDecode(response.body);
    return Tree(decoded);
  } else {
    print("statusCode=$response.statusCode");
    throw Exception('Failed to create activity');
  }
}

//searchRecent("searchRecent"...)
//Future list d'activities
Future<Tree> searchRecentTasks() async {
  String uri = "$baseUrl/searchRecent?";
  final response = await client.get(uri);
  if (response.statusCode == 200) {
    print("statusCode=$response.statusCode");
    print(response.body);
    // If the server did return a 200 OK response, then parse the JSON.
    Map<String, dynamic> decoded = convert.jsonDecode(response.body);
    return Tree(decoded);
  } else {
    print("statusCode=$response.statusCode");
    throw Exception('Failed to create activity');
  }
}

//totalTime("searchTime" ...)

Future<Tuple> searchTotalTime(String activityName, DateTime startDateTime, DateTime finalDateTime, double priceHour ) async {
  String uri = "$baseUrl/searchTime?$activityName&$startDateTime&$finalDateTime&$priceHour";
  final response = await client.get(uri);
  if (response.statusCode == 200) {
    print("statusCode=$response.statusCode");
    print(response.body);
    // If the server did return a 200 OK response, then parse the JSON.
    String result;
    result = response.body.toString();//retorna time/price en forma string(fer split després)
    List<String> aux = result.split('/');
    Tuple calculs = new Tuple(0.0,0.0);
    calculs.setCost(aux[1]);
    calculs.setTimeSpent(aux[0]);//= double.parse(aux[0]);
    String s="";
    s=s+aux[0]+"/"+aux[1];
    // return s;
    return calculs;
  } else {
    print("statusCode=$response.statusCode");
    throw Exception('Failed to create activity');
  }
}