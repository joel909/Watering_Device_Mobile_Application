import 'dart:async';
//import 'dart:ffi';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
//import 'package:waterit_beta/FirebaseReadData.dart';
//import 'package:waterit_beta/MqttEventHandler.dart';
import "MqttEventHandler.dart";
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,);
  runApp(const MaterialApp(
    title: 'Navigation Basics',

    home: MyApp(),
  ));
}


class MyApp extends StatefulWidget{
  const MyApp ({Key? Key}): super(key:Key);
  @override
  State<MyApp> createState() => _MyAppState();


}

class _MyAppState extends State<MyApp> {


  DatabaseReference machine_stats_reference = FirebaseDatabase.instance.ref("Gardening_Machine_1");
  DatabaseReference ref = FirebaseDatabase.instance.ref("Gardening_Machine_1/Aot_dur");
  String Aot_display_duration = "Loading...";
  String machine_stats = '              ';
  String machine_power_stats = "      ";
  late MqttServerClient client;
  int MqttEventRunningStats = 1;
  double turns = 0.0;
  double Aot_duration = 0;
  String Auto_On_Time = "Loading..";
  String Aot_on_Status ="";
  MaterialStateProperty<Color> onbuttoncolor = MaterialStateProperty.all(Colors.white);
  MaterialStateProperty<Color> offbuttoncolor =  MaterialStateProperty.all(Colors.white38);
  MaterialStateProperty<Color> Enabledbuttoncolor =  MaterialStateProperty.all(Colors.white38);
  MaterialStateProperty<Color> Disabledbuttoncolor =  MaterialStateProperty.all(Colors.white);





  @override
  void initState()  {
    super.initState();


    client = MqttEventHandler().ConnectMqttClient();
    print("Gardening Machine Power : $machine_power_stats");





    Stream<DatabaseEvent> stream = machine_stats_reference.onValue;
    stream.listen((DatabaseEvent event) {
      String machine_stats_event_snapshot_value = event.snapshot.child("Status").value.toString();
      Aot_duration = double.parse(event.snapshot.child("Aot_dur").value.toString());
      Aot_on_Status = event.snapshot.child("Auto_On_Stats").value.toString();
      if(Aot_on_Status=="Enabled"){
        Enabledbuttoncolor =  MaterialStateProperty.all(Colors.white38);
        Disabledbuttoncolor =  MaterialStateProperty.all(Colors.white);
      }else{
        Disabledbuttoncolor =  MaterialStateProperty.all(Colors.white38);
        Enabledbuttoncolor =  MaterialStateProperty.all(Colors.white);

      }
      Auto_On_Time = event.snapshot.child("Time").value.toString();
      Auto_On_Time = Auto_On_Time.replaceAll("/", ":");
      print("Stream shit ${Aot_duration}");
      // if()
      if(machine_stats_event_snapshot_value=="Off"){machine_stats = "Pump is Idle";onbuttoncolor=MaterialStateProperty.all(Colors.white);offbuttoncolor=MaterialStateProperty.all(Colors.white38);}
      else{machine_stats="Pump is  On";onbuttoncolor = MaterialStateProperty.all(Colors.white38);offbuttoncolor =  MaterialStateProperty.all(Colors.white);}
      print("MAchine Power Stats $machine_power_stats");
      if(machine_power_stats == "      "){
        Future.delayed(const Duration(seconds: 3), ()  { if (client.connectionStatus!.state ==  MqttConnectionState.connected){MqttEventHandler().checkDeviceStatus(client).then((value){setState((){machine_power_stats = value;machine_stats;MqttEventRunningStats=0;});
        });}
        else{Fluttertoast.showToast(msg: "An Error Occured please check network : Took too much time to connect to client",toastLength: Toast.LENGTH_LONG);}
        });}
      else{
        setState(() {machine_stats;machine_power_stats;}); }
    });


  }

