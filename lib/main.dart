import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final List<String> _request_types = ["GET", "POST", "PUT", "DELETE"];
  final _urlcontroller = TextEditingController();
  final _postdatacontroller = TextEditingController();
  final Uri gh_uri = Uri.parse("https://github.com/malawarecreator/request_pengui.git");
  String output_text = "";
  
  String? _request_type = "GET";
  @override
  void dispose() {
    _urlcontroller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(length: 2, child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.web)),
              Tab(icon: Icon(Icons.settings),),
              
            ]
            
          ),
          
        ),
        body: TabBarView(children: [
          
          SingleChildScrollView(
            child: Column(children: [
              SizedBox(height: 40,),
              Text("HTTP Requests", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),),
              DropdownButton<String>(
              value: _request_type,   
              items: _request_types
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
            SizedBox(height: 40,),
            SizedBox(
              width: 300,
              child: TextField(
                controller: _urlcontroller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0)
                  ),
                  hintText: "Enter the URL for the Request",
                  filled: true,

                ),
              )
            ),
            SizedBox(height: 30,),
            SizedBox(
              width: 300,
              child: TextField(
                controller: _postdatacontroller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0)
                  ),
                  hintText: "Enter Optional Data for the Request",
                  filled: true,
                ),
              )
            ),

            SizedBox(height: 20,),

            ElevatedButton(onPressed: () async  {
             
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
                    output_text = res.statusCode == 200 ? res.body : "Error: ${res.statusCode}";
                  });
                } catch (e) {
                  setState(() {
                    output_text = "Error $e";
                  });
                }
              } 
              if (_request_type == "POST") {
                try {
                  final res = await http.post(uri, body: _postdatacontroller.text);
                  setState(() {
                    output_text = res.statusCode == 201 ? res.body : "Error: ${res.statusCode}";
                  });
                } catch (e) {
                  setState(() {
                    output_text = "Error $e";
                  });
                }
              }
              if (_request_type == "PUT") {
                try { 
                  final res = await http.put(uri, body: _postdatacontroller.text);
                  setState(()  {
                    output_text = res.statusCode == 201 ? res.body : "Error: ${res.statusCode}";
                  });

                } catch (e) {
                  setState(() {
                    output_text  = "Error $e";
                  });
                }
                if (_request_type == "DELETE") {
                  try {
                    final res = await http.delete(uri);
                    setState(() {
                      if (res.statusCode == 200 || res.statusCode == 204) {
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


            }, child: Text("Send Request")),
            Text(output_text, textAlign: TextAlign.center,)

            ],)
          ),
          Column(
            children: [
              SizedBox(height: 30,),
              Text("Settings", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),),
              SizedBox(height: 60,),
              ElevatedButton(onPressed: () async {
                await launchUrl(gh_uri);
              }, child: Text("Go to this App's GitHub", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),)
            ],
          ),
        ]),
      ))
    );
  }
}
