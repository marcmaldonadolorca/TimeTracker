import 'package:codelab_timetracker/page_activities.dart';
import 'package:codelab_timetracker/page_intervals.dart';
import 'package:codelab_timetracker/search_options.dart';
import 'package:codelab_timetracker/tree.dart' hide getTree;
import 'package:flutter/material.dart';
import 'package:codelab_timetracker/requests.dart';
// has the new getTree() that sends an http request to the server

import 'dart:async';

import 'package:date_time_picker/date_time_picker.dart';


class TotalTime extends StatefulWidget {


  //Cal el nom del pare pel TimeTracekr pugui posar a l'arbre
  TotalTime();

  @override
  _TotalTimeState createState() => _TotalTimeState();

}

class _TotalTimeState extends State<TotalTime> {
  String name;
  DateTime startDateTime;
  DateTime finalDateTime;
  double priceHour;
  Future<double> totalCost;
  Future<double> totalTime;
  bool wantsPrice = false;


  final myControllerName = new TextEditingController();//per guardar l' inpus name
  final myControllerPrice = new TextEditingController();//per guardar l' input preu hora
  var startTimeController = new TextEditingController();
  var finalTimeController = new TextEditingController();

  @override
  void initSate() {
    super.initState();
    startTimeController = TextEditingController(text: DateTime.now().toString());
    finalTimeController = TextEditingController(text: DateTime.now().toString());
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
            title: Text('TotalTime'),
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
                Text(  "Found the ammount of time worked in a given activity between two dates",
                  style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    TextField(
                      controller: myControllerName,
                      decoration: InputDecoration(
                        labelText: 'Activity name',
                        hintText: 'Enter existing name',
                        labelStyle: TextStyle(
                            fontSize: 22.0,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      cursorColor: Colors.blue[500],
                      // keyboardType: TextInputType.name,
                    ),
                    DateTimePicker(
                      controller: startTimeController,
                      type: DateTimePickerType.dateTimeSeparate,
                      dateMask: 'd MMM, yyyy',
                      //initialValue: DateTime.now().toString(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      icon: Icon(Icons.event),
                      dateLabelText: 'Start Date',
                      timeLabelText: "Hour",
                      selectableDayPredicate: (date) {
                        // Disable weekend days to select from the calendar
                        if (date.weekday == 6 || date.weekday == 7) {
                          return false;
                        }
                        return true;
                      },
                      onChanged: (val) => print(val),//this.startDateTime=DateTime.parse(val),
                      validator: (val) {
                        print(val);
                        return null;
                      },
                      onSaved: (val) => print(val),//this.startDateTime=DateTime.parse(val),
                    ),
                    DateTimePicker(
                      controller: finalTimeController,
                      type: DateTimePickerType.dateTimeSeparate,
                      dateMask: 'd MMM, yyyy',
                      //initialValue: DateTime.now().toString(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      icon: Icon(Icons.event),
                      dateLabelText: 'Final Date',
                      timeLabelText: "Hour",
                      selectableDayPredicate: (date) {
                        // Disable weekend days to select from the calendar
                        if (date.weekday == 6 || date.weekday == 7) {
                          return false;
                        }
                        return true;
                      },
                      onChanged: (val) => print(val), //this.finalDateTime=DateTime.parse(val),
                      validator: (val) {
                        print(val);
                        return null;
                      },
                      onSaved: (val) => print(val),//this.finalDateTime=DateTime.parse(val),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(50.0,0,50.0,0),
                      child: Column(
                        children: [
                          TextField(
                            keyboardType: TextInputType.number,
                            controller: myControllerPrice,
                            decoration: InputDecoration(
                              labelText: 'Price per hour (optional)',
                              hintText: 'value per hour',
                              labelStyle: TextStyle(
                                  fontSize: 22.0,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.normal
                              ),
                            ),
                            cursorColor: Colors.blue[500],
                        // keyboardType: TextInputType.name,
                          ),
                          Row(
                            children: [
                              Text("Calculate cost"),
                              Switch(
                                value: wantsPrice,
                                onChanged: (value) {
                                  setState(() {
                                    wantsPrice = value;
                                  });
                                },
                                activeTrackColor: Colors.lightBlueAccent,
                                activeColor: Colors.blue[500],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Radio(value: null, groupValue: null, onChanged: null),
                  ],
                ),


                SizedBox(height: 30),
                Center(
                  child: RaisedButton(
                    onPressed: () {
                      _getTimeValue();
                      setState(() {});
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
                SizedBox(height: 80),
                _getResult(),
              ],
            ),
          )
      ),
    );

    throw UnimplementedError();
  }

  void _getTimeValue() async {
    this.priceHour = 0.0;
    this.startDateTime=DateTime.parse(startTimeController.text);
    this.finalDateTime=DateTime.parse(finalTimeController.text);
    this.name = myControllerName.text;
    if(myControllerPrice.text!=null){
      this.priceHour = double.parse(myControllerPrice.text);
    }
    if(this.startDateTime != null && this.finalDateTime != null){
      Tuple result;
      result = searchTotalTime(this.name,this.startDateTime, this.finalDateTime, this.priceHour) as Tuple;
      setState(() {
        this.totalTime = result.timeSpent as Future<double>;
        this.totalCost = result.cost as Future<double>;
      });//fa que es torni a cridar build
    }
  }

  //Controla què s'ha de mostrar com a resultat: res o showTime
  Widget _getResult() {
    if (this.totalTime == null) {
      return Center();
    } else {
      return FutureBuilder<double>(
          future: this.totalTime,
          builder: (context, snapshot){
            if(snapshot.hasData){
              return Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                  _showTimeResult(false),
                  _showTimeResult(true),
                ],
                ),
              );
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
  //Mostra el missatege de resultat
  Widget _showTimeResult(bool cost){
    if(!cost){
      return Column(
        children: [
          SizedBox(height: 30),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: "Total amount of time:",
              style: TextStyle(
                  fontSize: 22.0,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold
              ),
              children: <TextSpan>[
                TextSpan(
                  text: this.totalTime.toString(),
                  style: TextStyle(fontSize: 18.0,
                      color: Colors.blue[500],
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ],
      );
    }else{
      return Column(
        children: [
          SizedBox(height: 30),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: "Total cost:",
              style: TextStyle(
                  fontSize: 22.0,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold
              ),
              children: <TextSpan>[
                TextSpan(
                  text: this.totalCost.toString(),
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

  }


  String _formatDuration(dynamic activity){
    String strDuration = Duration(seconds: activity.duration).toString().split('.').first;
    return strDuration;
  }

  String _formatDate(DateTime date){
    String strInitialDate = date.toString().split('.')[0];
    return strInitialDate;
  }

}