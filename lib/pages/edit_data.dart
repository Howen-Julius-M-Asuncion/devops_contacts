import 'package:contacts/public/variables.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditData extends StatefulWidget {
  const EditData({super.key});

  @override
  State<EditData> createState() => _EditDataState();
}

class _EditDataState extends State<EditData> {
  // CONTROLLERS
  final TextEditingController _fname = TextEditingController();
  final TextEditingController _lname = TextEditingController();
  List<TextEditingController> phoneControllers = [];
  List<TextEditingController> emailControllers = [];
  List<TextEditingController> urlControllers = [];

  @override
  void initState() {
    super.initState();
    // Split the selected name into first and last names
    final nameParts = selectedName.trim().split(' ');
    _fname.text = nameParts.first;
    if (nameParts.length > 1) {
      _lname.text = nameParts.sublist(1).join(' ');
    }

    // Initialize phone controllers with existing data
    phoneControllers = selectedPhone.map((phone) => TextEditingController(text: phone)).toList();

    // Initialize email controllers with existing data
    emailControllers = selectedEmail.map((email) => TextEditingController(text: email)).toList();

    // Initialize url controllers with existing data
    urlControllers = selectedUrl.map((url) => TextEditingController(text: url)).toList();
  }

  @override
  void dispose() {
    _fname.dispose();
    _lname.dispose();
    for (var controller in phoneControllers) {
      controller.dispose();
    }
    for (var controller in emailControllers) {
      controller.dispose();
    }
    for (var controller in urlControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Function to add a new field
  void addField(List<TextEditingController> list) {
    setState(() {
      list.add(TextEditingController());
    });
  }

  // Function to remove a field
  void removeField(List<TextEditingController> list, int index) {
    setState(() {
      list[index].dispose();
      list.removeAt(index);
    });
  }

  // Function to save changes

  // Field section builder
  Widget buildFieldSection({
    required String label,
    required List<TextEditingController> controllers,
    required VoidCallback onAdd,
    required Function(int) onRemove,
    String placeholder = '',
    TextInputType? keyboardType,
  }) {
    return Column(
      children: [
        // Existing fields
        if (controllers.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: CupertinoColors.systemFill,
            ),
            child: Column(
              children: [
                for (int i = 0; i < controllers.length; i++)
                  Column(
                    children: [
                      Row(
                        children: [
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: Icon(
                              CupertinoIcons.minus_circle_fill,
                              color: CupertinoColors.systemRed,
                              size: 20,
                            ),
                            onPressed: () => onRemove(i),
                          ),
                          Expanded(
                            child: CupertinoTextField(
                              controller: controllers[i],
                              placeholder: placeholder,
                              keyboardType: keyboardType,
                              decoration: BoxDecoration(),
                            ),
                          ),
                        ],
                      ),
                      if (i < controllers.length - 1)
                        Divider(height: 0, indent: 0),
                    ],
                  ),
              ],
            ),
          ),

        // Add button
        SizedBox(height: 10),
        CupertinoButton(
          onPressed: onAdd,
          padding: EdgeInsets.zero,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: CupertinoColors.systemFill,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  CupertinoIcons.add_circled_solid,
                  color: CupertinoColors.systemGreen,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'add $label',
                  style: TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.systemBackground
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.secondarySystemBackground,
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Text('Cancel',),
          onPressed: () => Navigator.pop(context),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Text('Done',
            style: TextStyle(
            fontWeight: FontWeight.bold,
            )
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(height: 20),
                Container(
                  width: 200,
                  height: 200,
                  margin: EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(selectedPhoto),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                CupertinoButton(
                  child: Text('Add Photo'),
                  onPressed: () async {},
                ),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: CupertinoColors.systemFill,
                  ),
                  child: Column(
                    children: [
                      CupertinoTextField(
                        placeholder: 'First Name',
                        decoration: BoxDecoration(),
                        controller: _fname,
                      ),
                      Divider(height: 0),
                      CupertinoTextField(
                        controller: _lname,
                        placeholder: 'Last Name',
                        decoration: BoxDecoration(),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                buildFieldSection(
                  label: 'phone',
                  controllers: phoneControllers,
                  onAdd: () => addField(phoneControllers),
                  onRemove: (index) => removeField(phoneControllers, index),
                  placeholder: 'Phone number',
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 20),
                buildFieldSection(
                  label: 'email',
                  controllers: emailControllers,
                  onAdd: () => addField(emailControllers),
                  onRemove: (index) => removeField(emailControllers, index),
                  placeholder: 'Email address',
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 20),
                buildFieldSection(
                  label: 'url',
                  controllers: urlControllers,
                  onAdd: () => addField(urlControllers),
                  onRemove: (index) => removeField(urlControllers, index),
                  placeholder: 'Website URL',
                  keyboardType: TextInputType.url,
                ),
                SizedBox(height: 40),
                CupertinoButton(
                  onPressed: (){

                  },
                  padding: EdgeInsets.zero,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: CupertinoColors.systemFill,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 8),
                        Text(
                          'Delete Contact',
                          style: TextStyle(
                              fontSize: 16,
                              color: CupertinoColors.destructiveRed
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 40),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
