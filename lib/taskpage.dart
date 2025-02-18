import 'package:flutter/material.dart';
import 'package:to_do_task_management_sqlite/Database/database_helper.dart';
import 'package:to_do_task_management_sqlite/addTask.dart';
import 'package:to_do_task_management_sqlite/updateDelete.dart';

class Task {
  final int _id;
  final String _title;
  final String _date;
  final String _priority;
  final String _status;

  Task(this._id, this._title, this._date, this._priority, this._status);
}

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  String total = "0";
  String taskComplete = "0";
  int counter = 0;

  List<Map<String, dynamic>>? alltask;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "My Tasks",
                  style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 40),
                child: Text(
                  "$taskComplete of $total",
                  style: const TextStyle(
                      color: Colors.black45,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0),
                ),
              ),

              // List Builder will come here

              Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 25.0),
                  child: FutureBuilder(
                    future: _getValue(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.data == null) {
                        return const CircularProgressIndicator();
                      } else {
                        return SizedBox(
                          height: 400,
                          child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    ListTile(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  UpdateDelete(
                                                      snapshot.data[index]._id,
                                                      snapshot
                                                          .data[index]._title,
                                                      snapshot
                                                          .data[index]._date,
                                                      snapshot.data[index]
                                                          ._priority)),
                                        );
                                      },
                                      title: Text(snapshot.data[index]._title,
                                          style: TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                              decoration: snapshot.data[index]
                                                          ._status ==
                                                      "0"
                                                  ? TextDecoration.none
                                                  : TextDecoration
                                                      .lineThrough)),
                                      subtitle: Text(
                                        "${snapshot.data[index]._date} • ${snapshot.data[index]._priority}",
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            decoration: snapshot
                                                        .data[index]._status ==
                                                    "0"
                                                ? TextDecoration.none
                                                : TextDecoration.lineThrough),
                                      ),
                                      trailing: Checkbox(
                                        activeColor:
                                            Theme.of(context).primaryColor,
                                        value:
                                            snapshot.data[index]._status == "0"
                                                ? false
                                                : true,
                                        onChanged: (value) {
                                          if (value == true) {
                                            //snapshot.data[index]._status = "1";
                                            _updatecheckbox(
                                                snapshot.data[index]._id, "1");
                                          } else {
                                            _updatecheckbox(
                                                snapshot.data[index]._id, "0");
                                          }
                                        },
                                      ),
                                    ),
                                    const Divider(
                                      height: 25.0,
                                      thickness: 1.0,
                                    )
                                  ],
                                );
                              }),
                        );
                      }
                    },
                  ))

              //here end
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AddTask(),
              ),
            );
          },
        ));
  }

  @override
  void initState() {
    totalTask();
    super.initState();
  }

  totalTask() async {
    alltask = await DatabaseHelper.instance.queryAll();

    total = alltask!.length.toString();
    //total length tasks

    for (var element in alltask!) {
      if (element["_status"] == "1" && counter <= alltask!.length) {
        counter++;
        print("Increment $counter");
      }
    }
    taskComplete = counter.toString();
    setState(() {});
  }

  Future<List> _getValue() async {
    List<Task> data = [];
    for (var element in alltask ?? []) {
      Task task = Task(element["_id"], element["_title"], element["_date"],
          element["_priority"], element["_status"]);
      data.add(task);
    }

    return data;
  }

  _updatecheckbox(int value, String index) async {
    await DatabaseHelper.instance.update(value, index);

    alltask = await DatabaseHelper.instance.queryAll();

    total = alltask!.length.toString();

    if (index == "1") {
      counter++;
      taskComplete = counter.toString();
    } else {
      counter--;
      taskComplete = counter.toString();
    }

    setState(() {});
  }
}
