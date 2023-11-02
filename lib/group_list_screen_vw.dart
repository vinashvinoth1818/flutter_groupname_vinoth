import 'package:flutter/material.dart';
import 'package:flutter_group_name/group_list_model_vw.dart';
import 'database_helper_vw.dart';
import 'main.dart';

class GroupNameListScreen extends StatefulWidget {
  const GroupNameListScreen({super.key});

  @override
  State<GroupNameListScreen> createState() => _GroupNameListScreenState();
}

class _GroupNameListScreenState extends State<GroupNameListScreen> {
  var _groupNameController = TextEditingController();
  late List<GroupListModel> _groupNameList;

  @override
  void initState() {
    super.initState();
    getAllGroupName();
  }

  getAllGroupName() async {
    _groupNameList = <GroupListModel>[];

    var groupNameTableData =
    await dbHelper.queryAllRows(DatabaseHelper.groupNameTable);

    groupNameTableData.forEach((groupName) {
      setState(() {
        print(groupName['_id']);
        print(groupName['groupName']);

        var groupNameModel =
        GroupListModel(groupName['_id'], groupName['groupName']);

        _groupNameList.add(groupNameModel);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GroupName List'),
      ),
      body: ListView.builder(
          itemCount: _groupNameList.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
              child: Card(
                elevation: 8,
                child: ListTile(
                  leading: IconButton(
                    onPressed: () {
                      print('-----> Edit Record Id: $index');
                      _editgroupName(context, _groupNameList[index].id);
                    },
                    icon: Icon(
                      Icons.edit,
                      color: Colors.deepPurple,
                    ),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(_groupNameList[index].groupName),
                      IconButton(
                        onPressed: () {
                          _deleteFormDialog(context, _groupNameList[index].id);
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('-------> Add invoked');
          _showFormDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  _showFormDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (param) {
          return AlertDialog(
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _groupNameController.clear();
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  print('------> Frequency List---Save Clicked');
                  print('Frequency: ${_groupNameController.text}');
                  _save();
                },
                child: Text('Save'),
              ),
            ],
            title: Text('Frequency'),
            content: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: _groupNameController,
                    decoration: InputDecoration(hintText: 'Enter Frequency'),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _save() async {
    print('save ----> GroupName: $_groupNameController.text');

    Map<String, dynamic> row = {
      DatabaseHelper.colgroupName: _groupNameController.text,
    };

    final result =
    await dbHelper.insertData(row, DatabaseHelper.groupNameTable);

    debugPrint('----------> Inserted Row Id: $result');

    if (result > 0) {
      Navigator.pop(context);
      _showSuccessSnackBar(context, 'Saved');
      getAllGroupName();
    }
    _groupNameController.clear();
  }

  _editgroupName(BuildContext context, groupNameId) async {
    print(groupNameId);

    var row = await dbHelper.readDataById(DatabaseHelper.groupNameTable, groupNameId);

    setState(() {
      _groupNameController.text = row[0] ['groupName'] ?? 'No Data';
    });
    _editFormDialog(context, groupNameId);
  }

  _editFormDialog(BuildContext context, groupNameId) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (param) {
          return AlertDialog(
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  print('-------> Cancel invoked');
                  Navigator.pop(context);
                  _groupNameController.clear();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  print('------> Update invoked');
                  print('Frequency : ${_groupNameController.text}');
                  _update(groupNameId);
                },
                child: const Text('Update'),
              ),
            ],
            title: const Text('GroupName'),
            content: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: _groupNameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter GroupName',
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _update(int groupNameId) async {
    print('Update -----> Frequency: $_groupNameController.text');
    print('Update -----> Frequency Id: $groupNameId');

    Map<String, dynamic> row = {
      DatabaseHelper.colgroupName: _groupNameController.text,
      DatabaseHelper.colId: groupNameId,
    };
    final result =
    await dbHelper.updateData(row, DatabaseHelper.groupNameTable);

    debugPrint('--------> Updated Row Id: $result');

    if (result > 0) {
      Navigator.pop(context);
      _showSuccessSnackBar(context, 'Updated');
      getAllGroupName();
    }
    _groupNameController.clear();
  }

  _deleteFormDialog(BuildContext context, groupNameId) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (param) {
          return AlertDialog(
            actions: [
              ElevatedButton(onPressed: () {
                Navigator.pop(context);
              },
                child: Text('Cancel'),
              ),
              ElevatedButton(onPressed: () async {
                print('------> Delete Invoked');

                final result = await dbHelper.deleteData(groupNameId, DatabaseHelper.groupNameTable);

                debugPrint('Deleted Row Id: $result');

                if (result > 0) {
                  Navigator.pop(context);
                  _showSuccessSnackBar(context, 'Deleted');
                }

                setState(() {
                  _groupNameList.clear();
                  getAllGroupName();
                });
              },
                child: Text('Delete'),
              ),
            ],
            title: Text('Are you sure you want to delete this'),
          );
        }
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(new SnackBar(content: new Text(message)));
  }
}
