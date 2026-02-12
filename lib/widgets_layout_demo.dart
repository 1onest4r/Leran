import 'package:flutter/material.dart';

class WidgetsLayoutDemo extends StatelessWidget {
  const WidgetsLayoutDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Widgets and layout")),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Text("Hello"),
              Text("World"),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text("and MIU"),
              ),
              Icon(Icons.school),
              IconButton(onPressed: () {}, icon: Icon(Icons.mail_lock)),
              ElevatedButton(
                onPressed: () {},
                child: Text("Press to terminate"),
              ),
              SizedBox(height: 50),
              OutlinedButton(
                onPressed: () {
                  print("pressed these");
                },
                child: Text("waaat"),
              ),
              SizedBox(height: 50),
              OutlinedButton(
                onPressed: () {
                  print("pressed those");
                },
                child: Text("don't click me"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
