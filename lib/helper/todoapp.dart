import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todoapptest/helper/sql_helper.dart';

class TodoApp extends StatefulWidget {
  const TodoApp({Key? key}) : super(key: key);

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  //FormKey
  var _todoFormKey = GlobalKey<FormState>();

  // All journals
  List<Map<String, dynamic>> _journals = [];

  bool _isLoading = true;

  // This function is used to fetch all data from the database
  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals(); // Loading the diary when the app starts
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void _showForm(int? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingJournal =
          _journals.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['title'];
      _descriptionController.text = existingJournal['description'];
      _startDateController.text = existingJournal['startDate'];
      _endDateController.text = existingJournal['endDate'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                // this will prevent the soft keyboard from covering the text fields
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              child: Form(
                key: _todoFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(hintText: 'Title'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      keyboardType: TextInputType.multiline,
                      decoration:
                          const InputDecoration(hintText: 'Description'),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: _startDateController,
                      decoration: InputDecoration(
                          icon: Icon(Icons.calendar_today), //icon of text field
                          labelText: "Start Date"),
                      readOnly: true,
                      //set it true, so that user will not able to edit text
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            //DateTime.now() - not to allow to choose before today.
                            lastDate: DateTime(2101));
                        if (pickedDate != null) {
                          print(
                              pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                          String formattedDate =
                              DateFormat('yyyy-MM-dd').format(pickedDate);
                          print(
                              formattedDate); //formatted date output using intl package =>  2021-03-16
                          //you can implement different kind of Date Format here according to your requirement

                          setState(() {
                            _startDateController.text =
                                formattedDate; //set output date to TextField value.
                          });
                        } else {
                          print("Date is not selected");
                        }
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: _endDateController,
                      decoration: InputDecoration(
                          icon: Icon(Icons.calendar_today), //icon of text field
                          labelText: "End Date"),
                      readOnly: true,
                      //set it true, so that user will not able to edit text
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            //DateTime.now() - not to allow to choose before today.
                            lastDate: DateTime(2101));
                        if (pickedDate != null) {
                          print(
                              pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                          String formattedDate =
                              DateFormat('yyyy-MM-dd').format(pickedDate);
                          print(
                              formattedDate); //formatted date output using intl package =>  2021-03-16
                          //you can implement different kind of Date Format here according to your requirement

                          setState(() {
                            _endDateController.text =
                                formattedDate; //set output date to TextField value.
                          });
                        } else {
                          print("Date is not selected");
                        }
                      },
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          if (id == null) {

                            _addItem();
                          }
                        });

                        if (id != null) {
                          _updateItem(id);
                        }

                        // Clear the text fields
                        _titleController.text = '';
                        _descriptionController.text = '';
                        _startDateController.text = '';
                        _endDateController.text = '';

                        // Close the bottom sheet
                        Navigator.of(context).pop();
                      },
                      child: Text(id == null ? 'Create New' : 'Update'),
                    )
                  ],
                ),
              ),
            ));
  }

// Insert a new journal to the database
  Future<void> _addItem() async {
    await SQLHelper.createItem(
        _titleController.text.toUpperCase(),
        _descriptionController.text,
        _startDateController.text,
        _endDateController.text);
    _refreshJournals();
  }

  // Update an existing journal
  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(
        id,
        _titleController.text,
        _descriptionController.text,
        _startDateController.text,
        _endDateController.text);
    _refreshJournals();
  }

  // Delete an item
  void _deleteItem(int id) async {
    if (itemSelected == true) {
      await SQLHelper.deleteItem(id);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Successfully deleted'),
      ));
    }

    _refreshJournals();
  }

  bool itemSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo.com'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _journals.length,
              itemBuilder: (context, index) => Card(
                margin: const EdgeInsets.all(15),
                child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 300,
                    child: Card(
                      color: Colors.green[100],
                      child: ListTile(
                          title: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              _journals[index]['title'],
                              style: TextStyle(fontSize: 30),
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              _journals[index]['description'] +
                                  "\n" +
                                  _journals[index]['startDate'] +
                                  " " +
                                  _journals[index]['endDate'],
                              style: TextStyle(fontSize: 20),
                            ),
                          ),

                          //       Text(
                          //         _journals[index]['endDate'],
                          //         style: TextStyle(fontSize: 25),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // leading:  Text(
                          //   _journals[index]['title'],
                          //   style: TextStyle(fontSize: 30),
                          // ),

                          trailing: SizedBox(
                            width: 150,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () =>
                                      _showForm(_journals[index]['id']),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () =>
                                      _deleteItem(_journals[index]['id']),
                                ),
                                Checkbox(
                                  value: itemSelected,
                                  onChanged: (value) {
                                    setState(() {
                                      itemSelected = value!;
                                    });
                                  },
                                )
                              ],
                            ),
                          )),
                    )),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}
