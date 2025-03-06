
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path; 
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
void main() async  {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

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
  final _downloadurlcontroller = TextEditingController();

  ThemeData theme = ThemeData.light();
  WebSocketChannel? _channel;

  final Uri gh_uri = Uri.parse(
    "https://github.com/malawarecreator/request_pengui.git",
  );
  String output_text = "";
  String websocket_output_text = "";
  String download_output_text = "";
  bool switch_val = false;
  var db = FirebaseFirestore.instance;


  String? _request_type = "GET";
  @override
  void dispose() {
    _urlcontroller.dispose();
    _postdatacontroller.dispose();
    _websocketurlcontroller.dispose();
    _channel?.sink.close();
    _downloadurlcontroller.dispose();
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
      theme: theme,
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.public)),
                Tab(icon: Icon(Icons.settings)),
                Tab(icon: Icon(Icons.arrow_circle_right_outlined)),
                Tab(icon: Icon(Icons.folder)),
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

                          final RequestData =  {
                            "type": _request_type,
                            "output": output_text,

                          };
                          db.collection("request_data").doc().set(RequestData).onError((e, _) => print("error $e"));
    
                        }
                      },
                      child: Text("Send Request"),
                    ),
                    Text(output_text, style: GoogleFonts.sourceCodePro(),)
                  ],
                ),
              ),
              SingleChildScrollView(

              
              
                child: Column(

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
                    SizedBox(height: 30,),

                    Text("Dark Mode:", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),),
                    Switch(value: switch_val, onChanged: (bool val) {
                      setState(() {

                        switch_val = !switch_val;
                        if (switch_val == false) {
                          theme = ThemeData.light();
                        } else {
                          theme = ThemeData.dark();
                        }
                      });
                    })
                  ],
                ),
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
                    Text(websocket_output_text, textAlign: TextAlign.center, style: GoogleFonts.sourceCodePro(),),



                  ],
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 40,),
                    Text("Downloads Over HTTP", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),),
                    SizedBox(height: 30,),
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: _downloadurlcontroller,
                        decoration:  InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),

                          ),
                          hintText: "Enter the Download server URL",
                          filled: true

                        ),

                      ),
                      
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    
                    
                    ElevatedButton(onPressed: () async {
                      if (_downloadurlcontroller.text.isEmpty) {
                        setState(() {
                          download_output_text = "Missing URL Param";
                        });
                        return;
                      }
                      try {
                        final res = await http.get(Uri.parse(_downloadurlcontroller.text));

                        if (res.statusCode == 200) {
                          final dir = await getApplicationDocumentsDirectory();
                          final filename = path.basename(_downloadurlcontroller.text);
                          final fpath = "${dir.path}/$filename";
                          final file = File(fpath);          
                          await file.writeAsBytes(res.bodyBytes);
                          setState(() {
                            download_output_text = "Download successful at $fpath";
                          });              

                        } else {
                          setState(() {
                            download_output_text = "Download Failed: ${res.statusCode}";
                          });
                        } 
                      } catch (e) {
                        setState(() {
                          
                          download_output_text = "Error While Downloading: $e";
                        });
                      }

                      

                    }, child: Text("Get File")),
                    SizedBox(height: 20,),
                    Text(download_output_text, textAlign: TextAlign.center, style: GoogleFonts.sourceCodePro(),),
                    
                  ],

                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  
}
