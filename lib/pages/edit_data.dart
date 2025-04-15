import 'dart:io';
import 'package:contacts/public/variables.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditData extends StatefulWidget {
  const EditData({super.key});

  @override
  State<EditData> createState() => _EditDataState();
}

class _EditDataState extends State<EditData> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _fname = TextEditingController();
  final TextEditingController _lname = TextEditingController();
  List<TextEditingController> phoneControllers = [];
  List<TextEditingController> emailControllers = [];
  List<TextEditingController> urlControllers = [];
  String? _newImagePath;
  bool _newImageIsLocal = false;

  @override
  void initState() {
    super.initState();
    print('Initializing EditData for contact: $selectedName');
    final nameParts = selectedName.trim().split(' ');
    _fname.text = nameParts.first;
    if (nameParts.length > 1) {
      _lname.text = nameParts.sublist(1).join(' ');
    }

    phoneControllers = selectedPhone.map((phone) {
      print('Adding phone controller for: $phone');
      return TextEditingController(text: phone);
    }).toList();

    emailControllers = selectedEmail.map((email) {
      print('Adding email controller for: $email');
      return TextEditingController(text: email);
    }).toList();

    urlControllers = selectedUrl.map((url) {
      print('Adding url controller for: $url');
      return TextEditingController(text: url);
    }).toList();
  }

  @override
  void dispose() {
    print('Disposing EditData controllers');
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

  String _getInitials(String name) {
    print('Generating initials for: $name');
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0].toUpperCase()}${parts.last[0].toUpperCase()}';
  }

  Future<void> _pickImage() async {
    print('Attempting to pick image');
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        print('Image selected: ${pickedFile.path}');
        setState(() {
          _newImagePath = pickedFile.path;
          _newImageIsLocal = true;
        });
      }
    } catch (e) {
      print('Image pick error: $e');
    }
  }

  Widget _buildAvatar() {
    final photo = _newImagePath ?? selectedPhoto;
    final isLocal = _newImagePath != null ? true : selectedIsLocal;
    print('Building avatar with photo: $photo (isLocal: $isLocal)');

    if (photo.isEmpty) {
      return Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: CupertinoColors.systemGrey,
        ),
        child: Center(
          child: Text(
            _getInitials("${_fname.text} ${_lname.text}"),
            style: TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.systemBackground,
            ),
          ),
        ),
      );
    }

    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: isLocal
              ? FileImage(File(photo))
              : NetworkImage(photo) as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  void _saveChanges() {
    print('Attempting to save changes');
    if (_fname.text.trim().isEmpty) {
      print('Validation failed - missing name');
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text("Missing Information"),
          content: const Text("Please enter at least a first name"),
          actions: [
            CupertinoDialogAction(
              child: const Text("OK"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      );
      return;
    }

    final updatedContact = {
      "name": "${_fname.text.trim()} ${_lname.text.trim()}",
      "phone": phoneControllers.map((c) => c.text.trim()).where((p) => p.isNotEmpty).toList(),
      "email": emailControllers.map((c) => c.text.trim()).where((e) => e.isNotEmpty).toList(),
      "url": urlControllers.map((c) => c.text.trim()).where((u) => u.isNotEmpty).toList(),
      "photo": _newImagePath ?? selectedPhoto,
      "isLocal": _newImagePath != null ? true : selectedIsLocal,
    };

    print('Showing save confirmation dialog');
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Save Changes?"),
        content: const Text("Are you sure you want to update this contact?"),
        actions: [
          CupertinoDialogAction(
            child: const Text("Cancel"),
            onPressed: () {
              print('Save cancelled by user');
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            child: const Text("Save"),
            onPressed: () {
              print('User confirmed save');
              Navigator.pop(context, updatedContact);
            },
          ),
        ],
      ),
    ).then((value) {
      if (value != null) {
        print('Saving changes and returning updated contact');
        Navigator.pop(context, value);
      }
    });
  }

  void _deleteContact() {
    print('Showing delete confirmation dialog');
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Delete Contact"),
        content: const Text("Are you sure you want to delete this contact?"),
        actions: [
          CupertinoDialogAction(
            child: const Text("Cancel"),
            onPressed: () {
              print('Delete cancelled by user');
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            child: const Text("Delete", style: TextStyle(color: CupertinoColors.destructiveRed)),
            onPressed: () {
              print('User confirmed delete');
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
          ),
        ],
      ),
    );
  }

  // [Keep all other existing methods like _buildFieldSection, etc.]

  @override
  Widget build(BuildContext context) {
    print('Building EditData screen');
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.secondarySystemBackground,
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Cancel'),
          onPressed: () {
            print('Edit cancelled by user');
            Navigator.pop(context);
          },
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: _saveChanges,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildAvatar(),
                CupertinoButton(
                  child: Text(_newImagePath != null ? 'Change Photo' :
                  selectedPhoto.isEmpty ? 'Add Photo' : 'Change Photo'),
                  onPressed: _pickImage,
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: CupertinoColors.systemFill,
                  ),
                  child: Column(
                    children: [
                      CupertinoTextField(
                        placeholder: 'First Name',
                        decoration: const BoxDecoration(),
                        controller: _fname,
                      ),
                      const Divider(height: 0),
                      CupertinoTextField(
                        controller: _lname,
                        placeholder: 'Last Name',
                        decoration: const BoxDecoration(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildFieldSection(
                  label: 'phone',
                  controllers: phoneControllers,
                  onAdd: () => setState(() => phoneControllers.add(TextEditingController())),
                  onRemove: (index) => setState(() {
                    phoneControllers[index].dispose();
                    phoneControllers.removeAt(index);
                  }),
                  placeholder: 'Phone number',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                _buildFieldSection(
                  label: 'email',
                  controllers: emailControllers,
                  onAdd: () => setState(() => emailControllers.add(TextEditingController())),
                  onRemove: (index) => setState(() {
                    emailControllers[index].dispose();
                    emailControllers.removeAt(index);
                  }),
                  placeholder: 'Email address',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                _buildFieldSection(
                  label: 'url',
                  controllers: urlControllers,
                  onAdd: () => setState(() => urlControllers.add(TextEditingController())),
                  onRemove: (index) => setState(() {
                    urlControllers[index].dispose();
                    urlControllers.removeAt(index);
                  }),
                  placeholder: 'Website URL',
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 40),
                CupertinoButton(
                  onPressed: _deleteContact,
                  padding: EdgeInsets.zero,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: CupertinoColors.systemFill,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 8),
                        Text(
                          'Delete Contact',
                          style: TextStyle(
                            fontSize: 16,
                            color: CupertinoColors.destructiveRed,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldSection({
    required String label,
    required List<TextEditingController> controllers,
    required VoidCallback onAdd,
    required Function(int) onRemove,
    String placeholder = '',
    TextInputType? keyboardType,
  }) {
    print('Building field section for: $label');
    return Column(
      children: [
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
                            child: const Icon(
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
                              decoration: const BoxDecoration(),
                            ),
                          ),
                        ],
                      ),
                      if (i < controllers.length - 1)
                        const Divider(height: 0, indent: 0),
                    ],
                  ),
              ],
            ),
          ),
        const SizedBox(height: 10),
        CupertinoButton(
          onPressed: onAdd,
          padding: EdgeInsets.zero,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: CupertinoColors.systemFill,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(
                  CupertinoIcons.add_circled_solid,
                  color: CupertinoColors.systemGreen,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'add ${label[0].toUpperCase()}${label.substring(1)}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.systemBackground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
