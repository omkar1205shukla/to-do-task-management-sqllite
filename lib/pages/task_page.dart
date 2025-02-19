import 'package:flutter/material.dart';
import 'package:to_do_task_management_sqlite/models/task_model.dart';
import 'package:to_do_task_management_sqlite/pages/add_task_page.dart';
import 'package:to_do_task_management_sqlite/pages/task_update_delete_page.dart';
import 'package:to_do_task_management_sqlite/service/database_helper.dart';

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
                  child: FutureBuilder<List<Task>>(
                    future: _getValue(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      } else {
                        List<Task> tasks = snapshot.requireData as List<Task>;
                        return SizedBox(
                          height: 400,
                          child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: tasks.length,
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
                                                      tasks[index].id,
                                                      snapshot
                                                          .data[index].title,
                                                      snapshot.data[index].date,
                                                      tasks[index].priority)),
                                        );
                                      },
                                      title: Text(tasks[index].title,
                                          style: TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                              decoration:
                                                  tasks[index].status == "0"
                                                      ? TextDecoration.none
                                                      : TextDecoration
                                                          .lineThrough)),
                                      subtitle: Text(
                                        "${tasks[index].date} • ${tasks[index].priority}",
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            decoration: snapshot
                                                        .data[index].status ==
                                                    "0"
                                                ? TextDecoration.none
                                                : TextDecoration.lineThrough),
                                      ),
                                      trailing: Checkbox(
                                        activeColor:
                                            Theme.of(context).primaryColor,
                                        value: tasks[index].status == "0"
                                            ? false
                                            : true,
                                        onChanged: (value) {
                                          if (value == true) {
                                            //tasks[index].status = "1";
                                            _updatecheckbox(
                                                tasks[index].id, "1");
                                          } else {
                                            _updatecheckbox(
                                                tasks[index].id, "0");
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
                builder: (context) => const AddTaskPage(),
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

  Future<List<Task>> _getValue() async {
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
