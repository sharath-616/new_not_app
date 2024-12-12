import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_not_app/Services/db_helper_class.dart';
import 'package:new_not_app/Utilities/custom_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final Function(bool) onThemeChanged;

  const HomePage({
    super.key,
    required this.onThemeChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ignore: unused_field
  bool _isDarkMode = false;

  Future<void> _loadTheemPreference() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = pref.getBool('isDarkMode') ?? false;
    });
  }

  void _togglerTheem(bool value) {
    setState(() {
      _isDarkMode = value;
      widget.onThemeChanged(_isDarkMode);
    });
  }

  List<Map<String, dynamic>> _allNotes = [];
  bool _isNotLoading = true;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notDescriptionController = TextEditingController();

  void _reloadNotes() async {
    final notes = await DbHelperClass.getAllNotes();
    setState(() {
      _allNotes = notes;
      _isNotLoading = false;
    });
  }
// add note method()

  Future<void> _addednotes() async {
    await DbHelperClass.createNote(_titleController.text, _notDescriptionController.text);
    _reloadNotes();
  }

  Future<void> _updatesNotes(int id) async {
    await DbHelperClass.updateNote(id, _titleController.text, _notDescriptionController.text);
    _reloadNotes();
  }

  void _deletedNote(int id) async {
    await DbHelperClass.deleteNote(id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const CustomText(
          text: 'Note hasbeen deleted..!',
          clr: Colors.white,
          fs: 15,
          fw: FontWeight.w500,
          fontFamily: 'AguDisplay',
          ls: 1,
        ),
        backgroundColor: _isDarkMode ? Colors.grey : Colors.purple,
      ),
    );
    _reloadNotes();
  }

  void _deleteAllnotes() async {
    final notCount = await DbHelperClass.totalNotesCount();
    if (notCount > 0) {
      await DbHelperClass.deleteAllnotes();
      _reloadNotes();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: CustomText(
          text: 'Successfully Deleted..!',
          clr: Colors.white,
          fs: 15,
          fw: FontWeight.w500,
          ls: 1,
        ),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: CustomText(
          text: 'No Notes Deleted..!',
          clr: Colors.white,
          fs: 15,
          fw: FontWeight.w500,
          ls: 1,
        ),
      ));
    }
  }

// The app lounching time the note will update  so..using inistate
  @override
  void initState() {
    super.initState();
    _reloadNotes();
    _loadTheemPreference();
  }

  void showBottomSheetContent(int? id) {
// to use a sigle button to updates and add....
    if (id != null) {
      final currentNote = _allNotes.firstWhere(
        (element) => element['id'] == id,
      );
      _titleController.text = currentNote['title'];
      _notDescriptionController.text = currentNote['description'];
    }

    showModalBottomSheet(
      elevation: 3,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 15,
          right: 15,
          top: 15,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(
                  height: 40,
                ),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Note Title:',
                    hintStyle: TextStyle(color: Colors.black, fontSize: 15),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _notDescriptionController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Note Description',
                    hintStyle: TextStyle(color: Colors.black, fontSize: 15),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: OutlinedButton(
                    onPressed: () async {
                      if (id == null) {
                        await _addednotes();
                      }
                      if (id != null) {
                        await _updatesNotes(id);
                      }

                      _titleController.text = "";
                      _notDescriptionController.text = "";
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      id == null ? "Add Note" : "Update Note",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 100,
        elevation: 3,
        // backgroundColor: Colors.orange[100],
        backgroundColor: Colors.white,
        title: const CustomText(
          text: 'Notes',
          clr: Colors.black,
          fs: 25,
          fw: FontWeight.bold,
          fontFamily: 'AguDisplay',
        ),
        actions: [
          IconButton(
              onPressed: () async {
                _deleteAllnotes();
              },
              icon: const Icon(
                Icons.delete_forever,
                size: 30,
                color: Colors.black,
              )),
          IconButton(
              onPressed: () async {
                _exitApp();
              },
              icon: const Icon(
                Icons.logout_outlined,
                size: 30,
                color: Colors.black,
              )),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: _isDarkMode,
              onChanged: (value) => _togglerTheem(value),
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: SafeArea(
          child: _isNotLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _allNotes.length,
                  itemBuilder: (context, index) => Card(
                    margin: const EdgeInsets.all(16),
                    // color: Colors.orange[100],
                    color: Colors.white,
                    elevation: 3,
                    child: ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Text(
                              _allNotes[index]['title'],
                              style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                            ), // to get only title
                          )),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    showBottomSheetContent(_allNotes[index]['id']);
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: Colors.black,
                                  )),
                              IconButton(
                                  onPressed: () {
                                    _deletedNote(_allNotes[index]['id']);
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    size: 20,
                                    color: Colors.black,
                                  ))
                            ],
                          )
                        ],
                      ),
                      subtitle: Text(
                        _allNotes[index]['description'],
                        style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showBottomSheetContent(null);
        },
        child: const Icon(
          Icons.add,
          size: 20,
          color: Colors.black,
        ),
      ),
    );
  }

  void _exitApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App..!'),
        content: const Text('Do you want to exit the app..?'),
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const CustomText(
              text: 'Cancel',
              clr: Colors.black,
              fs: 15,
            ),
          ),
          OutlinedButton(
              onPressed: () async {
                _exitApp();
                SystemNavigator.pop();
              },
              child: const CustomText(
                text: 'Exit',
                clr: Colors.black,
              ))
        ],
      ),
    );
  }
}
