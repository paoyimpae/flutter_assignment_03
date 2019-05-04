import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_assignment_03/ui_pages/create.dart';

int count = 0;
Firestore _db = Firestore.instance;

class Todo {
  int id;
  String title;
  int done;
  Todo();
}

Future getListForTodo() async {
  QuerySnapshot data = await _db.collection('todo').where('done', isEqualTo: 0).getDocuments();
  return data.documents;
}

Future getListForDone() async {
  QuerySnapshot data = await _db.collection('todo').where('done', isEqualTo: 1).getDocuments();
  return data.documents;
}

void setTodo(bool value, String documentId) async{
  return await _db.collection('todo').document(documentId).updateData({ 'done': value == true ? 1 : 0 });
}

void deleteCompleteAll() {
  _db.collection('todo').where('done', isEqualTo: 1).getDocuments().then((snapshot) {
  for (DocumentSnapshot ds in snapshot.documents){
    ds.reference.delete();
  }});
}

class TodoList extends StatefulWidget {
  TodoList();
  
  @override
  TodoListState createState() {
    return TodoListState();
  }
}

class TodoListState extends State<TodoList> {
  void initState() {
    super.initState();
    setState(() {
      const oneSecond = const Duration(seconds: 1);
      new Timer.periodic(oneSecond, (Timer t) => setState((){}));
    });
  }
  
      
  int page = 0;
  @override
  Widget build(BuildContext context) {
  List buttonList = 
  <Widget>[
    IconButton(
      icon: Icon(Icons.add),
      onPressed: () { 
        Navigator.push(context, MaterialPageRoute(builder: (context) => CreateList()));
        setState(() {
          context = context;
        });
      },
    ),
    IconButton(
      icon: Icon(Icons.delete),
      onPressed: () { 
        setState(() {
          deleteCompleteAll();
          context = context; 
        });
        page = 1;
      },
    ),
  ];
  List pageList = 
  <Widget>[
    FutureBuilder<dynamic>(
      future: getListForTodo(),
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          if(snapshot.data.length != 0) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(snapshot.data[index]['title']),
                  value: snapshot.data[index]['done'] == 1 ? true : false,
                  onChanged: (bool value) {
                    String docId;
                    _db.collection('todo').where('_id', isEqualTo: snapshot.data[index]['_id']).getDocuments().then((snapshot) {
                      for (DocumentSnapshot ds in snapshot.documents){
                        docId = ds.reference.documentID;
                        setTodo(value, docId);
                    }});
                    setState(() {
                      context = context;
                    });
                  },
                );
              },
            );
          }
          else {
            return Text('No data found..');
          }
        }
        else {
          return Text('No data found..');
        }
      }
      
    ),
    FutureBuilder<dynamic>(
      future: getListForDone(),
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          if(snapshot.data.length != 0) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(snapshot.data[index]['title']),
                  value: snapshot.data[index]['done'] == 1 ? true : false,
                  onChanged: (bool value) {
                    String docId;
                    _db.collection('todo').where('_id', isEqualTo: snapshot.data[index]['_id']).getDocuments().then((snapshot) {
                      for (DocumentSnapshot ds in snapshot.documents){
                        docId = ds.reference.documentID;
                        setTodo(value, docId);
                    }});
                    setState(() {
                      context = context;
                    });
                  },
                );
              },
            );
          }
          else {
            return Text('No data found..');
          }
        }
        else {
          return Text('No data found..');
        }
      }
    ),
  ];


  return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Todo"),
            actions: <Widget>[buttonList[page]],
            automaticallyImplyLeading: false,
          ),
          body: Center(
            child: pageList[page] 
          ),
          
          bottomNavigationBar: SizedBox(
            height: 58,
            child: TabBar(
              tabs: <Widget>[
              Tab(
                child: Column(
                  children: <Widget>[
                    Icon(Icons.list),
                    Text('Task'),
                  ],
                ),
              ),
              Tab(
                child: Column(
                  children: <Widget>[
                    Icon(Icons.done_all),
                    Text('Completed'),
                  ],
                ),  
              ),
              ],   
              labelColor: Colors.blue,
              indicatorColor: Colors.blue,
              onTap: (value) {
                setState(() {
                  page = value;
                  context = context;
                });
              },
            ),   
          ),
        ),
      ),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
