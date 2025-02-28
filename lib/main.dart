import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {

  final List<String> _request_types = [
    "GET",
    "POST",
    "PUT",
    "DELETE",
    "TRACE",
    "OPTIONS",
  ];
  final _urlcontroller = TextEditingController();
  final _postdatacontroller = TextEditingController();
  final _websocketurlcontroller = TextEditingController();
  final _websocketmessagedatacontroller = TextEditingController();
  WebSocketChannel? _channel;

  final Uri gh_uri = Uri.parse(
    "https://github.com/malawarecreator/request_pengui.git",
  );
  String output_text = "";
  String websocket_output_text = "";

  String? _request_type = "GET";
  @override
  void dispose() {
    _urlcontroller.dispose();
    _postdatacontroller.dispose();
    _websocketurlcontroller.dispose();
    _channel?.sink.close();
    super.dispose();
  }
  void connectWebSocket() {
    if (_websocketurlcontroller.text.isEmpty || _websocketmessagedatacontroller.text.isEmpty) {
      setState(() {
        websocket_output_text = "Missing Params!";
      });
      return;
    }

    _channel = WebSocketChannel.connect(Uri.parse(_websocketurlcontroller.text));

    setState(() {
      websocket_output_text = "Connected to WebSocket!";
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.public)),
                Tab(icon: Icon(Icons.settings)),
                Tab(icon: Icon(Icons.arrow_circle_right_outlined)),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 40),
                    Text(
                      "HTTP Requests",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                    DropdownButton<String>(
                      value: _request_type,
                      items:
                          _request_types
                              .map<DropdownMenuItem<String>>(
                                (String type) => DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(type),
                                ),
                              )
                              .toList(),
                      onChanged: (String? type) {
                        setState(() {
                          _request_type = type;
                        });
                      },
                      hint: Text("Select Request Type"),
                    ),
                    SizedBox(height: 40),
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: _urlcontroller,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          hintText: "Enter the URL for the Request",
                          filled: true,
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: _postdatacontroller,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          hintText: "Enter Optional Data for the Request",
                          filled: true,
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () async {
                        if (_urlcontroller.text.isEmpty) {
                          setState(() {
                            output_text = "URL is Empty";
                          });
                          return;
                        }

                        var uri = Uri.parse(_urlcontroller.text);
                        if (_request_type == "GET") {
                          try {
                            final res = await http.get(uri);
                            setState(() {
                              output_text =
                                  res.statusCode == 200
                                      ? res.body
                                      : "Error: ${res.statusCode}";
                            });
                          } catch (e) {
                            setState(() {
                              output_text = "Error $e";
                            });
                          }
                        }
                        if (_request_type == "POST") {
                          try {
                            final res = await http.post(
                              uri,
                              body: _postdatacontroller.text,
                            );
                            setState(() {
                              output_text =
                                  res.statusCode == 201
                                      ? res.body
                                      : "Error: ${res.statusCode}";
                            });
                          } catch (e) {
                            setState(() {
                              output_text = "Error $e";
                            });
                          }
                        }
                        if (_request_type == "PUT") {
                          try {
                            final res = await http.put(
                              uri,
                              body: _postdatacontroller.text,
                            );
                            setState(() {
                              output_text =
                                  res.statusCode == 201
                                      ? res.body
                                      : "Error: ${res.statusCode}";
                            });
                          } catch (e) {
                            setState(() {
                              output_text = "Error $e";
                            });
                          }
                          if (_request_type == "DELETE") {
                            try {
                              final res = await http.delete(uri);
                              setState(() {
                                if (res.statusCode == 200 ||
                                    res.statusCode == 204) {
                                  output_text = res.body;
                                } else {
                                  output_text = "Error: ${res.statusCode}";
                                }
                              });
                            } catch (e) {
                              setState(() {
                                output_text = "Error $e";
                              });
                            }
                          }
                          if (_request_type == "OPTIONS") {
                            try {
                              final res = await http.get(
                                Uri.parse(
                                  "192.168.1.80:8080/api?command=OPTIONS&url=${_urlcontroller.text}",
                                ),
                              );
                              setState(() {
                                if (res.statusCode == 200) {
                                  output_text = res.body;
                                } else {
                                  output_text = "Error: ${res.statusCode}";
                                }
                              });
                            } catch (e) {
                              setState(() {
                                output_text = "Error $e";
                              });
                            }
                          }
                          if (_request_type == "TRACE") {
                            try {
                              final res = await http.get(
                                Uri.parse(
                                  "192.168.1.80:8080/api?command=TRACE&url=${_urlcontroller.text}",
                                ),
                              );
                              setState(() {
                                if (res.statusCode == 200) {
                                  output_text = res.body;
                                } else {
                                  output_text = "Error: ${res.statusCode}";
                                }
                              });
                            } catch (e) {
                              setState(() {
                                output_text = "Error $e";
                              });
                            }
                          }
                        }
                      },
                      child: Text("Send Request"),
                    ),
                    Text(output_text, textAlign: TextAlign.center),
                  ],
                ),
              ),
              Column(
                children: [
                  SizedBox(height: 40),
                  Text(
                    "Settings",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                  SizedBox(height: 60),
                  ElevatedButton(
                    onPressed: () async {
                      await launchUrl(gh_uri);
                    },
                    child: Text(
                      "Go to this App's GitHub",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 40),
                    Text(
                      "Websocket Requests",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                    SizedBox(height: 40),
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: _websocketurlcontroller,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          hintText: "Enter the Websocket URL",
                          filled: true,
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: _websocketmessagedatacontroller,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0)

                          ),
                          hintText: "Enter the Data to send",
                          filled: true
                          
                        ),
                      ),
                    ),
                    SizedBox(height: 30,),
                     ElevatedButton(
                      onPressed: () {
                        connectWebSocket();
                      },
                      child: Text(
                        "Connect to WebSocket",
                        
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_channel != null && _websocketmessagedatacontroller.text.isNotEmpty) {
                          _channel?.sink.add(_websocketmessagedatacontroller.text);
                        }
                      },
                      child: Text(
                        "Send Message",
                        
                      ),
                    ),
                    SizedBox(height: 20,),
                    StreamBuilder(
                      stream: _channel?.stream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text("Waiting for message...");
                        } else if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}");
                        } else if (snapshot.hasData) {
                          return Text("Received: ${snapshot.data}");
                        } else {
                          return Text("No data received.");
                        }
                      },
                    ),
                    SizedBox(height: 20),
                    Text(websocket_output_text),



                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  
}
