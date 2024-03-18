import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart'  ;


class MqttEventHandler{
  late MqttServerClient client;
  var  Password = "CONNECTION_PASSWORD";
  String broker = "YOUR_MQTT_SERVER_URL_SAME_AS_ARDUNIO_URL";
  String Username = "CONNECTION_USERNAME";
  int port = 8883;
  ConnectMqttClient()  {
    var devicepowerstats = "";
    client = MqttServerClient.withPort("YOUR_MQTT_SERVER_URL_SAME_AS_ARDUNIO_URL", "CLIENT_NAME",port);
    client.secure = true;
    client.securityContext = SecurityContext.defaultContext;

  Future<void> ConnectToClient() async {
      try {
        await client.connect(Username, Password);
        client.onConnected = onConnecdted();
        // devicepowerstats =  checkDeviceStatus(client);
        // print("Device Power Stats : $devicepowerstats");

      }
      catch (e) {
        if (kDebugMode) {
          print('FAILED to connect to Mqtt Client": $e');
        }
        client.disconnect();
        client.onDisconnected = onDisconnected();
      }}
    ConnectToClient();
    return client;
   }
  //OnConnected
  ConnectCallback? onConnecdted() {
    if (kDebugMode) {print("Successfully Connected To Mqtt Client");}
    client.subscribe("status_check", MqttQos.atMostOnce);
    /*client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage message = c![0].payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(message.payload.message);
      print('Received message:$payload');
    });

    return null;*/
  }


  //when it is disconnected
  ConnectCallback? onDisconnected() {
    if (kDebugMode) {print("Disconnected From Mqtt Client");}
    return null;
  }
  void turnOff(MqttServerClient client){
    MqttClientPayloadBuilder builder = MqttClientPayloadBuilder().addString("0");
    final onCode = builder.payload;
    client.publishMessage("Gardening_Machine_1", MqttQos.atMostOnce, onCode!);
    print("Sent MQTT Message :TURN Off");

  }
  void Updatetime(MqttServerClient client,String time){
    MqttClientPayloadBuilder builder = MqttClientPayloadBuilder().addString(time);
    final onCode = builder.payload;
    client.publishMessage("Gardening_Machine_1", MqttQos.atMostOnce, onCode!);
  }


  void turnOn(MqttServerClient client){
    MqttClientPayloadBuilder builder = MqttClientPayloadBuilder().addString("1");
    final onCode = builder.payload;
    client.publishMessage("Gardening_Machine_1", MqttQos.atMostOnce, onCode!);
    print("Sent MQTT Message :TURN ON");
  }
  void DisableAot_on(MqttServerClient client){
    MqttClientPayloadBuilder builder = MqttClientPayloadBuilder().addString("00");
    final onCode = builder.payload;
    client.publishMessage("Gardening_Machine_1", MqttQos.atMostOnce, onCode!);
  }
  void EnabledAot_on(MqttServerClient client){
    MqttClientPayloadBuilder builder = MqttClientPayloadBuilder().addString("11");
    final onCode = builder.payload;
    client.publishMessage("Gardening_Machine_1", MqttQos.atMostOnce, onCode!);


  }

    Future<String> checkDeviceStatus(MqttServerClient client)   {
    String  device_power_status = "";
    MqttClientPayloadBuilder builder = MqttClientPayloadBuilder().addString("??");
    final statscheckCode = builder.payload;
    client.publishMessage("status_check", MqttQos.atMostOnce, statscheckCode!);
    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) async {
      final MqttPublishMessage message = c![0].payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(message.payload.message);
      print("Payload $payload");
      if(payload.toString() == "Online"){
      device_power_status = "Active";}
      else{
        device_power_status = "Offline";
      }});

    Future<String> fetch_device_power_status() =>Future.delayed(const Duration(seconds: 4),() => device_power_status);
    return fetch_device_power_status();
  }








 Future<void> main() async {
   client = MqttServerClient.withPort("YOUR_SERVER_URI", "CLIENT_NAME",8883);
   client.secure = true;
   client.securityContext = SecurityContext.defaultContext;
   MqttClientPayloadBuilder builder = MqttClientPayloadBuilder().addString("This is a test Message");
   final i = builder.payload;
   void hi(){}


   try {
     await client.connect(Username, Password);
     print("Worked");
     client.publishMessage("test", MqttQos.atLeastOnce, i!);
   } catch (e) {
     print('Exception: $e');
     client.disconnect();
   }



 }



}
