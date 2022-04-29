import 'dart:async';

import 'package:english4you/component/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:sqflite/sqflite.dart';

class MyWebViewWidget extends StatefulWidget {
  const MyWebViewWidget({Key? key}) : super(key: key);

  @override
  _MyWebViewWidgetState createState() => _MyWebViewWidgetState();
}

class _MyWebViewWidgetState extends State<MyWebViewWidget> {
  late WebViewController controller;
  late TextEditingController _controller;
  List<String> allWebSites = [
    'https://e.vnexpress.net',
    'https://techcrunch.com/',
    'https://www.techradar.com/',
    'https://www.wired.com/',
    'https://www.lifewire.com/',
    'https://www.tomshardware.com/',
    'https://lifehacker.com/'
  ];

  String cambridgeAPI =
      'https://dictionary.cambridge.org/dictionary/english-vietnamese/';
      List<MyNewWords> fetch = [];
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('English4You'),
        actions: [
          IconButton(
              onPressed: () async {
                DatabaseHelper helper = DatabaseHelper.instance;
                fetch = await helper.queryAll();
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return ListView(
                        children: [
                          ...fetch.map((item) => ListTile(
                            trailing: IconButton(
                                onPressed: () async {
                                  helper.deleteWord(item.title ?? 'nothing');
                                  var fetch1 = await helper.queryAll();
                                  setState(() {
                                    fetch = fetch1;
                                  });
                                },
                                icon: Icon(Icons.delete, color: Colors.red,)),
                            leading: const Icon(
                              Icons.web_asset,
                              color: Colors.green,
                            ),
                            title: Text(item.title ?? 'nothing'),
                            onTap: () {
                              controller.loadUrl(cambridgeAPI +
                                  (item.title ?? 'nothing'));
                              Navigator.pop(context);
                            },
                          )),
                        ],
                      );
                    });
              },
              icon: Icon(Icons.file_present)),
          IconButton(
              onPressed: () {
                controller.goBack();
              },
              icon: Icon(Icons.arrow_back)),
          IconButton(
              onPressed: () {
                controller.goForward();
              },
              icon: const Icon(Icons.arrow_forward)),
          IconButton(
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return ListView(
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: SizedBox(
                                  child: TextFormField(
                                    controller: _controller,
                                    decoration: const InputDecoration(
                                      border: UnderlineInputBorder(),
                                      labelText: 'Enter the web address',
                                    ),
                                  ),
                                  width: MediaQuery.of(context).size.width - 80,
                                ),
                              ),
                              IconButton(
                                  onPressed: () {
                                    controller.loadUrl(_controller.value.text);
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(Icons.arrow_forward)),
                            ],
                          ),
                          ...allWebSites.map((item) => ListTile(
                                leading: const Icon(
                                  Icons.web_asset,
                                  color: Colors.green,
                                ),
                                title: Text(item),
                                onTap: () {
                                  controller.loadUrl(item);
                                  Navigator.pop(context);
                                },
                              )),
                        ],
                      );
                    });
              },
              icon: const Icon(Icons.more_vert_outlined))
        ],
      ),
      body: WebView(
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: "https://e.vnexpress.net",
        onWebViewCreated: (controller) {
          this.controller = controller;
        },
        onPageStarted: (url) {
          print('==========================' + url);
          EasyLoading.show(status: 'Loading...');
        },
        onPageFinished: (url) {
          print('============onPageFinished==============' + url);
          EasyLoading.dismiss();
        },
        onProgress: (value) {
          if (value == 100) EasyLoading.dismiss();

          Timer(const Duration(seconds: 3), () {
            EasyLoading.dismiss();
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          ClipboardData? cdata = await Clipboard.getData(Clipboard.kTextPlain);
          if (cdata!.text != null) {
            print("data===${cdata.text}");

            if (cdata.text != null) {
              DatabaseHelper helper = DatabaseHelper.instance;
              MyNewWords word = MyNewWords();
              word.title = cdata.text;
              MyNewWords? fetch = await helper.search(cdata.text);
              if (fetch == null) {
                helper.insert(word);
                print('insert new words....');
              }
            }
            showModalBottomSheet(
                context: context,
                builder: (context) {
                  return ListView(
                    children: [
                      Container(
                        height: 6000,
                        child: WebView(
                          javascriptMode: JavascriptMode.unrestricted,
                          initialUrl: cambridgeAPI + (cdata.text ?? 'nothing'),
                          onWebViewCreated: (controller) {},
                          onPageStarted: (url) {
                            print('==========================' + url);
                            EasyLoading.show(status: 'Loading...');
                          },
                          onPageFinished: (url) {
                            print('============onPageFinished==============' +
                                url);
                            EasyLoading.dismiss();
                          },
                          onProgress: (value) {
                            if (value == 100) EasyLoading.dismiss();

                            Timer(const Duration(seconds: 3), () {
                              EasyLoading.dismiss();
                            });
                          },
                        ),
                      ),
                    ],
                  );
                });
          } else {
            print('Nothing copied...');
          }
        },
        tooltip: 'Increment',
        child: const Icon(Icons.book_online),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
