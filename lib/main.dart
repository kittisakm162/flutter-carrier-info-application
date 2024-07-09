import 'dart:io';

import 'package:carrier_info/carrier_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'CARRIER INFORMATION'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  IosCarrierData? _iosInfo;
  IosCarrierData? get iosInfo => _iosInfo;
  set iosInfo(IosCarrierData? iosInfo) {
    setState(() => _iosInfo = iosInfo);
  }

  AndroidCarrierData? _androidInfo;
  AndroidCarrierData? get androidInfo => _androidInfo;
  set androidInfo(AndroidCarrierData? carrierInfo) {
    setState(() => _androidInfo = carrierInfo);
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    await [
      Permission.locationWhenInUse,
      Permission.phone,
      Permission.sms,
    ].request();

    try {
      if (Platform.isAndroid) androidInfo = await CarrierInfo.getAndroidInfo();
      if (Platform.isIOS) iosInfo = await CarrierInfo.getIosInfo();
    } catch (e) {
      print(e.toString());
    }
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
        body: Platform.isIOS
            ? ListView(
                children: [
                  HomeItem(
                    title: 'supportsEmbeddedSIM',
                    value: '${iosInfo?.supportsEmbeddedSIM}',
                    isFirst: true,
                  ),
                  ...(iosInfo?.carrierRadioAccessTechnologyTypeList ?? []).map(
                    (it) => HomeItem(
                      title: '',
                      value: it,
                    ),
                  ),
                  ...(iosInfo?.carrierData ?? []).map(
                    (it) => Column(
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'SIM: ${it.carrierName}',
                          style: const TextStyle(
                            fontSize: 15,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...it.toMap().entries.map(
                              (e) => HomeItem(
                                title: e.key,
                                value: '${e.value}',
                              ),
                            )
                      ],
                    ),
                  ),
                ],
              )
            : ListView());
  }
}

class HomeItem extends StatelessWidget {
  const HomeItem(
      {super.key, required this.title, this.value, this.isFirst = false});

  final String title;
  final String? value;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        child: Column(children: <Widget>[
          if (!isFirst)
            Container(height: 0.5, color: Colors.grey.withOpacity(0.3)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title),
                const Spacer(),
                Flexible(
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    children: [
                      Text(value ?? ''),
                    ],
                  ),
                ),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