  Widget build(BuildContext context){
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double statusbarheightratio = screenHeight/15;
    double statusbarwidthtratio = screenWidth/1.06857142857;
    double Aot_Controlbox_widthratio = screenWidth/7.85454545455;
    double Aot_Controlbox_Heightratio = screenHeight/3.64312896406;


    print(screenHeight);
    if(MqttEventRunningStats ==1 ){
      hello();
    }
    if(Aot_duration >=1){
      Aot_display_duration="${Aot_duration.round().toString()} Minute";
    }
    //hello();
    print(screenWidth);
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xFFe0e0e0),),
      home: Scaffold(
          body: Stack(
            children: [
              Positioned(top:screenHeight/23.2742109154,left:screenWidth/37.4837291585,child: Card(  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0),),color: Colors.white,child: SizedBox(height:statusbarheightratio,width:statusbarwidthtratio,child:Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max, children: <Widget>[Text("Watering Device 1",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold)),Padding(padding: EdgeInsets.only(top: statusbarheightratio/25.1048951049,bottom: statusbarheightratio/5)),Row(mainAxisAlignment: MainAxisAlignment.start,mainAxisSize: MainAxisSize.max,children: [Padding(padding: EdgeInsets.only(right: statusbarwidthtratio/5.35481845121)),Text(machine_power_stats,style: TextStyle(color: Colors.lightGreen,fontWeight: FontWeight.bold),),Icon(Icons.radio_button_checked,color: Colors.green,size: 15,),Padding(padding: EdgeInsets.only(right: statusbarwidthtratio/6.24728819308)),Text(machine_stats.toString(),style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold)),Icon(Icons.spa,size: 15,),Padding(padding: EdgeInsets.only(right: statusbarwidthtratio/6.9))])]
              ),)),),
              Positioned(top: screenHeight/14.5418719212,right: 10, child: AnimatedRotation(turns: turns,duration: Duration(milliseconds: 7700),
                child :IconButton(onPressed:(){
                  if(MqttEventRunningStats == 0){
                    setState(() {machine_power_stats="      ";turns+=3;MqttEventRunningStats=1;});}}, icon: Icon(Icons.autorenew,size: 30)),)),
              Positioned(top: 150,right: 43,left: 43,child:SizedBox( height: screenHeight/15.6654545455,width: screenWidth/1.30909090909,child: TextButton(onPressed: () {if(MqttEventRunningStats==0){MqttEventHandler().turnOn(client);}},style: ButtonStyle(shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),backgroundColor: onbuttoncolor), child: const Text('Turn On')))),
              Positioned(top: 225,right: 43,left: 43,child:SizedBox( height: screenHeight/15.6654545455,width: screenWidth/1.30909090909,child: TextButton(onPressed: () {if(MqttEventRunningStats==0){MqttEventHandler().turnOff(client);}},style: ButtonStyle(shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),backgroundColor: offbuttoncolor,), child: const Text('Turn Off')))),
              Positioned(top:305+statusbarheightratio.toDouble(),left:screenWidth/37.4837291585 ,right: 43,child: Text("Automatic Turn Off Duration",style:  TextStyle(color: Colors.blue,fontWeight: FontWeight.bold,fontSize: 12))),
              Positioned(top: 320,left:screenWidth/37.4837291585,child:SizedBox(height: statusbarheightratio,width: statusbarwidthtratio,child: Slider(value: Aot_duration, onChanged: (double value1){
                if(MqttEventRunningStats==0&&value1.round()+1!= 10){
                  machine_stats_reference.update({"Aot_dur":(value1.round()+1)});
                }},min: 0,max: 9,divisions: 8,label: Aot_duration.round().toString(),activeColor: Colors.deepPurple,))),
              Positioned(top:315,right:screenWidth/18.6363636364 ,child: Text("Duration : ${Aot_display_duration}",style: TextStyle(color: Colors.blue),),),
              Positioned(top: 460,left:10,right:10,child: Card(shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),color: Colors.white70 ,child: SizedBox(height: Aot_Controlbox_Heightratio,width: Aot_Controlbox_widthratio,child: Stack(
                children:[
                  Positioned(top:10,left:35,right:screenWidth/6.54545454545,child: const Text("Automatic   Watering   Settings",style: TextStyle(fontSize: 18,color: Colors.green,fontWeight: FontWeight.bold),)),
                  Positioned(top:60,right: 10 ,child: SizedBox(height: screenHeight/15.6654545455,width: screenWidth/3,child: TextButton(onPressed: () { if(MqttEventRunningStats==0){MqttEventHandler().EnabledAot_on(client);} },style: ButtonStyle(shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),backgroundColor: Enabledbuttoncolor,), child: const Text("Enable",style:TextStyle(color: Colors.blue) ,),),)),
                  const Positioned(top: 60,left: 10,child: Text("Automatic Turn On Time",style: TextStyle(color: Colors.blue,fontSize: 17,fontWeight: FontWeight.bold),)),
                  Positioned(top:100 ,left: 85,child: Text(Auto_On_Time,style: TextStyle(color: Colors.blue,fontSize: 25),)),
                  Positioned(top:140,right: 10 ,child: SizedBox(height: screenHeight/15.6654545455,width: screenWidth/3,child: TextButton(onPressed: () {if(MqttEventRunningStats==0){MqttEventHandler().DisableAot_on(client);}},style: ButtonStyle(shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),backgroundColor: Disabledbuttoncolor,),child: Text("Disable",style: TextStyle(color: Colors.blue),))),),
                  Positioned(top:150,left: 50 ,child: SizedBox(height: screenHeight/20,width: screenWidth/3,child: TextButton(onPressed: () async{
                    if(MqttEventRunningStats==0){
                      final TimeOfDay? Updated_Aot_time = await showTimePicker(context: context, initialTime: Convert_toTimeOf_day(Auto_On_Time, ":"),initialEntryMode: TimePickerEntryMode.dialOnly);
                      print("${Updated_Aot_time?.hour}/${Updated_Aot_time?.minute}");
                      MqttEventHandler().Updatetime(client,"${Updated_Aot_time?.hour}/${Updated_Aot_time?.minute}");
                    }},
                      style: ButtonStyle(shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),backgroundColor: MaterialStateProperty.all(Colors.white)),child: Text("Set Time",style: TextStyle(color: Colors.blue),))),),

                ],
              )),))

            ],
          )

      ),

    );
  }
  TimeOfDay Convert_toTimeOf_day(String Time,String Splitchar){
    List<String> parts = Time.split(Splitchar);
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
// Normalize the time values
    while (minute >= 60) {hour += 1;minute -= 60;}
    while (hour >= 24) {hour -= 24;}
    TimeOfDay Converted_Time = TimeOfDay(hour: hour, minute: minute);
    return Converted_Time;

  }
  void hello(){
    if(machine_power_stats != "      "){setState(() {MqttEventRunningStats=0;});}
    else{
      if(client.connectionStatus!.state == MqttConnectionState.disconnected){
        client = MqttEventHandler().ConnectMqttClient();}
      Future.delayed(const Duration(seconds: 3), ()  { if (client.connectionStatus!.state ==  MqttConnectionState.connected){MqttEventHandler().checkDeviceStatus(client).then((value){
        if(value == "Active" || value == "Offline"){
          setState((){machine_power_stats = value;machine_stats
          ;MqttEventRunningStats=0;});}
        else{
          Fluttertoast.showToast(msg: "An Error Occurred Please Reload the Application and check network connection",toastLength: Toast.LENGTH_LONG);
          setState(() {
            MqttEventRunningStats=0;machine_power_stats="Error";
          });
        }
      });}
      else{}
      });

    }
  }
}







