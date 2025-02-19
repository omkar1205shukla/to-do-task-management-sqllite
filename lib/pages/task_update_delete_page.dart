import "package:flutter/material.dart";
import 'package:intl/intl.dart';
import 'package:to_do_task_management_sqlite/pages/task_page.dart';
import 'package:to_do_task_management_sqlite/service/database_helper.dart';

class UpdateDelete extends StatefulWidget {
  final int id;
  final String date;
  final String priority;
  final String title;

  const UpdateDelete(this.id, this.title, this.date, this.priority,
      {super.key});
  @override
  _UpdateDeleteState createState() => _UpdateDeleteState();
}

class _UpdateDeleteState extends State<UpdateDelete> {
  final _formKey = GlobalKey<FormState>();
  String _title = "";
  DateTime dateTime = DateTime.now();
  List<String> priorities = ['Low', 'Medium', 'High'];
  late String _priority;
  late String _id;

  final TextEditingController _dateController = TextEditingController();
  final DateFormat _dateFormat = DateFormat("MMM dd,yyyy");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context)
            .unfocus(), //it is used to unfocus keyboard from the context
        child: SingleChildScrollView(
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 80.0, horizontal: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  child: Icon(Icons.arrow_back_ios_outlined,
                      color: Theme.of(context).primaryColor, size: 30.0),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 40.0),
                const Text(
                  "Update/Delete Task",
                  style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
                ),
                Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 30.0),
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Title',
                              labelStyle: const TextStyle(fontSize: 18.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),

                            // The validator receives the text that the user has entered.
                            validator: (value) {
                              if (value!.trim().isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                            onChanged: (value) => _title = value,
                            initialValue: _title,
                          ),
                        ),

                        //date

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: TextFormField(
                            readOnly: true, // to call only show date picker
                            controller: _dateController,
                            onTap: _handleDatePicker,
                            decoration: InputDecoration(
                              labelText: 'Date',
                              labelStyle: const TextStyle(fontSize: 18.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ),

                        //priority

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: DropdownButtonFormField(
                            iconSize: 20.0,
                            icon: const Icon(Icons.arrow_drop_down_circle),
                            iconEnabledColor: Theme.of(context).primaryColor,
                            items: priorities.map((String priority) {
                              return DropdownMenuItem(
                                value: priority,
                                child: Text(
                                  priority,
                                  style: const TextStyle(
                                      fontSize: 18.0, color: Colors.black),
                                ),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              labelText: 'Priority',
                              labelStyle: const TextStyle(fontSize: 18.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),

                            // The validator receives the text that the user has entered.
                            validator: (value) {
                              if (value == null) {
                                return 'Please select an option';
                              } else {
                                return null;
                              }
                            },
                            value: _priority,
                            onChanged: (value) {
                              setState(() {
                                _priority = value!;
                              });
                            },
                          ),
                        ),

                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 20.0),
                          height: 60.0,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: TextButton(
                            onPressed: _update,
                            child: const Text(
                              "Update",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 20.0),
                            ),
                          ),
                        ),

                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10.0),
                          height: 60.0,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: TextButton(
                            onPressed: _delete,
                            child: const Text(
                              "Delete",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 20.0),
                            ),
                          ),
                        ),
                      ],
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  //set sets to the fields

  DataInput() {
    _title = widget.title;
    _dateController.text = widget.date;
    _priority = widget.priority;
    _id = widget.id.toString();

    setState(() {});
  }

  @override
  void initState() {
    _dateController.text = _dateFormat.format(dateTime);
    super.initState();

    DataInput();
  }

  _delete() async {
    await DatabaseHelper.instance.deleteQuery(int.parse(_id));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const TaskPage(),
        ),
      );
    }
  }

  _handleDatePicker() async {
    final DateTime? date = await showDatePicker(
      context: context,
      firstDate: DateTime(2001),
      lastDate: DateTime(2050),
      initialDate: dateTime,
    );

    if (date != null && date != dateTime) {
      setState(() {
        dateTime = date;
      });

      _dateController.text = _dateFormat.format(date);
    }
  }

  _update() async {
    await DatabaseHelper.instance
        .updateQuery(int.parse(_id), _title, _dateController.text, _priority);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const TaskPage(),
      ),
    );
  }
}
