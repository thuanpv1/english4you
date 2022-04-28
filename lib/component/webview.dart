import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

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
              icon: const Icon(Icons.home))
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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
